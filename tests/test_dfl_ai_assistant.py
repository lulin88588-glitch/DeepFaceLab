import base64
import os
import unittest
from pathlib import Path
from unittest.mock import patch

import dfl_ai_assistant as assistant


def faceset(count, valid_sampled=100):
    return {
        "count": count,
        "valid_sampled": valid_sampled,
        "unreadable": 0,
        "blurry": 0,
        "too_dark": 0,
        "too_bright": 0,
        "duplicate_samples": 0,
        "resolutions": ["512x512"],
    }


class DflAiAssistantTest(unittest.TestCase):
    def test_clean_workspace_decision_allows_training(self):
        decision = assistant._decision_from_issues(94, [])

        self.assertEqual(decision["risk_level"], "ready")
        self.assertTrue(decision["can_train"])
        self.assertIn("开始训练", decision["next_action"])

    def test_workspace_score_flags_severe_imbalance(self):
        issues, score = assistant._workspace_issues(
            faceset(96), faceset(119_507)
        )

        self.assertEqual(score, 68)
        self.assertTrue(
            any(issue["title"] == "SRC 与 DST 数量严重失衡" for issue in issues)
        )
        decision = assistant._decision_from_issues(score, issues)
        self.assertEqual(decision["risk_level"], "blocked")
        self.assertFalse(decision["can_train"])
        self.assertIn("补充", decision["next_action"])

    @patch.object(
        assistant,
        "_gpu_info",
        return_value={
            "name": "NVIDIA GeForce RTX 5090",
            "memory_total_mib": 32607,
            "memory_free_mib": 30000,
            "temperature": 38,
        },
    )
    @patch.object(
        assistant,
        "_parse_model_summaries",
        return_value=[{"name": "existing_SAEHD"}],
    )
    @patch.object(assistant, "workspace_analysis")
    def test_recommendation_is_conservative_for_existing_model(
        self, workspace_analysis, _model_summaries, _gpu_info
    ):
        workspace_analysis.return_value = {
            "score": 68,
            "src": {"count": 96},
            "dst": {"count": 119_507},
            "issues": [
                {
                    "severity": "高",
                    "title": "SRC 与 DST 数量严重失衡",
                    "detail": "测试数据失衡。",
                    "action": "优先补充数量较少的一侧。",
                }
            ],
        }

        result = assistant.recommendation_analysis(
            Path("/workspace"), 20, "SAEHD"
        )

        self.assertEqual(result["resolution"], 256)
        self.assertEqual(result["batch"], "8-12")
        self.assertEqual(result["batch_recommended"], 8)
        self.assertTrue(result["can_apply"])
        self.assertFalse(result["can_train"])
        self.assertEqual(result["risk_level"], "blocked")
        self.assertEqual(
            result["recommended_options"]["base_iterations"], 300_000
        )
        self.assertEqual(result["readiness"], "建议先补充数量较少的一侧")
        self.assertIn("不要直接修改分辨率、架构或维度", result["report"])

    @patch.object(
        assistant, "_preview_analysis", return_value={"exists": False}
    )
    @patch.object(assistant, "_parse_model_summaries", return_value=[])
    @patch.object(assistant, "workspace_analysis")
    def test_training_diagnosis_reports_runtime_error(
        self, workspace_analysis, _model_summaries, _preview
    ):
        workspace_analysis.return_value = {
            "score": 68,
            "issues": [{"severity": "高"}],
        }
        encoded_log = base64.b64encode(
            b"Traceback: ResourceExhaustedError: out of memory"
        ).decode("ascii")

        with patch.dict(
            os.environ,
            {
                "DFL_AI_CONTAINER_STATE": "exited",
                "DFL_AI_LOG_B64": encoded_log,
            },
            clear=False,
        ):
            result = assistant.training_analysis(Path("/workspace"), 20)

        self.assertEqual(result["state"], "exited")
        self.assertEqual(result["health"], "error")
        self.assertTrue(result["next_action"])
        self.assertIn("检测到显存不足", result["log_errors"])
        self.assertIn("最近日志包含 Python 异常", result["log_errors"])
        self.assertIn("先处理最近日志中的异常", result["report"])


if __name__ == "__main__":
    unittest.main()
