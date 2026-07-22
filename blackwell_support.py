"""Shared validation helpers for native NVIDIA Blackwell support."""

import re


def parse_cuda_version(value):
    """Return a ``(major, minor)`` tuple for TensorFlow CUDA version strings."""
    value = str(value)
    match = re.search(r"(\d+)\.(\d+)", value)
    if match:
        return tuple(map(int, match.groups()))

    # Old native-Windows TensorFlow builds report values such as ``64_112``.
    windows_match = re.fullmatch(r"64_(\d{2,3})", value)
    if windows_match:
        digits = windows_match.group(1)
        return int(digits[:-1]), int(digits[-1])
    return None


def parse_compute_capability(value):
    """Normalize TensorFlow compute-capability values to ``(major, minor)``."""
    if isinstance(value, (tuple, list)) and len(value) >= 2:
        return int(value[0]), int(value[1])

    text = str(value).strip().lower()
    dotted_match = re.search(r"(\d+)\.(\d+)", text)
    if dotted_match:
        return tuple(map(int, dotted_match.groups()))

    architecture_match = re.search(r"(?:sm|compute)_?(\d{2,3})", text)
    if architecture_match:
        digits = architecture_match.group(1)
        return int(digits[:-1]), int(digits[-1])
    return None


def get_cuda_capability_tokens(build_info):
    """Return exact ``sm_*``/``compute_*`` tokens reported by TensorFlow."""
    raw_capabilities = build_info.get("cuda_compute_capabilities", ())
    if isinstance(raw_capabilities, (str, bytes)):
        values = [raw_capabilities]
    else:
        values = raw_capabilities or ()

    tokens = set()
    for value in values:
        tokens.update(
            re.findall(r"(?:sm|compute)_\d+", str(value).lower())
        )
    return tokens


def validate_tensorflow_build(build_info):
    """Require a CUDA 12.8+ TensorFlow build containing native SM 12.0 SASS."""
    is_cuda_build = build_info.get("is_cuda_build")
    if str(is_cuda_build).lower() not in ("1", "true"):
        raise RuntimeError("TensorFlow is not a CUDA build.")

    cuda_version = str(build_info.get("cuda_version", ""))
    parsed_cuda_version = parse_cuda_version(cuda_version)
    if parsed_cuda_version is None or parsed_cuda_version < (12, 8):
        raise RuntimeError(
            "CUDA 12.8+ is required; TensorFlow reports %r." % cuda_version
        )

    capabilities = get_cuda_capability_tokens(build_info)
    if "sm_120" not in capabilities:
        raise RuntimeError(
            "TensorFlow lacks native SM 12.0 kernels; reported capabilities: %s"
            % (", ".join(sorted(capabilities)) or "<none>")
        )
    return capabilities


def validate_blackwell_device(device_details):
    """Require an SM 12.0-or-newer GPU and return its normalized capability."""
    compute_capability = parse_compute_capability(
        device_details.get("compute_capability")
    )
    if compute_capability is None or compute_capability < (12, 0):
        raise RuntimeError(
            "Selected GPU is not an RTX 50-series / SM 12.0 device; "
            "TensorFlow reports %r."
            % device_details.get("compute_capability")
        )
    return compute_capability
