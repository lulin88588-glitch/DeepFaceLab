import os
import pickle
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import cv2
import numpy as np

import dfl_pipeline
from core.interact import interact
from mainscripts import ExportDFM


class DflPipelineTest(unittest.TestCase):
    def test_prepare_media_imports_both_sides_idempotently(self):
        with tempfile.TemporaryDirectory() as directory:
            workspace = Path(directory)
            for side, value in (("src", 90), ("dst", 150)):
                input_dir = workspace / f"input_{side}"
                input_dir.mkdir(parents=True)
                image = np.full((96, 96, 3), value, dtype=np.uint8)
                self.assertTrue(
                    cv2.imwrite(str(input_dir / f"{side}.jpg"), image)
                )

            first = dfl_pipeline.prepare_media(workspace, 5, 5, 100, 100)
            second = dfl_pipeline.prepare_media(workspace, 5, 5, 100, 100)

            self.assertEqual(first["src"]["created"], 1)
            self.assertEqual(first["dst"]["created"], 1)
            self.assertEqual(second["src"]["created"], 0)
            self.assertEqual(second["dst"]["created"], 0)
            self.assertEqual(second["src"]["total_frames"], 1)
            self.assertEqual(second["dst"]["total_frames"], 1)

    def test_screen_candidates_classifies_without_deleting(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            dark = np.zeros((128, 128, 3), dtype=np.uint8)
            bright = np.full((128, 128, 3), 255, dtype=np.uint8)
            flat = np.full((128, 128, 3), 110, dtype=np.uint8)
            paths = []
            for name, image in (
                ("dark.jpg", dark),
                ("bright.jpg", bright),
                ("flat.jpg", flat),
            ):
                path = root / name
                self.assertTrue(cv2.imwrite(str(path), image))
                paths.append(path)

            candidates, statistics = dfl_pipeline._screen_candidates(
                paths, 45.0, 30.0, 225.0
            )

            reasons = {item["reason"] for item in candidates}
            self.assertIn("too_dark", reasons)
            self.assertIn("too_bright", reasons)
            self.assertIn("blurry", reasons)
            self.assertEqual(statistics["readable"], 3)
            self.assertTrue(all(path.exists() for path in paths))

    def test_preset_and_refinement_are_reproducible_and_backed_up(self):
        with tempfile.TemporaryDirectory() as directory:
            workspace = Path(directory)
            result = dfl_pipeline.write_preset(
                workspace,
                "portrait-model",
                resolution=256,
                batch_size=8,
                base_iter=300_000,
                final_iter=500_000,
                use_xseg=True,
            )
            options = pickle.loads(Path(result["preset_file"]).read_bytes())
            self.assertEqual(options["archi"], "df-ud")
            self.assertEqual(options["ae_dims"], 320)
            self.assertEqual(options["e_dims"], 64)
            self.assertEqual(options["d_dims"], 64)
            self.assertEqual(options["target_iter"], 300_000)
            self.assertTrue(options["random_warp"])
            self.assertEqual(options["gan_power"], 0.0)

            data_path = (
                workspace / "model" / "portrait-model_SAEHD_data.dat"
            )
            data_path.write_bytes(
                pickle.dumps(
                    {"iter": 300_000, "options": options}, protocol=4
                )
            )
            refined = dfl_pipeline.refine_model(
                workspace, "portrait-model", 500_000
            )
            model_data = pickle.loads(data_path.read_bytes())

            self.assertTrue(Path(refined["backup"]).exists())
            self.assertEqual(model_data["options"]["target_iter"], 500_000)
            self.assertEqual(model_data["options"]["lr_dropout"], "y")
            self.assertFalse(model_data["options"]["random_warp"])
            self.assertEqual(model_data["options"]["gan_power"], 0.1)

    def test_non_interactive_mode_uses_defaults(self):
        with patch.dict(os.environ, {"DFL_NON_INTERACTIVE": "1"}):
            self.assertEqual(interact.input_int("Integer", 7), 7)
            self.assertTrue(interact.input_bool("Boolean", True))
            self.assertEqual(interact.input_str("String", "default"), "default")
            self.assertFalse(interact.input_in_time("Timed", 1))

    def test_export_forwards_forced_model_name(self):
        captured = {}

        class FakeModel:
            def __init__(self, **kwargs):
                captured.update(kwargs)

            def export_dfm(self):
                captured["exported"] = True

        with patch.object(
            ExportDFM.models, "import_model", return_value=FakeModel
        ):
            ExportDFM.main("SAEHD", Path("/models"), "portrait-model")

        self.assertEqual(captured["force_model_name"], "portrait-model")
        self.assertTrue(captured["exported"])


if __name__ == "__main__":
    unittest.main()
