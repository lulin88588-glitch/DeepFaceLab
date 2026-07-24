import unittest
from pathlib import Path


class HiddenGuiLauncherTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.repo_root = Path(__file__).resolve().parents[1]

    def test_vbs_launchers_hide_the_powershell_host(self):
        for stem in ("DeepFaceLab-GUI", "DeepFaceLab-OneClick"):
            launcher = (self.repo_root / f"{stem}.vbs").read_text(
                encoding="utf-8"
            )
            self.assertIn("-WindowStyle Hidden", launcher)
            self.assertIn("shell.Run command, 0, False", launcher)
            self.assertIn(f'"{stem}.ps1"', launcher)

    def test_cmd_compatibility_entries_delegate_to_wscript(self):
        for stem in ("DeepFaceLab-GUI", "DeepFaceLab-OneClick"):
            launcher = (self.repo_root / f"{stem}.cmd").read_text(
                encoding="utf-8"
            ).lower()
            self.assertIn("wscript.exe //nologo", launcher)
            self.assertIn(f"{stem.lower()}.vbs", launcher)
            self.assertNotIn("powershell.exe", launcher)

    def test_primary_windows_have_single_instance_mutexes(self):
        expected = {
            "DeepFaceLab-GUI.ps1": "Local\\DeepFaceLabTrainingConsole",
            "DeepFaceLab-OneClick.ps1": "Local\\DeepFaceLabOneClickGui",
        }
        for relative_path, mutex_name in expected.items():
            source = (self.repo_root / relative_path).read_text(
                encoding="utf-8"
            )
            self.assertIn(mutex_name, source)
            self.assertIn("AppActivate", source)
            self.assertIn("ReleaseMutex", source)

    def test_primary_windows_have_distinct_taskbar_icons(self):
        expected = {
            "DeepFaceLab-GUI.ps1": (
                "assets\\dfl-console.ico",
                "lulin88588.DeepFaceLab.TrainingConsole",
            ),
            "DeepFaceLab-OneClick.ps1": (
                "assets\\dfl-oneclick.ico",
                "lulin88588.DeepFaceLab.OneClickDfm",
            ),
        }
        for relative_path, (icon_path, app_id) in expected.items():
            source = (self.repo_root / relative_path).read_text(
                encoding="utf-8"
            )
            self.assertIn(icon_path, source)
            self.assertIn(app_id, source)
        for icon_name in ("dfl-console.ico", "dfl-oneclick.ico"):
            icon = self.repo_root / "assets" / icon_name
            self.assertTrue(icon.is_file())
            self.assertGreater(icon.stat().st_size, 1024)

    def test_training_console_embeds_ai_core_workflow(self):
        source = (self.repo_root / "DeepFaceLab-GUI.ps1").read_text(
            encoding="utf-8"
        )
        for contract in (
            "$aiPanel.Visible = $true",
            "function Start-AiAnalysis",
            "function Apply-AiRecommendation",
            "Start-AiAnalysis 'recommend'",
            "dfl_ai_assistant.py",
            "dfl_pipeline.py",
            "DFL_AI_JSON_BEGIN",
            "Save-AiPayload",
            "recommended_options",
        ):
            self.assertIn(contract, source)


if __name__ == "__main__":
    unittest.main()
