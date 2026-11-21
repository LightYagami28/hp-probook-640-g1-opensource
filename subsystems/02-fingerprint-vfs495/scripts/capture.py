#!/usr/bin/env python3
"""Capture one fingerprint swipe through HP's validity-sensor driver.

The driver holds the sensor's secure session, so it is driven under gdb and its
motion-compensated assembled fingerprint is harvested. Output: PGM.

Usage: vfs495-capture OUT.pgm     (root)     env: VFS_TIMEOUT (s, default 75)
"""

import os
import struct
import sys
import tempfile
from pathlib import Path

from exec_command import CommandTimeout, execute

HP = "/var/lib/vfs495-fprint"  # HP binary + shim libs (installed by setup-hp-driver.sh)
LIB = "/usr/lib/vfs495-fprint"
OUTPUT_ROOT = Path("/run/vfs495-fprint")


def output_path(value):
    """Return a .pgm path that stays inside the vfs495 runtime directory."""
    root = OUTPUT_ROOT.expanduser().resolve()
    path = Path(value).expanduser().resolve()
    if path.suffix != ".pgm" or not path.is_relative_to(root):
        sys.exit(f"output must be a .pgm file below {root}")
    return path


def run_driver(binp, asm):
    """Run the HP driver under gdb, killing the sensor helper when it times out."""
    env = {**os.environ, "LD_LIBRARY_PATH": HP + "/lib", "VFS_ASM_OUT": asm}
    timeout = int(os.environ.get("VFS_TIMEOUT", "75"))
    try:
        execute(
            [
                "/usr/bin/gdb",
                "-q",
                "-batch",
                "-x",
                LIB + "/harvest_assembled.py",
                "--args",
                binp,
                "getprintwait",
                "-doinit",
            ],
            env=env,
            timeout=timeout,
        )
    except CommandTimeout:
        execute(["/usr/bin/pkill", "-9", "-f", "validity-sensor-unlocked"])


def take_harvest(asm):
    """Return the harvested bytes and remove the temporary file."""
    try:
        with open(asm, "rb") as handle:
            return handle.read()
    finally:
        try:
            os.unlink(asm)
        except OSError as error:
            print(f"cannot remove {asm}: {error}", file=sys.stderr)


def write_pgm(out, data):
    """Write the harvested image as a binary PGM and return its size."""
    width, height = struct.unpack("<II", data[:8])
    with out.open("wb") as pgm_file:
        pgm_file.write(f"P5\n{width} {height}\n255\n".encode())
        pgm_file.write(data[8 : 8 + width * height])
    return width, height


def main():
    """Capture one swipe through the HP driver and write it as a PGM."""
    if len(sys.argv) < 2:
        sys.exit("usage: vfs495-capture OUT.pgm")
    out = output_path(sys.argv[1])
    binp = HP + "/validity-sensor-unlocked"
    if not os.path.exists(binp):
        sys.exit("HP driver not installed. Run: sudo vfs495-setup-hp-driver")
    descriptor, asm = tempfile.mkstemp(dir=out.parent, suffix=".bin")
    os.close(descriptor)
    run_driver(binp, asm)
    data = take_harvest(asm)
    if len(data) < 16:
        print("no finger captured", file=sys.stderr)
        return 10
    width, height = write_pgm(out, data)
    print(f"captured {width}x{height} -> {out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
