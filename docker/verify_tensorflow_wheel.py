"""Use NVIDIA cuobjdump to prove that a TensorFlow wheel contains SM 12.0 SASS."""

import argparse
import os
import re
import shutil
import subprocess
import tempfile
import zipfile


def _shared_libraries(wheel):
    with zipfile.ZipFile(wheel) as archive:
        names = [
            name
            for name in archive.namelist()
            if name.endswith(".so") or ".so." in os.path.basename(name)
        ]
    return sorted(
        names,
        key=lambda name: (
            "_pywrap_tensorflow_internal" not in name,
            "libtensorflow_cc" not in name,
            name,
        ),
    )


def verify_wheel(wheel, cuobjdump):
    candidates = _shared_libraries(wheel)
    if not candidates:
        raise RuntimeError("TensorFlow wheel contains no ELF shared libraries.")

    with zipfile.ZipFile(wheel) as archive, tempfile.TemporaryDirectory() as temp_dir:
        for index, member in enumerate(candidates):
            extracted = os.path.join(temp_dir, "candidate-%04d.so" % index)
            with archive.open(member) as source, open(extracted, "wb") as target:
                shutil.copyfileobj(source, target)
            result = subprocess.run(
                [cuobjdump, "--list-elf", extracted],
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                universal_newlines=True,
            )
            if re.search(r"(?<!\d)sm_120(?!\d)", result.stdout.lower()):
                print("Found native SM 12.0 cubin in:", member)
                return

    raise RuntimeError(
        "cuobjdump found no native SM 12.0 cubin in %d shared libraries."
        % len(candidates)
    )


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("wheel")
    parser.add_argument(
        "--cuobjdump", default="/usr/local/cuda/bin/cuobjdump"
    )
    args = parser.parse_args()

    if not os.path.isfile(args.wheel):
        parser.error("wheel does not exist: %s" % args.wheel)
    if not os.path.isfile(args.cuobjdump):
        parser.error("cuobjdump does not exist: %s" % args.cuobjdump)

    verify_wheel(args.wheel, args.cuobjdump)
    print("TensorFlow wheel native-cubin verification passed.")


if __name__ == "__main__":
    main()
