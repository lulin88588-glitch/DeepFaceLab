"""Privacy-first local analysis for the DeepFaceLab Windows AI assistant."""

from __future__ import annotations

import argparse
import base64
import json
import os
import re
import statistics
import subprocess
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable

import cv2
import numpy as np


IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}
JSON_BEGIN = "DFL_AI_JSON_BEGIN"
JSON_END = "DFL_AI_JSON_END"


@dataclass
class ImageMetrics:
    width: int
    height: int
    brightness: float
    contrast: float
    sharpness: float
    dark_clip: float
    bright_clip: float
    perceptual_hash: str


def _image_files(path: Path) -> list[Path]:
    if not path.exists():
        return []
    return sorted(
        item
        for item in path.iterdir()
        if item.is_file() and item.suffix.lower() in IMAGE_EXTENSIONS
    )


def _even_sample(items: list[Path], limit: int) -> list[Path]:
    if len(items) <= limit:
        return items
    indexes = np.linspace(0, len(items) - 1, limit, dtype=np.int64)
    return [items[int(index)] for index in indexes]


def _perceptual_hash(gray: np.ndarray) -> str:
    resized = cv2.resize(gray, (9, 8), interpolation=cv2.INTER_AREA)
    bits = resized[:, 1:] > resized[:, :-1]
    packed = np.packbits(bits.reshape(-1).astype(np.uint8))
    return packed.tobytes().hex()


def _metrics_from_image(image: np.ndarray | None) -> ImageMetrics | None:
    if image is None or image.size == 0:
        return None
    height, width = image.shape[:2]
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    return ImageMetrics(
        width=width,
        height=height,
        brightness=float(np.mean(gray)),
        contrast=float(np.std(gray)),
        sharpness=float(cv2.Laplacian(gray, cv2.CV_64F).var()),
        dark_clip=float(np.mean(gray <= 8)),
        bright_clip=float(np.mean(gray >= 247)),
        perceptual_hash=_perceptual_hash(gray),
    )


def _read_metrics(path: Path) -> ImageMetrics | None:
    return _metrics_from_image(cv2.imread(str(path), cv2.IMREAD_COLOR))


def _median(values: Iterable[float]) -> float:
    values = list(values)
    return float(statistics.median(values)) if values else 0.0


def analyze_faceset(path: Path, sample_limit: int) -> dict[str, Any]:
    files = _image_files(path)
    metrics: list[ImageMetrics] = []
    unreadable = 0
    hashes: dict[str, int] = {}
    storage = "files"
    total_count = len(files)
    sampled_count = 0

    packed_path = path / "faceset.pak"
    if packed_path.exists():
        storage = "packed"
        from samplelib import PackedFaceset

        packed_samples = PackedFaceset.load(path) or []
        total_count = len(packed_samples)
        indexes = list(range(total_count))
        if len(indexes) > sample_limit:
            indexes = [
                int(index)
                for index in np.linspace(
                    0, len(indexes) - 1, sample_limit, dtype=np.int64
                )
            ]
        sampled_count = len(indexes)
        for index in indexes:
            raw = packed_samples[index].read_raw_file()
            image = cv2.imdecode(
                np.frombuffer(raw, dtype=np.uint8), cv2.IMREAD_COLOR
            )
            item = _metrics_from_image(image)
            if item is None:
                unreadable += 1
                continue
            metrics.append(item)
            hashes[item.perceptual_hash] = (
                hashes.get(item.perceptual_hash, 0) + 1
            )
    else:
        sampled = _even_sample(files, sample_limit)
        sampled_count = len(sampled)
        for file_path in sampled:
            item = _read_metrics(file_path)
            if item is None:
                unreadable += 1
                continue
            metrics.append(item)
            hashes[item.perceptual_hash] = (
                hashes.get(item.perceptual_hash, 0) + 1
            )

    duplicate_samples = sum(count - 1 for count in hashes.values() if count > 1)
    blurry = sum(item.sharpness < 45.0 for item in metrics)
    too_dark = sum(
        item.brightness < 45.0 or item.dark_clip > 0.30 for item in metrics
    )
    too_bright = sum(
        item.brightness > 215.0 or item.bright_clip > 0.30 for item in metrics
    )
    low_contrast = sum(item.contrast < 25.0 for item in metrics)
    small = sum(min(item.width, item.height) < 256 for item in metrics)
    resolutions = sorted({f"{item.width}x{item.height}" for item in metrics})
    valid_count = len(metrics)

    return {
        "path": str(path),
        "storage": storage,
        "count": total_count,
        "sampled": sampled_count,
        "valid_sampled": valid_count,
        "unreadable": unreadable,
        "median_width": int(_median(item.width for item in metrics)),
        "median_height": int(_median(item.height for item in metrics)),
        "median_brightness": round(
            _median(item.brightness for item in metrics), 1
        ),
        "median_contrast": round(_median(item.contrast for item in metrics), 1),
        "median_sharpness": round(_median(item.sharpness for item in metrics), 1),
        "blurry": blurry,
        "too_dark": too_dark,
        "too_bright": too_bright,
        "low_contrast": low_contrast,
        "small": small,
        "duplicate_samples": duplicate_samples,
        "resolutions": resolutions[:12],
    }


def _percentage(value: int, total: int) -> float:
    return round(value * 100.0 / total, 1) if total else 0.0


def _quality_lines(label: str, data: dict[str, Any]) -> list[str]:
    storage = "已打包" if data["storage"] == "packed" else "独立文件"
    lines = [
        (
            f"{label}: {data['count']} 张；抽样 {data['valid_sampled']} 张；"
            f"中位尺寸 {data['median_width']}x{data['median_height']}；{storage}"
        )
    ]
    if data["valid_sampled"]:
        lines.append(
            (
                f"  清晰度 {data['median_sharpness']:.1f}；"
                f"亮度 {data['median_brightness']:.1f}；"
                f"对比度 {data['median_contrast']:.1f}"
            )
        )
        lines.append(
            (
                f"  疑似模糊 {_percentage(data['blurry'], data['valid_sampled'])}%；"
                f"过暗 {_percentage(data['too_dark'], data['valid_sampled'])}%；"
                f"过亮 {_percentage(data['too_bright'], data['valid_sampled'])}%"
            )
        )
    return lines


def _workspace_issues(
    src: dict[str, Any], dst: dict[str, Any]
) -> tuple[list[dict[str, str]], int]:
    issues: list[dict[str, str]] = []
    score = 100

    for label, data in (("SRC", src), ("DST", dst)):
        if data["count"] == 0:
            issues.append(
                {
                    "severity": "高",
                    "title": f"{label} 没有对齐人脸",
                    "detail": "无法开始有效训练。",
                    "action": f"先完成 {label} 人脸提取并检查 aligned 目录。",
                }
            )
            score -= 45
        elif data["count"] < 20:
            issues.append(
                {
                    "severity": "高",
                    "title": f"{label} 素材数量过少",
                    "detail": f"当前只有 {data['count']} 张，身份和姿态覆盖不足。",
                    "action": f"补充 {label} 视频帧并重新提取，至少先达到数百张。",
                }
            )
            score -= 30
        elif data["count"] < 200:
            issues.append(
                {
                    "severity": "中",
                    "title": f"{label} 素材数量偏少",
                    "detail": f"当前 {data['count']} 张，可能限制泛化能力。",
                    "action": f"继续补充 {label} 的角度、表情和光照变化。",
                }
            )
            score -= 12

        valid = data["valid_sampled"]
        if data["unreadable"]:
            issues.append(
                {
                    "severity": "高",
                    "title": f"{label} 存在无法读取的图片",
                    "detail": f"抽样中发现 {data['unreadable']} 张损坏或格式异常。",
                    "action": "移出损坏文件后重新检查。",
                }
            )
            score -= 15
        if valid and data["blurry"] / valid > 0.20:
            issues.append(
                {
                    "severity": "中",
                    "title": f"{label} 模糊样本偏多",
                    "detail": (
                        f"抽样中约 {_percentage(data['blurry'], valid)}% "
                        "清晰度偏低。"
                    ),
                    "action": "使用查看/排序工具复核模糊帧，确认后再清理。",
                }
            )
            score -= 12
        if valid and (data["too_dark"] + data["too_bright"]) / valid > 0.20:
            issues.append(
                {
                    "severity": "中",
                    "title": f"{label} 曝光异常样本偏多",
                    "detail": "过暗或过亮样本可能影响颜色和细节学习。",
                    "action": "复核曝光异常帧，保留具有代表性的光照变化。",
                }
            )
            score -= 8
        if data["duplicate_samples"] > max(3, int(valid * 0.10)):
            issues.append(
                {
                    "severity": "低",
                    "title": f"{label} 疑似重复帧偏多",
                    "detail": (
                        f"抽样中发现约 {data['duplicate_samples']} 个感知重复项。"
                    ),
                    "action": "使用排序工具减少连续重复帧，提高有效多样性。",
                }
            )
            score -= 5
        if len(data["resolutions"]) > 3:
            issues.append(
                {
                    "severity": "低",
                    "title": f"{label} 尺寸不完全一致",
                    "detail": "检测到多种对齐图像尺寸。",
                    "action": "训练前确认 faceset resize 和 face type 设置一致。",
                }
            )
            score -= 4

    smaller = min(src["count"], dst["count"])
    larger = max(src["count"], dst["count"])
    if smaller and larger / smaller >= 5:
        issues.append(
            {
                "severity": "高",
                "title": "SRC 与 DST 数量严重失衡",
                "detail": f"SRC {src['count']} 张，DST {dst['count']} 张。",
                "action": "优先补充数量较少的一侧，再开始长时间训练。",
            }
        )
        score -= 20

    return issues, max(0, min(100, score))


def _score_label(score: int) -> str:
    if score >= 85:
        return "良好"
    if score >= 65:
        return "可用，但建议优化"
    if score >= 40:
        return "存在明显问题"
    return "暂不建议训练"


def _render_issues(issues: list[dict[str, str]]) -> list[str]:
    if not issues:
        return ["未发现需要优先处理的明显问题。"]
    lines: list[str] = []
    order = {"高": 0, "中": 1, "低": 2}
    for index, issue in enumerate(
        sorted(issues, key=lambda item: order[item["severity"]]), start=1
    ):
        lines.extend(
            [
                f"{index}. [{issue['severity']}] {issue['title']}",
                f"   {issue['detail']}",
                f"   建议：{issue['action']}",
            ]
        )
    return lines


def _decision_from_issues(
    score: int, issues: list[dict[str, str]]
) -> dict[str, Any]:
    severity_order = {"高": 0, "中": 1, "低": 2}
    ordered = sorted(
        issues, key=lambda item: severity_order.get(item["severity"], 9)
    )
    has_high = any(issue["severity"] == "高" for issue in issues)
    if score < 40 or has_high:
        risk_level = "blocked"
    elif score < 85 or issues:
        risk_level = "warning"
    else:
        risk_level = "ready"
    can_train = score >= 65 and not has_high
    next_action = (
        ordered[0]["action"]
        if ordered
        else "素材状态良好，可以生成推荐配置并开始训练。"
    )
    return {
        "risk_level": risk_level,
        "can_train": can_train,
        "next_action": next_action,
    }


def workspace_analysis(workspace: Path, sample_limit: int) -> dict[str, Any]:
    src = analyze_faceset(workspace / "data_src" / "aligned", sample_limit)
    dst = analyze_faceset(workspace / "data_dst" / "aligned", sample_limit)
    issues, score = _workspace_issues(src, dst)
    decision = _decision_from_issues(score, issues)
    report_lines = [
        "本地 AI 素材质检",
        "=" * 56,
        f"综合评分：{score}/100 · {_score_label(score)}",
        f"工作区：{workspace}",
        "",
        "数据概况",
        "-" * 56,
        *_quality_lines("SRC", src),
        *_quality_lines("DST", dst),
        "",
        "诊断与建议",
        "-" * 56,
        *_render_issues(issues),
        "",
        "说明：本次分析只读取素材并进行本地图像统计，没有修改或上传文件。",
    ]
    return {
        "mode": "workspace",
        "score": score,
        "src": src,
        "dst": dst,
        "issues": issues,
        **decision,
        "report": "\n".join(report_lines),
    }


def _parse_model_summaries(model_dir: Path) -> list[dict[str, Any]]:
    models: list[dict[str, Any]] = []
    for path in sorted(model_dir.glob("*_summary.txt")):
        text = path.read_text(encoding="utf-8", errors="replace")
        values: dict[str, str] = {}
        for line in text.splitlines():
            match = re.match(r"==\s*([^:=]+):\s*(.*?)\s*==", line)
            if match:
                values[match.group(1).strip()] = match.group(2).strip()
        models.append(
            {
                "file": path.name,
                "name": values.get("Model name", path.stem.replace("_summary", "")),
                "iteration": int(values.get("Current iteration", "0") or 0),
                "resolution": values.get("resolution", "未知"),
                "face_type": values.get("face_type", "未知"),
                "archi": values.get("archi", "未知"),
                "batch_size": values.get("batch_size", "未知"),
                "device": values.get("Name", "未知"),
                "vram": values.get("VRAM", "未知"),
                "modified": datetime.fromtimestamp(
                    path.stat().st_mtime, tz=timezone.utc
                ).isoformat(),
            }
        )
    return models


def _decode_runtime_log() -> str:
    encoded = os.environ.get("DFL_AI_LOG_B64", "")
    if not encoded:
        return ""
    try:
        return base64.b64decode(encoded).decode("utf-8", errors="replace")
    except Exception:
        return ""


def _preview_analysis(path: Path) -> dict[str, Any]:
    if not path.exists():
        return {"exists": False}
    metrics = _read_metrics(path)
    if metrics is None:
        return {"exists": True, "readable": False}
    age_seconds = max(0.0, datetime.now().timestamp() - path.stat().st_mtime)
    return {
        "exists": True,
        "readable": True,
        "width": metrics.width,
        "height": metrics.height,
        "brightness": round(metrics.brightness, 1),
        "contrast": round(metrics.contrast, 1),
        "sharpness": round(metrics.sharpness, 1),
        "age_seconds": round(age_seconds, 1),
    }


def training_analysis(workspace: Path, sample_limit: int) -> dict[str, Any]:
    material = workspace_analysis(workspace, sample_limit)
    models = _parse_model_summaries(workspace / "model")
    preview = _preview_analysis(workspace / ".dfl-preview.jpg")
    state = os.environ.get("DFL_AI_CONTAINER_STATE", "").strip() or "未运行"
    state_label = {
        "running": "运行中",
        "stopped": "已停止",
        "exited": "已退出",
        "created": "已创建",
        "restarting": "正在重启",
    }.get(state, state)
    runtime_log = _decode_runtime_log()
    log_lower = runtime_log.lower()
    errors = []
    for marker, label in (
        ("out of memory", "检测到显存不足"),
        ("resourceexhausted", "检测到 TensorFlow 资源耗尽"),
        ("traceback", "最近日志包含 Python 异常"),
        ("nan", "最近日志出现 NaN"),
        ("failed", "最近日志包含失败信息"),
    ):
        if marker in log_lower:
            errors.append(label)
    metric_lines = [
        line.strip()
        for line in runtime_log.splitlines()
        if re.search(r"\]\[\d+ms\]\[", line)
    ]
    last_metric = metric_lines[-1] if metric_lines else ""

    recommendations: list[str] = []
    if state == "running":
        recommendations.append("训练容器正在运行；保持定期备份并观察预览变化。")
    else:
        recommendations.append("训练容器当前未运行，可先完成素材修正后再启动。")
    if material["score"] < 65:
        recommendations.append("素材评分较低，优先处理素材问题比继续堆叠迭代更有效。")
    elif any(
        issue["severity"] == "高" for issue in material.get("issues", [])
    ):
        recommendations.append("素材仍有高优先级问题，建议处理后再进行长时间训练。")
    if errors:
        recommendations.append("先处理最近日志中的异常，再继续训练。")
    if preview.get("exists") and preview.get("readable"):
        if preview["age_seconds"] > 180 and state == "running":
            recommendations.append("预览图超过 3 分钟未更新，检查训练是否卡住。")
        if preview["brightness"] < 35 or preview["brightness"] > 225:
            recommendations.append("预览整体曝光异常，需要复核素材或模型状态。")
    else:
        recommendations.append("尚无可读预览图；模型加载完成后再进行视觉判断。")
    if not models:
        recommendations.append("未找到模型摘要，首次训练需要完成交互式模型配置。")
    health = (
        "error"
        if errors
        else "running"
        if state == "running"
        else "needs_attention"
        if material["risk_level"] != "ready"
        else "idle"
    )

    report_lines = [
        "本地 AI 训练状态诊断",
        "=" * 56,
        f"容器状态：{state_label}",
        f"素材评分：{material['score']}/100 · {_score_label(material['score'])}",
        "",
        "模型",
        "-" * 56,
    ]
    if models:
        for model in models:
            report_lines.append(
                (
                    f"{model['name']}：迭代 {model['iteration']:,}；"
                    f"分辨率 {model['resolution']}；batch {model['batch_size']}；"
                    f"架构 {model['archi']}"
                )
            )
    else:
        report_lines.append("未发现模型摘要。")
    report_lines.extend(["", "预览", "-" * 56])
    if preview.get("readable"):
        report_lines.append(
            (
                f"{preview['width']}x{preview['height']}；"
                f"清晰度 {preview['sharpness']:.1f}；"
                f"亮度 {preview['brightness']:.1f}；"
                f"距上次更新 {preview['age_seconds']:.0f} 秒"
            )
        )
    else:
        report_lines.append("当前没有可读的训练预览。")
    report_lines.extend(["", "最近日志", "-" * 56])
    if errors:
        report_lines.extend(f"- {item}" for item in errors)
    elif runtime_log:
        report_lines.append("最近日志未匹配到常见严重错误。")
    else:
        report_lines.append("当前没有训练容器日志。")
    if last_metric:
        report_lines.append(f"最近训练指标：{last_metric}")
    report_lines.extend(["", "建议", "-" * 56])
    report_lines.extend(
        f"{index}. {item}" for index, item in enumerate(recommendations, start=1)
    )
    report_lines.append(
        "\n说明：诊断基于本地素材统计、模型摘要、预览和最近日志，不会自动修改训练。"
    )
    return {
        "mode": "training",
        "state": state,
        "material_score": material["score"],
        "models": models,
        "preview": preview,
        "log_errors": errors,
        "health": health,
        "next_action": recommendations[0],
        "report": "\n".join(report_lines),
    }


def _gpu_info() -> dict[str, Any]:
    command = [
        "nvidia-smi",
        "--query-gpu=name,memory.total,memory.free,temperature.gpu",
        "--format=csv,noheader,nounits",
    ]
    try:
        result = subprocess.run(
            command, capture_output=True, text=True, timeout=5, check=True
        )
        values = [value.strip() for value in result.stdout.splitlines()[0].split(",")]
        return {
            "name": values[0],
            "memory_total_mib": int(values[1]),
            "memory_free_mib": int(values[2]),
            "temperature": int(values[3]),
        }
    except Exception:
        return {
            "name": "未检测到",
            "memory_total_mib": 0,
            "memory_free_mib": 0,
            "temperature": 0,
        }


def recommendation_analysis(
    workspace: Path, sample_limit: int, requested_model: str
) -> dict[str, Any]:
    material = workspace_analysis(workspace, sample_limit)
    models = _parse_model_summaries(workspace / "model")
    gpu = _gpu_info()
    material_decision = _decision_from_issues(
        material["score"], material.get("issues", [])
    )
    material_can_train = material.get(
        "can_train", material_decision["can_train"]
    )
    material_risk = material.get(
        "risk_level", material_decision["risk_level"]
    )
    material_next_action = material.get(
        "next_action", material_decision["next_action"]
    )
    vram_gib = gpu["memory_total_mib"] / 1024.0
    src_count = material["src"]["count"]
    dst_count = material["dst"]["count"]
    smaller = min(src_count, dst_count)
    larger = max(src_count, dst_count)
    severely_imbalanced = bool(smaller and larger / smaller >= 5)

    if smaller < 20:
        readiness = "暂不建议开始长时间训练"
    elif severely_imbalanced:
        readiness = "建议先补充数量较少的一侧"
    elif material["score"] < 65:
        readiness = "建议先清理素材"
    else:
        readiness = "可以开始或继续训练"

    if vram_gib >= 28:
        resolution = 256
        batch = "8-12"
        batch_recommended = 8
    elif vram_gib >= 20:
        resolution = 224
        batch = "6-8"
        batch_recommended = 6
    elif vram_gib >= 12:
        resolution = 192
        batch = "4-6"
        batch_recommended = 4
    else:
        resolution = 160
        batch = "2-4"
        batch_recommended = 2

    model_type = requested_model or "SAEHD"
    advice = [
        f"训练准备度：{readiness}。",
        (
            f"新建 {model_type} 模型时，可从分辨率 {resolution}、"
            f"batch {batch} 开始，再根据实际显存占用调整。"
        ),
        "优先保证 DST 的姿态、表情和光照覆盖，不要只追求帧数。",
        "先关闭 GAN 完成主体和细节学习，预览稳定后再低强度开启 GAN。",
        "每小时自动备份；任何结构参数变化都应新建模型，不覆盖已训练模型。",
    ]
    if models:
        advice.insert(
            1,
            (
                "检测到已有模型：继续训练时沿用其结构参数，"
                "不要直接修改分辨率、架构或维度。"
            ),
        )
    if severely_imbalanced:
        advice.insert(1, "SRC/DST 数量严重失衡，先补充较少的一侧。")

    report_lines = [
        "本地 AI 配置建议",
        "=" * 56,
        f"GPU：{gpu['name']}",
        (
            f"显存：{gpu['memory_total_mib']} MiB 总量；"
            f"{gpu['memory_free_mib']} MiB 当前可用；温度 {gpu['temperature']}°C"
        ),
        f"素材：SRC {src_count} 张；DST {dst_count} 张；评分 {material['score']}/100",
        "",
        "建议",
        "-" * 56,
    ]
    report_lines.extend(
        f"{index}. {item}" for index, item in enumerate(advice, start=1)
    )
    report_lines.extend(
        [
            "",
            "建议的新模型起点",
            "-" * 56,
            f"模型：{model_type}",
            f"分辨率：{resolution}",
            f"batch：{batch}",
            "face type：whole_face",
            "优化器：AdaBelief",
            "",
            "说明：这是根据本机显存和当前素材规模生成的保守起点，不会自动改写模型。",
        ]
    )
    return {
        "mode": "recommend",
        "gpu": gpu,
        "material_score": material["score"],
        "readiness": readiness,
        "model_type": model_type,
        "resolution": resolution,
        "batch": batch,
        "batch_recommended": batch_recommended,
        "can_apply": model_type == "SAEHD",
        "can_train": material_can_train,
        "risk_level": material_risk,
        "next_action": material_next_action,
        "recommended_options": {
            "resolution": resolution,
            "batch_size": batch_recommended,
            "face_type": "whole_face",
            "architecture": "df-ud",
            "optimizer": "AdaBelief",
            "base_iterations": 300_000,
            "final_iterations": 500_000,
            "use_xseg": True,
        },
        "report": "\n".join(report_lines),
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--mode", choices=("workspace", "training", "recommend"), required=True
    )
    parser.add_argument("--workspace", default="/workspace")
    parser.add_argument("--sample-limit", type=int, default=120)
    parser.add_argument("--model-type", default="SAEHD")
    args = parser.parse_args()

    workspace = Path(args.workspace).resolve()
    if not workspace.exists():
        raise FileNotFoundError(f"Workspace does not exist: {workspace}")

    if args.mode == "workspace":
        result = workspace_analysis(workspace, args.sample_limit)
    elif args.mode == "training":
        result = training_analysis(workspace, args.sample_limit)
    else:
        result = recommendation_analysis(
            workspace, args.sample_limit, args.model_type
        )

    print(JSON_BEGIN)
    print(json.dumps(result, ensure_ascii=False))
    print(JSON_END)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
