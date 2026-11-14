#!/usr/bin/env python3
"""vfs495 capture: drive HP's validity-sensor (which holds the sensor's secure session)
under gdb and harvest its motion-compensated assembled fingerprint. Output: PGM.
Usage: vfs495-capture OUT.pgm     (root)     env: VFS_TIMEOUT (s, default 75)"""
import os
import struct
import subprocess  # nosec B404
import sys
import tempfile
from pathlib import Path

HP = "/var/lib/vfs495-fprint"          # HP binary + shim libs (installed by setup-hp-driver.sh)
LIB = "/usr/lib/vfs495-fprint"
OUTPUT_ROOT = Path("/run/vfs495-fprint")


def output_path(value):
    """Return a .pgm path that stays inside the vfs495 runtime directory."""
    root = OUTPUT_ROOT.expanduser().resolve()
    path = Path(value).expanduser().resolve()
    if path.suffix != ".pgm" or not path.is_relative_to(root):
        sys.exit(f"output must be a .pgm file below {root}")
    return path


def main():
    if len(sys.argv) < 2: sys.exit("usage: vfs495-capture OUT.pgm")
    out = output_path(sys.argv[1])
    binp = HP + "/validity-sensor-unlocked"
    if not os.path.exists(binp):
        sys.exit("HP driver not installed. Run: sudo vfs495-setup-hp-driver")
    descriptor, asm = tempfile.mkstemp(dir=out.parent, suffix=".bin")
    os.close(descriptor)
    env = {**os.environ, "LD_LIBRARY_PATH": HP + "/lib", "VFS_ASM_OUT": asm}
    try:
        subprocess.run(["gdb", "-q", "-batch", "-x", LIB + "/harvest_assembled.py",  # nosec B603, B607
                        "--args", binp, "getprintwait", "-doinit"],
                       check=False, env=env, timeout=int(os.environ.get("VFS_TIMEOUT", "75")),
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except subprocess.TimeoutExpired:
        subprocess.run(["pkill", "-9", "-f", "validity-sensor-unlocked"], check=False, stderr=subprocess.DEVNULL)  # nosec B603, B607
    try:
        with open(asm, "rb") as handle:
            data = handle.read()
    finally:
        try: os.unlink(asm)
        except OSError: pass
    if len(data) < 16:
        print("no finger captured", file=sys.stderr); return 10
    w, h = struct.unpack("<II", data[:8]); px = data[8:8 + w * h]
    with out.open("wb") as pgm_file:
        pgm_file.write(f"P5\n{w} {h}\n255\n".encode())
        pgm_file.write(px)
    print(f"captured {w}x{h} -> {out}"); return 0
if __name__ == "__main__": sys.exit(main())
