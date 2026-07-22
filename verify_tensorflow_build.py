"""Verify provenance metadata for the source-built Blackwell TensorFlow wheel."""

import sys

import tensorflow as tf

from blackwell_support import validate_tensorflow_build


def main():
    build_info = tf.sysconfig.get_build_info()
    print("TensorFlow:", tf.__version__)
    print("TensorFlow build:", build_info)

    try:
        if not tf.__version__.startswith("2.21.0+dflsm120"):
            raise RuntimeError(
                "Expected the pinned DFL SM 12.0 wheel, found TensorFlow %s."
                % tf.__version__
            )
        capabilities = validate_tensorflow_build(build_info)
    except RuntimeError as error:
        print("ERROR:", error, file=sys.stderr)
        return 1

    print("Native CUDA architectures:", ", ".join(sorted(capabilities)))
    print("TensorFlow Blackwell build metadata verification passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
