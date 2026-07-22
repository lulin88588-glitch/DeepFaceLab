#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
venv_dir="${repo_dir}/.venv-modern"

python3 -m venv "${venv_dir}"
"${venv_dir}/bin/python" -m pip install --upgrade pip setuptools wheel
"${venv_dir}/bin/python" -m pip install -r "${repo_dir}/requirements-modern.txt"
PYTHONPATH="${repo_dir}" "${venv_dir}/bin/python" -m unittest \
  tests.test_blackwell_support tests.test_leras_tf_compat -v
"${venv_dir}/bin/python" "${repo_dir}/main.py" --help
"${venv_dir}/bin/python" -c \
  'import tensorflow as tf; print("Stock-wheel GPUs (informational only):", tf.config.list_physical_devices("GPU"))'

echo "Modern TensorFlow API environment ready: source '${venv_dir}/bin/activate'"
echo "Use the source-built Docker image for verified native SM 12.0 execution."
