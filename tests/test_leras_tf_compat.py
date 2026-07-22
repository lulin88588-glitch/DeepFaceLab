import unittest
import tempfile
from pathlib import Path

import cv2
import numpy as np

from core import imagelib
from core.leras import nn
from facelib import FaceType, LandmarksProcessor
from samplelib import Sample, SampleProcessor, SampleType


class LerasTensorFlowCompatibilityTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        nn.initialize_main_env()
        nn.initialize(nn.DeviceConfig.CPU())

    @classmethod
    def tearDownClass(cls):
        nn.close_session()

    def test_conv_optimizer_and_xseg(self):
        x = nn.tf.placeholder(nn.tf.float32, (1, 16, 16, 3))
        layer = nn.Conv2D(3, 8, kernel_size=3)
        layer.build_weights()
        y = layer(x)
        nn.init_weights(layer.get_weights())
        result = nn.tf_sess.run(
            y, {x: np.ones((1, 16, 16, 3), dtype=np.float32)}
        )
        self.assertEqual(result.shape, (1, 16, 16, 8))
        self.assertTrue(np.isfinite(result).all())

        train_var = nn.tf.get_variable(
            "optimizer_probe", (), initializer=nn.tf.constant_initializer(2.0)
        )
        loss = nn.tf.square(train_var)
        optimizer = nn.AdaBelief(lr=0.1, name="optimizer_probe")
        grads = nn.tf.gradients(loss, [train_var])
        optimizer.initialize_variables([train_var])
        update_op = optimizer.get_update_op(list(zip(grads, [train_var])))
        nn.tf_sess.run(nn.tf.variables_initializer([train_var] + optimizer.get_weights()))
        before = nn.tf_sess.run(train_var)
        nn.tf_sess.run(update_op)
        after = nn.tf_sess.run(train_var)
        self.assertLess(after, before)

        xseg_input = nn.tf.placeholder(nn.tf.float32, (1, 256, 256, 3))
        xseg = nn.XSeg(3, 2, 1, name="xseg_probe")
        logits, mask = xseg(xseg_input)
        nn.tf_sess.run(nn.tf.variables_initializer(xseg.get_weights()))
        logits_value, mask_value = nn.tf_sess.run(
            [logits, mask],
            {xseg_input: np.ones((1, 256, 256, 3), dtype=np.float32)},
        )
        self.assertEqual(logits_value.shape, (1, 256, 256, 1))
        self.assertTrue(np.isfinite(mask_value).all())

        # Exercise the Encoder/Inter/Decoder path used by SAEHD.
        sae_input = nn.tf.placeholder(nn.tf.float32, (1, 64, 64, 3))
        archi = nn.DeepFakeArchi(64)
        encoder = archi.Encoder(3, 4, name="saehd_encoder_probe")
        encoder_out_ch = encoder.get_out_ch()
        encoder_out_res = encoder.get_out_res(64)
        inter = archi.Inter(
            encoder_out_res * encoder_out_res * encoder_out_ch,
            32,
            8,
            name="saehd_inter_probe",
        )
        decoder = archi.Decoder(
            inter.get_out_ch(), 4, 2, name="saehd_decoder_probe"
        )
        code = encoder(sae_input)
        latent = inter(code)
        face, face_mask = decoder(latent)
        sae_weights = encoder.get_weights() + inter.get_weights() + decoder.get_weights()
        nn.tf_sess.run(nn.tf.variables_initializer(sae_weights))
        face_value, face_mask_value = nn.tf_sess.run(
            [face, face_mask],
            {sae_input: np.ones((1, 64, 64, 3), dtype=np.float32)},
        )
        self.assertEqual(face_value.shape, (1, 64, 64, 3))
        self.assertEqual(face_mask_value.shape, (1, 64, 64, 1))
        self.assertTrue(np.isfinite(face_value).all())

        with tempfile.TemporaryDirectory() as temp_dir:
            weights_path = Path(temp_dir) / "encoder.npy"
            original_weights = encoder.get_weights_np()
            encoder.save_weights(weights_path)
            encoder.set_weights([np.zeros_like(value) for value in original_weights])
            self.assertTrue(encoder.load_weights(weights_path))
            restored_weights = encoder.get_weights_np()
            for original, restored in zip(original_weights, restored_weights):
                np.testing.assert_array_equal(original, restored)

    def test_tf2onnx_graph_export(self):
        import tf2onnx

        graph = nn.tf.Graph()
        with graph.as_default():
            export_input = nn.tf.placeholder(
                nn.tf.float32, (None, 4), name="export_input"
            )
            nn.tf.identity(export_input * 2.0, name="export_output")
            with nn.tf.Session(graph=graph) as session:
                graph_def = nn.tf.graph_util.convert_variables_to_constants(
                    session, graph.as_graph_def(), ["export_output"]
                )

        model_proto, _ = tf2onnx.convert._convert_common(
            graph_def,
            name="dfl_export_probe",
            input_names=["export_input:0"],
            output_names=["export_output:0"],
            opset=12,
        )
        self.assertEqual(model_proto.graph.input[0].name, "export_input:0")
        self.assertEqual(model_proto.graph.output[0].name, "export_output:0")

    def test_sample_processing_pipeline(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            image_path = Path(temp_dir) / "sample.png"
            gradient = np.linspace(0, 255, 96, dtype=np.uint8)
            image = np.repeat(gradient[None, :, None], 96, axis=0)
            image = np.repeat(image, 3, axis=2)
            self.assertTrue(cv2.imwrite(str(image_path), image))

            sample = Sample(
                sample_type=SampleType.FACE,
                filename=str(image_path),
                face_type=FaceType.FULL,
                shape=image.shape,
                landmarks=np.full((68, 2), 48, dtype=np.float32),
            )
            processed = SampleProcessor.process(
                [sample],
                SampleProcessor.Options(random_flip=False),
                [
                    {
                        "sample_type": SampleProcessor.SampleType.FACE_IMAGE,
                        "channel_type": SampleProcessor.ChannelType.BGR,
                        "face_type": FaceType.FULL,
                        "resolution": 64,
                        "warp": True,
                        "transform": True,
                    }
                ],
                debug=False,
            )
            output = processed[0][0]
            self.assertEqual(output.shape, (64, 64, 3))
            self.assertEqual(output.dtype, np.float32)
            self.assertTrue(np.isfinite(output).all())
            self.assertGreaterEqual(output.min(), 0.0)
            self.assertLessEqual(output.max(), 1.0)

    def test_legacy_numpy_resolution_with_modern_opencv(self):
        params = imagelib.gen_warp_params(
            np.int64(224),
            rnd_state=np.random.RandomState(5090),
            warp_rnd_state=np.random.RandomState(5090),
        )
        self.assertEqual(params["w"], 224)
        self.assertEqual(params["rmat"].shape, (2, 3))
        self.assertTrue(np.isfinite(params["rmat"]).all())

    def test_legacy_float64_landmarks_with_modern_opencv(self):
        landmarks = np.random.RandomState(5090).uniform(32, 224, (68, 2))
        image_shape = (256, 256, 3)
        masks = (
            LandmarksProcessor.get_image_hull_mask(image_shape, landmarks),
            LandmarksProcessor.get_image_eye_mask(image_shape, landmarks),
            LandmarksProcessor.get_image_mouth_mask(image_shape, landmarks),
        )
        for mask in masks:
            self.assertEqual(mask.shape, (256, 256, 1))
            self.assertEqual(mask.dtype, np.float32)
            self.assertTrue(np.isfinite(mask).all())


if __name__ == "__main__":
    unittest.main()
