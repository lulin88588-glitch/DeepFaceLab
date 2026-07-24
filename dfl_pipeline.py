"""Recoverable one-click DeepFaceLab project pipeline helpers.

This module runs inside the Blackwell container.  It prepares project media,
quarantines low-quality aligned faces, writes a deterministic SAEHD preset,
switches an existing model into a conservative refinement phase, and validates
the final DeepFaceLive DFM file.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import os
import pickle
import re
import shutil
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable

import cv2
import numpy as np


IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}
VIDEO_EXTENSIONS = {
    ".mp4",
    ".mkv",
    ".mov",
    ".avi",
    ".webm",
    ".m4v",
    ".mpg",
    ".mpeg",
}
JSON_BEGIN = "DFL_PIPELINE_JSON_BEGIN"
JSON_END = "DFL_PIPELINE_JSON_END"


def _now() -> str:
    return datetime.now(timezone.utc).isoformat()


def _emit(result: dict[str, Any]) -> None:
    print(JSON_BEGIN)
    print(json.dumps(result, ensure_ascii=False))
    print(JSON_END)


def _atomic_write_bytes(path: Path, content: bytes) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(path.name + ".tmp")
    temporary.write_bytes(content)
    os.replace(temporary, path)


def _atomic_write_json(path: Path, value: Any) -> None:
    _atomic_write_bytes(
        path,
        json.dumps(value, ensure_ascii=False, indent=2).encode("utf-8"),
    )


def _iter_media(path: Path) -> list[Path]:
    if not path.exists():
        return []
    return sorted(
        item
        for item in path.rglob("*")
        if item.is_file()
        and item.suffix.lower() in IMAGE_EXTENSIONS | VIDEO_EXTENSIONS
    )


def _image_files(path: Path) -> list[Path]:
    if not path.exists():
        return []
    return sorted(
        item
        for item in path.iterdir()
        if item.is_file() and item.suffix.lower() in IMAGE_EXTENSIONS
    )


def _media_key(path: Path, root: Path) -> str:
    relative = path.relative_to(root).as_posix()
    digest = hashlib.sha1(relative.encode("utf-8")).hexdigest()[:10]
    return digest


def _write_frame(path: Path, frame: np.ndarray) -> bool:
    if path.exists():
        return False
    path.parent.mkdir(parents=True, exist_ok=True)
    return bool(
        cv2.imwrite(
            str(path),
            frame,
            [int(cv2.IMWRITE_JPEG_QUALITY), 96],
        )
    )


def _prepare_side(
    workspace: Path,
    side: str,
    fps: float,
    max_frames: int,
) -> dict[str, Any]:
    short_name = "src" if side == "data_src" else "dst"
    input_dir = workspace / f"input_{short_name}"
    output_dir = workspace / side
    output_dir.mkdir(parents=True, exist_ok=True)
    media = _iter_media(input_dir)
    created = 0
    skipped = 0
    unreadable = 0
    source_details: list[dict[str, Any]] = []
    total_frames = len(_image_files(output_dir))

    for source_index, source in enumerate(media):
        if max_frames and total_frames >= max_frames:
            break
        key = _media_key(source, input_dir)
        suffix = source.suffix.lower()
        if suffix in IMAGE_EXTENSIONS:
            frame = cv2.imread(str(source), cv2.IMREAD_COLOR)
            if frame is None:
                unreadable += 1
                continue
            output = output_dir / f"{short_name}_{source_index:04d}_{key}_000000.jpg"
            if _write_frame(output, frame):
                created += 1
                total_frames += 1
            else:
                skipped += 1
            source_details.append(
                {"file": source.relative_to(input_dir).as_posix(), "frames": 1}
            )
            continue

        capture = cv2.VideoCapture(str(source))
        if not capture.isOpened():
            unreadable += 1
            continue
        native_fps = float(capture.get(cv2.CAP_PROP_FPS) or 0.0)
        if not math.isfinite(native_fps) or native_fps <= 0:
            native_fps = 25.0
        output_fps = native_fps if fps <= 0 else min(fps, native_fps)
        interval = native_fps / output_fps
        next_frame = 0.0
        frame_index = 0
        saved_for_source = 0
        while True:
            ok, frame = capture.read()
            if not ok:
                break
            if frame_index + 1e-6 >= next_frame:
                output = output_dir / (
                    f"{short_name}_{source_index:04d}_{key}_{frame_index:08d}.jpg"
                )
                if _write_frame(output, frame):
                    created += 1
                    total_frames += 1
                else:
                    skipped += 1
                saved_for_source += 1
                next_frame += interval
                if max_frames and total_frames >= max_frames:
                    break
            frame_index += 1
        capture.release()
        source_details.append(
            {
                "file": source.relative_to(input_dir).as_posix(),
                "frames": saved_for_source,
                "native_fps": round(native_fps, 3),
                "sample_fps": round(output_fps, 3),
            }
        )

    return {
        "side": side,
        "input_dir": str(input_dir),
        "media_files": len(media),
        "created": created,
        "skipped": skipped,
        "unreadable": unreadable,
        "total_frames": total_frames,
        "sources": source_details,
    }


def prepare_media(
    workspace: Path,
    src_fps: float,
    dst_fps: float,
    max_src: int,
    max_dst: int,
) -> dict[str, Any]:
    src = _prepare_side(workspace, "data_src", src_fps, max_src)
    dst = _prepare_side(workspace, "data_dst", dst_fps, max_dst)
    if src["total_frames"] == 0:
        raise RuntimeError(
            "input_src 中没有可用照片或视频，无法生成 SRC 训练帧。"
        )
    if dst["total_frames"] == 0:
        raise RuntimeError(
            "input_dst 中没有可用照片或视频，无法生成 DST 训练帧。"
        )
    result = {
        "mode": "prepare",
        "created_at": _now(),
        "src": src,
        "dst": dst,
    }
    _atomic_write_json(
        workspace / ".dfl-pipeline" / "media-report.json", result
    )
    return result


def _dhash(gray: np.ndarray) -> str:
    resized = cv2.resize(gray, (9, 8), interpolation=cv2.INTER_AREA)
    bits = resized[:, 1:] > resized[:, :-1]
    return np.packbits(bits.reshape(-1).astype(np.uint8)).tobytes().hex()


def _pose_degrees(path: Path) -> tuple[float, float, float] | None:
    try:
        from DFLIMG import DFLIMG
        from facelib import LandmarksProcessor

        dfl_image = DFLIMG.load(path)
        if dfl_image is None or not dfl_image.has_data():
            return None
        pitch, yaw, roll = LandmarksProcessor.estimate_pitch_yaw_roll(
            dfl_image.get_landmarks(), size=512
        )
        return tuple(math.degrees(value) for value in (pitch, yaw, roll))
    except Exception:
        return None


def _screen_candidates(
    files: Iterable[Path],
    min_sharpness: float,
    min_brightness: float,
    max_brightness: float,
) -> tuple[list[dict[str, Any]], dict[str, Any]]:
    candidates: list[dict[str, Any]] = []
    hashes: dict[str, Path] = {}
    sharpness_values: list[float] = []
    brightness_values: list[float] = []
    yaw_values: list[float] = []
    readable = 0

    for path in files:
        image = cv2.imread(str(path), cv2.IMREAD_COLOR)
        if image is None:
            candidates.append(
                {"path": path, "reason": "unreadable", "priority": 0}
            )
            continue
        readable += 1
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        brightness = float(np.mean(gray))
        sharpness = float(cv2.Laplacian(gray, cv2.CV_64F).var())
        sharpness_values.append(sharpness)
        brightness_values.append(brightness)

        image_hash = _dhash(gray)
        if image_hash in hashes:
            candidates.append(
                {
                    "path": path,
                    "reason": "duplicate",
                    "priority": 4,
                    "value": image_hash,
                }
            )
        else:
            hashes[image_hash] = path

        if brightness < min_brightness:
            candidates.append(
                {
                    "path": path,
                    "reason": "too_dark",
                    "priority": 1,
                    "value": brightness,
                }
            )
        elif brightness > max_brightness:
            candidates.append(
                {
                    "path": path,
                    "reason": "too_bright",
                    "priority": 1,
                    "value": brightness,
                }
            )
        elif sharpness < min_sharpness:
            candidates.append(
                {
                    "path": path,
                    "reason": "blurry",
                    "priority": 2,
                    "value": sharpness,
                }
            )

        pose = _pose_degrees(path)
        if pose is not None:
            yaw_values.append(pose[1])

    unique: dict[Path, dict[str, Any]] = {}
    for item in sorted(candidates, key=lambda value: value["priority"]):
        unique.setdefault(item["path"], item)
    statistics = {
        "readable": readable,
        "median_sharpness": round(float(np.median(sharpness_values)), 1)
        if sharpness_values
        else 0.0,
        "median_brightness": round(float(np.median(brightness_values)), 1)
        if brightness_values
        else 0.0,
        "yaw_min": round(min(yaw_values), 1) if yaw_values else None,
        "yaw_max": round(max(yaw_values), 1) if yaw_values else None,
    }
    return list(unique.values()), statistics


def screen_faces(
    workspace: Path,
    side: str,
    min_sharpness: float,
    min_brightness: float,
    max_brightness: float,
    min_keep: int,
) -> dict[str, Any]:
    report_path = workspace / ".dfl-pipeline" / f"screen-{side}.json"
    if report_path.exists():
        result = json.loads(report_path.read_text(encoding="utf-8"))
        result["reused"] = True
        return result
    aligned = workspace / side / "aligned"
    if (aligned / "faceset.pak").exists():
        raise RuntimeError("筛选前需要先解包 faceset.pak。")
    files = _image_files(aligned)
    if not files:
        raise RuntimeError(f"{side}/aligned 中没有可筛选的人脸。")

    candidates, statistics = _screen_candidates(
        files, min_sharpness, min_brightness, max_brightness
    )
    max_reject = max(0, len(files) - max(1, min_keep))
    selected = candidates[:max_reject]
    quarantine = workspace / ".dfl-pipeline" / "rejected" / side
    moved: dict[str, int] = {}
    for item in selected:
        reason = item["reason"]
        destination_dir = quarantine / reason
        destination_dir.mkdir(parents=True, exist_ok=True)
        destination = destination_dir / item["path"].name
        if destination.exists():
            digest = hashlib.sha1(str(item["path"]).encode()).hexdigest()[:8]
            destination = destination.with_stem(destination.stem + "_" + digest)
        shutil.move(str(item["path"]), str(destination))
        moved[reason] = moved.get(reason, 0) + 1

    result = {
        "mode": "screen",
        "side": side,
        "created_at": _now(),
        "before": len(files),
        "kept": len(files) - len(selected),
        "quarantined": len(selected),
        "deferred_candidates": max(0, len(candidates) - len(selected)),
        "reasons": moved,
        "statistics": statistics,
        "quarantine": str(quarantine),
    }
    _atomic_write_json(report_path, result)
    return result


def _clean_model_name(value: str) -> str:
    cleaned = re.sub(r"[^A-Za-z0-9-]+", "-", value.strip()).strip("-")
    if not cleaned:
        raise ValueError("模型名称只能包含英文字母、数字和连字符。")
    return cleaned[:48]


def _base_options(
    resolution: int,
    batch_size: int,
    target_iter: int,
    use_xseg: bool,
) -> dict[str, Any]:
    return {
        "autobackup_hour": 1,
        "write_preview_history": True,
        "target_iter": target_iter,
        "random_src_flip": False,
        "random_dst_flip": True,
        "batch_size": batch_size,
        "resolution": resolution,
        "face_type": "wf",
        "archi": "df-ud",
        "ae_dims": 320,
        "e_dims": 64,
        "d_dims": 64,
        "d_mask_dims": 22,
        "masked_training": True,
        "eyes_mouth_prio": True,
        "uniform_yaw": True,
        "blur_out_mask": bool(use_xseg),
        "models_opt_on_gpu": True,
        "adabelief": True,
        "lr_dropout": "n",
        "random_warp": True,
        "random_hsv_power": 0.05,
        "gan_power": 0.0,
        "gan_patch_size": max(8, resolution // 8),
        "gan_dims": 16,
        "true_face_power": 0.0,
        "face_style_power": 0.0,
        "bg_style_power": 0.0,
        "ct_mode": "rct",
        "clipgrad": False,
        "pretrain": False,
    }


def write_preset(
    workspace: Path,
    model_name: str,
    resolution: int,
    batch_size: int,
    base_iter: int,
    final_iter: int,
    use_xseg: bool,
) -> dict[str, Any]:
    model_name = _clean_model_name(model_name)
    if resolution < 128 or resolution > 640 or resolution % 16:
        raise ValueError("分辨率必须是 128-640 之间的 16 的倍数。")
    if batch_size < 1 or batch_size > 32:
        raise ValueError("batch 必须在 1-32 之间。")
    if base_iter < 1000 or final_iter <= base_iter:
        raise ValueError("精修目标迭代必须大于基础目标迭代。")

    options = _base_options(
        resolution, batch_size, base_iter, use_xseg
    )
    model_dir = workspace / "model"
    model_dir.mkdir(parents=True, exist_ok=True)
    preset_pickle = model_dir / "SAEHD_default_options.dat"
    _atomic_write_bytes(preset_pickle, pickle.dumps(options, protocol=4))
    readable = {
        "model_name": model_name,
        "model_type": "SAEHD",
        "phase": "base",
        "base_target_iter": base_iter,
        "final_target_iter": final_iter,
        "options": options,
        "created_at": _now(),
    }
    _atomic_write_json(
        workspace / ".dfl-pipeline" / "model-preset.json", readable
    )
    return {
        "mode": "preset",
        **readable,
        "preset_file": str(preset_pickle),
    }


def refine_model(
    workspace: Path, model_name: str, final_iter: int
) -> dict[str, Any]:
    model_name = _clean_model_name(model_name)
    data_path = workspace / "model" / f"{model_name}_SAEHD_data.dat"
    if not data_path.exists():
        raise FileNotFoundError(f"找不到模型状态文件：{data_path}")
    model_data = pickle.loads(data_path.read_bytes())
    options = model_data.get("options")
    if not isinstance(options, dict):
        raise RuntimeError("模型状态文件缺少 options，无法安全进入精修阶段。")
    current_iter = int(model_data.get("iter", 0))
    if final_iter <= current_iter:
        final_iter = current_iter + 50_000

    backup_dir = workspace / ".dfl-pipeline" / "model-backups"
    backup_dir.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    backup = backup_dir / f"{data_path.name}.{stamp}.bak"
    shutil.copy2(data_path, backup)

    options.update(
        {
            "target_iter": final_iter,
            "lr_dropout": "y",
            "random_warp": False,
            "gan_power": 0.1,
            "gan_patch_size": max(
                8, int(options.get("resolution", 256)) // 8
            ),
            "gan_dims": 16,
            "clipgrad": True,
        }
    )
    model_data["options"] = options
    _atomic_write_bytes(data_path, pickle.dumps(model_data, protocol=4))
    result = {
        "mode": "refine",
        "model_name": model_name,
        "current_iter": current_iter,
        "target_iter": final_iter,
        "backup": str(backup),
        "changes": {
            "lr_dropout": "y",
            "random_warp": False,
            "gan_power": 0.1,
            "clipgrad": True,
        },
    }
    _atomic_write_json(
        workspace / ".dfl-pipeline" / "refine-report.json", result
    )
    return result


def _model_iteration(workspace: Path, model_name: str) -> int:
    data_path = workspace / "model" / f"{model_name}_SAEHD_data.dat"
    if not data_path.exists():
        return 0
    try:
        return int(pickle.loads(data_path.read_bytes()).get("iter", 0))
    except Exception:
        return 0


def _faceset_count(path: Path) -> int:
    packed = path / "faceset.pak"
    if packed.exists():
        try:
            from samplelib import PackedFaceset

            return len(PackedFaceset.load(path) or [])
        except Exception:
            return 0
    return len(_image_files(path))


def pipeline_status(workspace: Path, model_name: str) -> dict[str, Any]:
    model_name = _clean_model_name(model_name)
    dfm_source = (
        workspace / "model" / f"{model_name}_SAEHD_model.dfm"
    )
    dfm_output = workspace / "output" / f"{model_name}.dfm"
    return {
        "mode": "status",
        "model_name": model_name,
        "src_frames": len(_image_files(workspace / "data_src")),
        "dst_frames": len(_image_files(workspace / "data_dst")),
        "src_faces": _faceset_count(workspace / "data_src" / "aligned"),
        "dst_faces": _faceset_count(workspace / "data_dst" / "aligned"),
        "iteration": _model_iteration(workspace, model_name),
        "preview_exists": (workspace / ".dfl-preview.jpg").exists(),
        "dfm_source": str(dfm_source) if dfm_source.exists() else "",
        "dfm_output": str(dfm_output) if dfm_output.exists() else "",
    }


def collect_and_validate_dfm(
    workspace: Path, model_name: str
) -> dict[str, Any]:
    model_name = _clean_model_name(model_name)
    source = workspace / "model" / f"{model_name}_SAEHD_model.dfm"
    if not source.exists():
        raise FileNotFoundError(f"没有找到导出的 DFM：{source}")
    if source.stat().st_size < 1_000_000:
        raise RuntimeError("DFM 文件异常小，拒绝发布到 output。")

    import onnx

    model = onnx.load(str(source))
    onnx.checker.check_model(model)
    output_dir = workspace / "output"
    output_dir.mkdir(parents=True, exist_ok=True)
    destination = output_dir / f"{model_name}.dfm"
    temporary = destination.with_suffix(".dfm.tmp")
    shutil.copy2(source, temporary)
    os.replace(temporary, destination)
    digest = hashlib.sha256(destination.read_bytes()).hexdigest()
    result = {
        "mode": "validate",
        "model_name": model_name,
        "path": str(destination),
        "size_mib": round(destination.stat().st_size / 1024 / 1024, 2),
        "sha256": digest,
        "inputs": [value.name for value in model.graph.input],
        "outputs": [value.name for value in model.graph.output],
        "onnx_valid": True,
        "deepfacelive_ready": True,
    }
    _atomic_write_json(
        workspace / ".dfl-pipeline" / "dfm-report.json", result
    )
    return result


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--workspace", default="/workspace")
    subparsers = parser.add_subparsers(dest="command", required=True)

    prepare = subparsers.add_parser("prepare")
    prepare.add_argument("--src-fps", type=float, default=5.0)
    prepare.add_argument("--dst-fps", type=float, default=5.0)
    prepare.add_argument("--max-src", type=int, default=20_000)
    prepare.add_argument("--max-dst", type=int, default=30_000)

    screen = subparsers.add_parser("screen")
    screen.add_argument("--side", choices=("data_src", "data_dst"), required=True)
    screen.add_argument("--min-sharpness", type=float, default=45.0)
    screen.add_argument("--min-brightness", type=float, default=30.0)
    screen.add_argument("--max-brightness", type=float, default=225.0)
    screen.add_argument("--min-keep", type=int, default=64)

    preset = subparsers.add_parser("preset")
    preset.add_argument("--model-name", required=True)
    preset.add_argument("--resolution", type=int, default=256)
    preset.add_argument("--batch-size", type=int, default=8)
    preset.add_argument("--base-iter", type=int, default=300_000)
    preset.add_argument("--final-iter", type=int, default=500_000)
    preset.add_argument("--use-xseg", action="store_true")

    refine = subparsers.add_parser("refine")
    refine.add_argument("--model-name", required=True)
    refine.add_argument("--final-iter", type=int, required=True)

    status = subparsers.add_parser("status")
    status.add_argument("--model-name", required=True)

    validate = subparsers.add_parser("validate")
    validate.add_argument("--model-name", required=True)

    args = parser.parse_args()
    workspace = Path(args.workspace).resolve()
    workspace.mkdir(parents=True, exist_ok=True)

    if args.command == "prepare":
        result = prepare_media(
            workspace,
            args.src_fps,
            args.dst_fps,
            args.max_src,
            args.max_dst,
        )
    elif args.command == "screen":
        result = screen_faces(
            workspace,
            args.side,
            args.min_sharpness,
            args.min_brightness,
            args.max_brightness,
            args.min_keep,
        )
    elif args.command == "preset":
        result = write_preset(
            workspace,
            args.model_name,
            args.resolution,
            args.batch_size,
            args.base_iter,
            args.final_iter,
            args.use_xseg,
        )
    elif args.command == "refine":
        result = refine_model(
            workspace, args.model_name, args.final_iter
        )
    elif args.command == "status":
        result = pipeline_status(workspace, args.model_name)
    else:
        result = collect_and_validate_dfm(workspace, args.model_name)

    _emit(result)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
