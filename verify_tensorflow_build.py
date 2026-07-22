"""Verify provenance metadata for the pinned Blackwell TensorFlow wheel."""

from importlib import metadata
from pathlib import Path
import sys

import tensorflow as tf

from blackwell_support import validate_tensorflow_build


def _locked_cuda_packages():
    requirements = Path(__file__).with_name("requirements-blackwell-cuda.txt")
    packages = {}
    for line in requirements.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        if line.count("==") != 1:
            raise RuntimeError("CUDA runtime dependency is not exactly pinned: %s" % line)
        package, version = line.split("==")
        packages[package] = version
    if not packages:
        raise RuntimeError("CUDA runtime requirements file is empty.")
    return packages


def main():
    build_info = tf.sysconfig.get_build_info()
    print("TensorFlow:", tf.__version__)
    print("TensorFlow build:", build_info)

    try:
        if tf.__version__ != "2.21.0+selfbuild":
            raise RuntimeError(
                "Expected the pinned DFL SM 12.0 wheel, found TensorFlow %s."
                % tf.__version__
            )
        capabilities = validate_tensorflow_build(build_info)
        expected_cuda_packages = _locked_cuda_packages()
        installed_cuda_packages = {
            package: metadata.version(package)
            for package in expected_cuda_packages
        }
        if installed_cuda_packages != expected_cuda_packages:
            raise RuntimeError(
                "CUDA runtime package drift detected: %s"
                % installed_cuda_packages
            )
    except (RuntimeError, metadata.PackageNotFoundError) as error:
        print("ERROR:", error, file=sys.stderr)
        return 1

    print("Native CUDA architectures:", ", ".join(sorted(capabilities)))
    print("Pinned CUDA runtime packages:", installed_cuda_packages)
    print("TensorFlow Blackwell build metadata verification passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
