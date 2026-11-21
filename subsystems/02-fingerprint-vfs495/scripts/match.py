#!/usr/bin/env python3
"""
Offline fingerprint match scoring with the libfprint matcher that fprintd uses.

  vfs495-match IMG1.pgm IMG2.pgm [IMG3.pgm ...]   score every image against every other
  vfs495-match --template FILE IMG.pgm [...]       score images against an fprintd template
                                                    (e.g. /var/lib/fprint/<user>/virtual_image/0/7)
  sudo vfs495-match --capture N [DIR]             capture N swipes from the sensor into DIR
                                                    (default /run/vfs495-fprint/test), then score them
                                                    against each other and against your enrolled finger
  sudo vfs495-match --enroll IMG.pgm [...]        enroll the given scans (e.g. the ones --capture just
                                                    took) as your right index finger in fprintd

Scores are libfprint/NBIS bozorth3 scores. fprintd accepts a swipe when the score against any
enrolled sub-template is >= 40. Genuine swipes of the same finger typically score 40-150,
different fingers < 15. No sensor is touched unless --capture is used.
"""

import glob
import importlib
import os
import re
import socket
import stat
import struct
import subprocess
import sys
import tempfile
import threading
from pathlib import Path

THRESHOLD = 40
MIN_ROWS = 80
CAPTURE_ROOT = Path("/run/vfs495-fprint").resolve()

# --- must happen before libfprint is loaded: private socket + score debug output ---
_tmp = tempfile.mkdtemp(prefix="vfs495-match-")
SOCK = _tmp + "/sock"
os.environ["FP_VIRTUAL_IMAGE"] = SOCK
os.environ["G_MESSAGES_DEBUG"] = "libfprint-print"
# glib prints DEBUG-level messages on stdout: capture fd 1, keep a copy for our own output
_orig_stdout = os.dup(1)
_r, _w = os.pipe()
os.dup2(_w, 1)
os.close(_w)
_lines = []


def _reader():
    """Collect the libfprint debug lines written to the captured stdout."""
    with os.fdopen(_r, "rb", 0) as stream:
        for line in stream:
            _lines.append(line.decode(errors="replace"))


threading.Thread(target=_reader, daemon=True).start()


def err(msg):
    """Write a message to stderr."""
    sys.stderr.write(msg + "\n")
    sys.stderr.flush()


def out(msg):
    """Write a message to the original stdout."""
    os.write(_orig_stdout, (msg + "\n").encode())


gi = importlib.import_module("gi")
gi.require_version("FPrint", "2.0")
_repository = importlib.import_module("gi.repository")
FPrint, Gio, GLib = _repository.FPrint, _repository.Gio, _repository.GLib


def input_path(name):
    """Return the resolved path of an existing regular file."""
    path = Path(name).expanduser().resolve(strict=True)
    if not path.is_file():
        raise SystemExit(f"{name}: not a regular file")
    return path


def read_input(name):
    """Return the bytes of an input file."""
    return input_path(name).read_bytes()


def read_pgm(name):
    """Read a binary PGM file and return (width, height, pixels)."""
    with input_path(name).open("rb") as handle:
        if handle.readline().strip() != b"P5":
            raise SystemExit(f"{name}: not a binary PGM (P5)")
        tok = []
        while len(tok) < 3:
            line = handle.readline()
            if line.startswith(b"#"):
                continue
            tok += line.split()
        width, height = int(tok[0]), int(tok[1])
        return width, height, handle.read(width * height)


CONN: list[socket.socket] = []


def pause(seconds):
    """Wait for the given number of seconds."""
    threading.Event().wait(seconds)


def send_image(img, delay=0.3):
    """Feed one image to the in-process virtual_image device.

    The image is sent from a helper thread over one persistent connection, so the driver
    never sees a hang-up mid-operation.
    """
    width, height, data = img

    def run():
        pause(delay)
        for _ in range(50):
            try:
                if not CONN:
                    CONN.append(socket.socket(socket.AF_UNIX, socket.SOCK_STREAM))
                    CONN[0].connect(SOCK)
                CONN[0].sendall(struct.pack("<ii", width, height) + data)
                return
            except OSError:
                CONN.clear()
                pause(0.1)

    threading.Thread(target=run, daemon=True).start()


def open_device():
    """Open the libfprint virtual_image device."""
    ctx = FPrint.Context()
    ctx.enumerate()
    for device in ctx.get_devices():
        if device.get_driver() == "virtual_image":
            device.open_sync(None)
            return ctx, device
    raise SystemExit(
        "libfprint virtual_image device not available (is libfprint-2-2 installed?)"
    )


def enroll_from_image(dev, img, name):
    """Build a template from one image (fed for each of the 5 enroll stages)."""
    tmpl = FPrint.Print.new(dev)
    tmpl.set_finger(FPrint.Finger.RIGHT_INDEX)
    tmpl.set_username("vfs495-match")
    canc = Gio.Cancellable()
    stage = {"sent": 1}

    def progress(*args):
        if stage["sent"] >= 8:
            canc.cancel()
            return  # image keeps failing minutiae extraction
        if args[1] < dev.get_nr_enroll_stages():
            stage["sent"] += 1
            send_image(img, 0.2)

    send_image(img)
    try:
        return dev.enroll_sync(tmpl, canc, progress, None)
    except GLib.Error as err_gl:
        err(f"  enroll from {name} failed: {err_gl.message}")
        return None


def enroll_from_images(dev, imgs, user):
    """Build a template from several images, cycling through them for the 5 enroll stages."""
    tmpl = FPrint.Print.new(dev)
    tmpl.set_finger(FPrint.Finger.RIGHT_INDEX)
    tmpl.set_username(user)
    canc = Gio.Cancellable()
    stage = {"sent": 1}

    def progress(*args):
        if stage["sent"] >= 12:
            canc.cancel()
            return
        if args[1] < dev.get_nr_enroll_stages():
            send_image(imgs[stage["sent"] % len(imgs)], 0.2)
            stage["sent"] += 1

    send_image(imgs[0])
    try:
        return dev.enroll_sync(tmpl, canc, progress, None)
    except GLib.Error as err_gl:
        raise SystemExit(f"enroll failed: {err_gl.message}") from err_gl


def write_template(user, data):
    """Store the serialized template in fprintd's private directory and return its path."""
    base = f"/var/lib/fprint/{user}/virtual_image/0"
    os.makedirs(base, mode=stat.S_IRWXU, exist_ok=True)
    for entry in (
        "/var/lib/fprint",
        f"/var/lib/fprint/{user}",
        f"/var/lib/fprint/{user}/virtual_image",
        base,
    ):
        os.chmod(entry, stat.S_IRWXU)
    path = base + "/7"  # 7 = right index finger in fprintd's file store
    if os.path.exists(path):
        os.replace(path, path + ".bak")
    with open(path, "wb") as handle:
        handle.write(data)
    os.chmod(path, 0o600)
    return path


def check_template(dev, print_, files, imgs):
    """Verify the new template against the scans it was built from."""
    out("check of the new template against those scans:")
    for name in files:
        matched, score = verify(dev, print_, imgs[name], name)
        out(f"  {os.path.basename(name):<20} {fmt(matched, score)}")


def install_template(dev, files, imgs):
    """Enroll the scans and install the template in the fprintd store."""
    if os.geteuid():
        raise SystemExit("--enroll needs root: sudo vfs495-match --enroll IMG...")
    user = os.environ.get("SUDO_USER") or "root"
    print_ = enroll_from_images(dev, [imgs[name] for name in files], user)
    path = write_template(user, bytes(print_.serialize()))
    out(f"enrolled right index finger for {user} from {len(files)} scan(s) -> {path}")
    check_template(dev, print_, files, imgs)
    subprocess.run(
        ["/usr/bin/systemctl", "restart", "fprintd"],
        check=False,
        stderr=subprocess.DEVNULL,
    )
    out("\nnow test:  fprintd-verify   (wait ~2 s after the prompt, then swipe)")


def best_score(lines):
    """Return the highest bozorth3 score found in the libfprint debug lines, or -1."""
    hits = (re.search(r"score (-?\d+)/(\d+)", text) for text in lines)
    return max((int(hit.group(1)) for hit in hits if hit), default=-1)


def verify(dev, template, img, name):
    """Returns (matched, best_score)."""
    del _lines[:]
    send_image(img)
    try:
        res = dev.verify_sync(template, None, None, None)
    except GLib.Error as err_gl:
        err(f"  verify {name}: {err_gl.message}")
        return False, -1
    matched = bool(res[0] if isinstance(res, tuple) else res)
    pause(0.05)
    return matched, best_score(_lines)


def fmt(matched, score):
    """Format a score line."""
    tag = "MATCH" if matched else "no match"
    return f"{score:4d}/{THRESHOLD}  {tag}"


STUCK_MESSAGE = (
    "\nEvery scan was tiny. If you did swipe slowly, the sensor is in its stuck state:"
    " it returns a few\nlines and never waits for a finger. Only a FULL POWER-OFF"
    " (shut down, wait 10 s, power on) clears it;\na warm reboot does not."
)


def capture_swipe(label, swipe):
    """Capture one swipe; return its height, or None if missed."""
    out(f"{label} get ready... ")
    pause(1.0)
    out(f"{label} SWIPE NOW (slowly, whole fingertip, one steady motion)")
    cmd = ["/usr/bin/python3", "/usr/lib/vfs495-fprint/capture.py", os.fspath(swipe)]
    result = subprocess.run(
        cmd, check=False, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
    )
    if result.returncode:
        out(f"{label} nothing captured (missed the swipe?)")
        return None
    width, height, _ = read_pgm(swipe)
    if height < MIN_ROWS:
        swipe.unlink()
    out(f"{label} {width}x{height} scan, {swipe}")
    return height


def capture_directory(target):
    """Check the preconditions of --capture and return the target directory."""
    if os.geteuid():
        raise SystemExit("--capture needs root: sudo vfs495-match --capture N")
    if not os.path.exists("/var/lib/vfs495-fprint/validity-sensor-unlocked"):
        raise SystemExit("HP driver not installed; run: sudo vfs495-setup-hp-driver")
    directory = Path(target).expanduser().resolve()
    if not directory.is_relative_to(CAPTURE_ROOT):
        raise SystemExit(f"capture directory must be below {CAPTURE_ROOT}")
    return directory


def set_bridge(action):
    """Start or stop the vfs495-bridge service."""
    subprocess.run(
        ["/usr/bin/systemctl", action, "vfs495-bridge"],
        check=False,
        stderr=subprocess.DEVNULL,
    )


def warn_tiny(heights):
    """Explain the stuck sensor state when every scan was tiny."""
    if any(heights.values()):
        out(STUCK_MESSAGE)


def usable_swipes(heights):
    """Return the swipes tall enough to score, warning when all of them were tiny."""
    files = [path for path, rows in heights.items() if (rows or 0) >= MIN_ROWS]
    if not files:
        warn_tiny(heights)
    return files


def capture(count, target):
    """Capture count swipes from the sensor into directory target."""
    directory = capture_directory(target)
    set_bridge("stop")
    directory.mkdir(mode=stat.S_IRWXU, parents=True, exist_ok=True)
    heights = {}
    try:
        for i in range(1, count + 1):
            swipe = directory / f"swipe-{i}.pgm"
            heights[swipe] = capture_swipe(f"[{i}/{count}]", swipe)
            pause(1.5)
    finally:
        set_bridge("start")
    return usable_swipes(heights)


def find_templates():
    """List the fprintd templates of the current user."""
    user = os.environ.get("SUDO_USER") or os.environ.get("USER") or "*"
    return sorted(glob.glob(f"/var/lib/fprint/{user}/virtual_image/0/*"))


def capture_args(args):
    """Run --capture with its optional count and directory and return the scans."""
    count = int(args[1]) if len(args) > 1 else 3
    target = args[2] if len(args) > 2 else "/run/vfs495-fprint/test"
    files = capture(count, target)
    if not files:
        raise SystemExit("no captures to score")
    out("")
    return files


def parse_args(args):
    """Return (files, template_file, enroll, captured) from the command line."""
    if args[0] == "--capture":
        return capture_args(args), None, False, True
    template_file = None
    if args[0] == "--template":
        template_file, args = args[1], args[2:]
    enroll = bool(args) and args[0] == "--enroll"
    return (args[1:] if enroll else args), template_file, enroll, False


def score_templates(dev, files, imgs, templates):
    """Score every image against every enrolled template."""
    for tpath, tdata in templates:
        try:
            tmpl = FPrint.Print.deserialize(tdata)
        except GLib.Error as err_gl:
            err(f"cannot load template {tpath}: {err_gl.message}")
            continue
        out(
            f"against enrolled template {tpath} ({FPrint.Finger(tmpl.get_finger()).value_nick}):"
        )
        for name in files:
            matched, score = verify(dev, tmpl, imgs[name], name)
            out(f"  {os.path.basename(name):<20} {fmt(matched, score)}")
        out("")


def score_cross(dev, files, imgs):
    """Enroll each image and verify it against all the others."""
    out("each image enrolled, verified with every other image:")
    for first in files:
        tmpl = enroll_from_image(dev, imgs[first], first)
        if tmpl is None:
            continue
        for second in files:
            if first == second:
                continue
            matched, score = verify(dev, tmpl, imgs[second], second)
            out(
                f"  enroll {os.path.basename(first):<16} verify {os.path.basename(second):<16} {fmt(matched, score)}"
            )


def drop_short_scans(files, imgs):
    """Remove the scans too short to be usable."""
    for name in tuple(files):
        if imgs[name][1] < MIN_ROWS:
            err(f"{name}: only {imgs[name][1]} rows, not a usable scan (skipped)")
            files.remove(name)


def load_images(files):
    """Read the scans, drop the unusable ones and return them keyed by file name."""
    if not files:
        raise SystemExit("no images given")
    imgs = {name: read_pgm(name) for name in files}
    drop_short_scans(files, imgs)
    if not files:
        raise SystemExit("no usable images")
    return imgs


def collect_templates(template_file, captured):
    """Return the (path, data) pairs of the templates the scans are scored against."""
    if template_file:
        paths = [template_file]
    else:
        paths = find_templates() if captured else []
    return [(path, read_input(path)) for path in paths]


def finish(dev):
    """Close the persistent connection and the device."""
    for sock in CONN:
        sock.close()
    dev.close_sync(None)


def run_scoring(dev, files, imgs, templates):
    """Score the images against the templates and against each other."""
    score_templates(dev, files, imgs, templates)
    if len(files) >= 2:
        score_cross(dev, files, imgs)


def main(argv):
    """Entry point: return 0 on success, 1 on a user-facing failure."""
    args = argv[1:]
    if not args or args[0] in ("-h", "--help"):
        out(__doc__)
        return 0
    try:
        files, template_file, enroll, captured = parse_args(args)
        imgs = load_images(files)
        _, dev = open_device()
        out(
            f"matcher: libfprint {dev.get_driver()} (NBIS bozorth3), threshold {THRESHOLD}\n"
        )
        if enroll:
            install_template(dev, files, imgs)
        else:
            run_scoring(dev, files, imgs, collect_templates(template_file, captured))
        finish(dev)
    except SystemExit as error:
        # Failures used to escape as SystemExit(message): the interpreter printed the
        # message and exited with status 1. Keep that output and status, but return the
        # failure code from this entry point so success and failure are distinct.
        if error.code:
            err(str(error.code))
        return 1
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main(sys.argv))
    finally:
        try:
            os.unlink(SOCK)
            os.rmdir(_tmp)
        except OSError as error:
            err(f"cleanup failed: {error}")
