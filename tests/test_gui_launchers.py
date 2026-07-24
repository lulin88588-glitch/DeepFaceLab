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


if __name__ == "__main__":
    unittest.main()
