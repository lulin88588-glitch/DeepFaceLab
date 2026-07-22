#!/usr/bin/env bash
set -euo pipefail

site_packages="$(python -c 'import site; print(site.getsitepackages()[0])')"
cuda_library_path="$(
  find "${site_packages}/nvidia" -type d -name lib -print 2>/dev/null \
    | paste -sd: - || true
)"

if [[ -n "${cuda_library_path}" ]]; then
  export LD_LIBRARY_PATH="${cuda_library_path}${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
fi

exec python "$@"
