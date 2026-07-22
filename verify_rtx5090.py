"""Verify that TensorFlow can execute CUDA work on an RTX 50-series GPU."""

import os
import sys

import numpy as np
import tensorflow as tf

from blackwell_support import (
    validate_blackwell_device,
    validate_tensorflow_build,
)


def main():
    gpus = tf.config.list_physical_devices("GPU")
    print("TensorFlow:", tf.__version__)
    print("GPUs:", gpus)
    if not gpus:
        print("ERROR: TensorFlow did not detect an NVIDIA GPU.", file=sys.stderr)
        return 1

    details = tf.config.experimental.get_device_details(gpus[0])
    print("Device details:", details)
    build_info = tf.sysconfig.get_build_info()
    print("TensorFlow build:", build_info)
    try:
        validate_blackwell_device(details)
        if os.environ.get("DFL_REQUIRE_NATIVE_BLACKWELL") == "1":
            validate_tensorflow_build(build_info)
    except RuntimeError as error:
        print("ERROR:", error, file=sys.stderr)
        return 1

    tf.compat.v1.disable_v2_behavior()
    graph = tf.Graph()
    with graph.as_default():
        with tf.device("/GPU:0"):
            result = tf.matmul(tf.ones((256, 256)), tf.ones((256, 256)))
            conv = tf.nn.conv2d(
                tf.ones((1, 64, 64, 3)),
                tf.ones((3, 3, 3, 8)),
                strides=(1, 1, 1, 1),
                padding="SAME",
            )
        total = tf.reduce_sum(result)

    with tf.compat.v1.Session(graph=graph) as session:
        value, conv_value = session.run([total, conv])

    print("Placed device:", result.device)
    print("GPU smoke-test sum:", float(value))
    if "GPU:0" not in result.device.upper() or float(value) != 16777216.0:
        print("ERROR: GPU smoke test failed.", file=sys.stderr)
        return 1
    if conv_value.shape != (1, 64, 64, 8) or not np.isfinite(conv_value).all():
        print("ERROR: GPU convolution smoke test failed.", file=sys.stderr)
        return 1
    print("RTX 50-series runtime is ready.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
