"""Run a small but real DeepFaceLab forward/backward training step on GPU 0."""

import os
import sys

import numpy as np

from core.leras import nn
from core.leras.device import Devices
from blackwell_support import (
    validate_blackwell_device,
    validate_tensorflow_build,
)


def _check_native_blackwell(tensorflow, device):
    physical_gpus = tensorflow.config.list_physical_devices("GPU")
    details = tensorflow.config.experimental.get_device_details(
        physical_gpus[device.index]
    )
    build_info = tensorflow.sysconfig.get_build_info()
    print("TensorFlow:", tensorflow.__version__)
    print("Selected GPU:", device)
    print("Device details:", details)
    print("TensorFlow build:", build_info)

    validate_blackwell_device(details)

    if os.environ.get("DFL_REQUIRE_NATIVE_BLACKWELL") == "1":
        validate_tensorflow_build(build_info)


def main():
    nn.initialize_main_env()
    devices = Devices.getDevices()
    if len(devices) == 0:
        print("ERROR: TensorFlow did not detect a GPU.", file=sys.stderr)
        return 1

    device = devices[0]
    nn.initialize(nn.DeviceConfig.GPUIndexes([device.index]))

    import tensorflow

    try:
        _check_native_blackwell(tensorflow, device)

        resolution = 64
        with nn.tf.device("/GPU:0"):
            input_face = nn.tf.placeholder(
                nn.tf.float32, (1, resolution, resolution, 3), name="input_face"
            )
            target_face = nn.tf.placeholder(
                nn.tf.float32, (1, resolution, resolution, 3), name="target_face"
            )
            target_mask = nn.tf.placeholder(
                nn.tf.float32, (1, resolution, resolution, 1), name="target_mask"
            )

            archi = nn.DeepFakeArchi(resolution)
            encoder = archi.Encoder(3, 4, name="verify_encoder")
            encoded_res = encoder.get_out_res(resolution)
            encoded_ch = encoder.get_out_ch()
            inter = archi.Inter(
                encoded_res * encoded_res * encoded_ch,
                32,
                8,
                name="verify_inter",
            )
            decoder = archi.Decoder(8, 4, 2, name="verify_decoder")

            code = encoder(input_face)
            latent = inter(code)
            predicted_face, predicted_mask = decoder(latent)
            loss = nn.tf.reduce_mean(nn.tf.square(predicted_face - target_face))
            loss += nn.tf.reduce_mean(nn.tf.square(predicted_mask - target_mask))

        weights = encoder.get_weights() + inter.get_weights() + decoder.get_weights()
        optimizer = nn.AdaBelief(lr=5e-5, name="verify_optimizer")
        grads_vars = nn.gradients(loss, weights)
        optimizer.initialize_variables(weights, vars_on_cpu=True)
        train_op = optimizer.get_update_op(grads_vars)

        nn.init_weights(weights)
        nn.tf_sess.run(nn.tf.variables_initializer(optimizer.get_weights()))

        rng = np.random.RandomState(5090)
        input_value = rng.rand(1, resolution, resolution, 3).astype(np.float32)
        feed = {
            input_face: input_value,
            target_face: np.zeros_like(input_value),
            target_mask: np.zeros((1, resolution, resolution, 1), dtype=np.float32),
        }
        weight_before = nn.tf_sess.run(weights[0]).copy()
        loss_before = float(nn.tf_sess.run(loss, feed))
        nn.tf_sess.run(train_op, feed)
        loss_after = float(nn.tf_sess.run(loss, feed))
        weight_after = nn.tf_sess.run(weights[0])

        print("Predicted face device:", predicted_face.device)
        print("Loss before:", loss_before)
        print("Loss after one step:", loss_after)
        print("First weight changed:", not np.array_equal(weight_before, weight_after))

        if "GPU:0" not in predicted_face.device.upper():
            raise RuntimeError("SAEHD graph was not placed on GPU 0.")
        if not np.isfinite([loss_before, loss_after]).all():
            raise RuntimeError("Training produced a non-finite loss.")
        if np.array_equal(weight_before, weight_after):
            raise RuntimeError("AdaBelief did not update the SAEHD weights.")

        print("DeepFaceLab Blackwell training verification passed.")
        return 0
    except Exception as error:
        print("ERROR:", error, file=sys.stderr)
        return 1
    finally:
        nn.close_session()


if __name__ == "__main__":
    sys.exit(main())
