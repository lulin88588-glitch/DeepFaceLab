import unittest
import tempfile
import zipfile
from pathlib import Path
from types import SimpleNamespace
from unittest import mock

from blackwell_support import (
    get_cuda_capability_tokens,
    parse_compute_capability,
    parse_cuda_version,
    validate_blackwell_device,
    validate_tensorflow_build,
)
from docker.verify_tensorflow_wheel import verify_wheel


class BlackwellSupportTest(unittest.TestCase):
    def test_docker_build_contract_is_pinned_and_native(self):
        repository = Path(__file__).resolve().parents[1]
        dockerfile = (repository / "Dockerfile.blackwell").read_text(
            encoding="utf-8"
        )
        for expected in (
            "a481b10260dfdf833a1b16007eead49c1d7febf3",
            "HERMETIC_CUDA_VERSION=12.8.1",
            "HERMETIC_CUDNN_VERSION=9.8.0",
            "HERMETIC_CUDA_COMPUTE_CAPABILITIES=sm_120,compute_120",
            "--config=cuda_nvcc",
            "verify-tensorflow-wheel.py",
            "verify_tensorflow_build.py",
            "DFL_REQUIRE_NATIVE_BLACKWELL=1",
        ):
            with self.subTest(expected=expected):
                self.assertIn(expected, dockerfile)

        self.assertRegex(
            dockerfile,
            r"FROM nvidia/cuda:[^\s]+@sha256:[0-9a-f]{64}",
        )
        self.assertNotIn("--config=cuda_clang", dockerfile)

    def test_version_and_device_normalization(self):
        self.assertEqual(parse_cuda_version("12.8.1"), (12, 8))
        self.assertEqual(parse_cuda_version("64_112"), (11, 2))
        self.assertIsNone(parse_cuda_version("unknown"))
        self.assertEqual(parse_compute_capability((12, 0)), (12, 0))
        self.assertEqual(parse_compute_capability("12.0"), (12, 0))
        self.assertEqual(parse_compute_capability("sm_120"), (12, 0))
        self.assertEqual(
            validate_blackwell_device({"compute_capability": "sm_120"}),
            (12, 0),
        )

    def test_build_capabilities_accept_list_or_string(self):
        base = {
            "is_cuda_build": True,
            "cuda_version": "12.8.1",
            "cuda_compute_capabilities": ["sm_90", "sm_120", "compute_120"],
        }
        self.assertIn("sm_120", validate_tensorflow_build(base))

        string_capabilities = dict(base)
        string_capabilities["cuda_compute_capabilities"] = (
            "sm_90,sm_120,compute_120"
        )
        self.assertIn("sm_120", validate_tensorflow_build(string_capabilities))
        self.assertEqual(
            get_cuda_capability_tokens(string_capabilities),
            {"sm_90", "sm_120", "compute_120"},
        )

    def test_build_rejects_ptx_only_or_false_substring(self):
        for capabilities in (["compute_120"], ["sm_1200"]):
            with self.subTest(capabilities=capabilities):
                with self.assertRaises(RuntimeError):
                    validate_tensorflow_build(
                        {
                            "is_cuda_build": True,
                            "cuda_version": "12.8.1",
                            "cuda_compute_capabilities": capabilities,
                        }
                    )

        with self.assertRaises(RuntimeError):
            validate_tensorflow_build(
                {
                    "is_cuda_build": True,
                    "cuda_version": "12.7",
                    "cuda_compute_capabilities": ["sm_120"],
                }
            )

    def test_wheel_cubin_inspection_uses_exact_architecture(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            wheel = Path(temp_dir) / "tensorflow-test.whl"
            with zipfile.ZipFile(str(wheel), "w") as archive:
                archive.writestr("tensorflow/python/kernel.so", b"ELF")

            valid_result = SimpleNamespace(
                returncode=0,
                stdout="ELF file: kernel.1.sm_120.cubin\n",
            )
            with mock.patch(
                "docker.verify_tensorflow_wheel.subprocess.run",
                return_value=valid_result,
            ) as run:
                verify_wheel(str(wheel), "cuobjdump")
                self.assertTrue(run.called)

            invalid_result = SimpleNamespace(
                returncode=0,
                stdout="ELF file: kernel.1.sm_1200.cubin\n",
            )
            with mock.patch(
                "docker.verify_tensorflow_wheel.subprocess.run",
                return_value=invalid_result,
            ):
                with self.assertRaises(RuntimeError):
                    verify_wheel(str(wheel), "cuobjdump")


if __name__ == "__main__":
    unittest.main()
