"""Unit tests for the vfs495 script changes. No sensor or libfprint required."""
import importlib.util
import io
import os
import struct
import sys
import tempfile
import types
from pathlib import Path
from unittest.mock import MagicMock

import pytest

ROOT = Path(__file__).resolve().parents[1]
SCRIPTS = ROOT / "subsystems" / "02-fingerprint-vfs495" / "scripts"
_LOADED = {}


def install_stubs():
    gi = sys.modules.get("gi")
    if gi is None:
        gi = types.ModuleType("gi")
        sys.modules["gi"] = gi
    repository = sys.modules.get("gi.repository")
    if repository is None:
        repository = types.ModuleType("gi.repository")
        sys.modules["gi.repository"] = repository
    gi.repository = repository
    gi.require_version = lambda *args, **kwargs: None
    if not hasattr(repository, "GLib"):
        repository.GLib = MagicMock()
        repository.GLib.Error = type("Error", (Exception,), {})
    if not hasattr(repository, "FPrint"):
        repository.FPrint = MagicMock()
    if not hasattr(repository, "Gio"):
        repository.Gio = MagicMock()
    if "dbus" not in sys.modules:
        dbus = types.ModuleType("dbus")
        mainloop = types.ModuleType("dbus.mainloop")
        glib = types.ModuleType("dbus.mainloop.glib")
        dbus.mainloop = mainloop
        mainloop.glib = glib
        dbus.DBusException = type("DBusException", (Exception,), {})
        sys.modules["dbus"] = dbus
        sys.modules["dbus.mainloop"] = mainloop
        sys.modules["dbus.mainloop.glib"] = glib


def load_script(filename, name):
    if name in _LOADED:
        return _LOADED[name]
    spec = importlib.util.spec_from_file_location(name, SCRIPTS / filename)
    module = importlib.util.module_from_spec(spec)
    sys.modules[name] = module
    spec.loader.exec_module(module)
    _LOADED[name] = module
    return module


def write_pgm(path, width, height):
    path.write_bytes(
        f"P5\n{width} {height}\n255\n".encode() + b"\x10" * (width * height)
    )


def bridge():
    install_stubs()
    return load_script("bridge.py", "vfs495_bridge")


def capture():
    return load_script("capture.py", "vfs495_capture")


def match():
    if "vfs495_match" in _LOADED:
        return _LOADED["vfs495_match"]
    install_stubs()
    saved = os.dup(1)
    try:
        return load_script("match.py", "vfs495_match")
    finally:
        os.dup2(saved, 1)
        os.close(saved)


def harvest():
    if "vfs495_harvest" in _LOADED:
        return _LOADED["vfs495_harvest"]
    gdb = types.ModuleType("gdb")

    class MemoryError(Exception):
        pass

    class Breakpoint:
        def __init__(self, spec):
            self.spec = spec

    gdb.MemoryError = MemoryError
    gdb.Breakpoint = Breakpoint
    gdb.execute = lambda *args, **kwargs: None
    gdb.selected_frame = lambda: None
    gdb.selected_inferior = lambda: None
    sys.modules["gdb"] = gdb
    os.environ["VFS_ASM_OUT"] = str(Path(tempfile.mkdtemp()) / "asm.bin")
    return load_script("harvest_assembled.py", "vfs495_harvest")


class _Frame:
    def read_register(self, name):
        assert name == "rdi"
        return 0x1000


class _Inferior:
    def __init__(self, reads):
        self.reads = list(reads)
        self.index = 0

    def read_memory(self, addr, size):
        item = self.reads[self.index]
        self.index += 1
        if isinstance(item, Exception):
            raise item
        return item


def _stop(module, reads):
    gdb = sys.modules["gdb"]
    gdb.selected_frame = lambda: _Frame()
    gdb.selected_inferior = lambda: _Inferior(reads)
    module.hit["n"] = 0
    out = Path(module.OUT)
    if out.exists():
        out.unlink()
    stopped = module.BP("probe").stop()
    return stopped, out


def test_capture_is_current():
    module = bridge()
    module.state["gen"] = 4
    module.state["wanted"] = True
    assert module.capture_is_current(4) is True
    assert module.capture_is_current(3) is False
    module.state["wanted"] = False
    assert module.capture_is_current(4) is False


def test_deliver_capture_branches(monkeypatch):
    module = bridge()
    logs = []
    monkeypatch.setattr(module, "log", logs.append)
    monkeypatch.setattr(module, "run_capture", lambda out: False)
    assert module.deliver_capture("out", "last", 1, 0) is False

    monkeypatch.setattr(module, "run_capture", lambda out: True)
    module.state["gen"] = 1
    module.state["wanted"] = False
    assert module.deliver_capture("out", "last", 1, 0) is True
    assert any("cancelled" in message for message in logs)

    replaced = []
    monkeypatch.setattr(module.os, "replace", lambda src, dst: replaced.append((src, dst)))
    monkeypatch.setattr(module, "read_pgm", lambda path: (8, 2, b"xx"))
    module.state["wanted"] = True
    module.state["gen"] = 2
    assert module.deliver_capture("cap", "prev", 2, 0) is False
    assert replaced == [("cap", "prev")]

    monkeypatch.setattr(module, "read_pgm", lambda path: (20, 100, b"pixels"))
    monkeypatch.setattr(module, "deliver", lambda *args: None)
    assert module.deliver_capture("cap", "prev", 2, 10) is True
    assert any("delivered scan" in message for message in logs)

    def broken(*args):
        raise OSError("socket down")

    monkeypatch.setattr(module, "deliver", broken)
    assert module.deliver_capture("cap", "prev", 2, 10) is True
    assert any("deliver failed" in message for message in logs)


def test_capture_and_deliver_retries_then_stops(tmp_path, monkeypatch):
    module = bridge()
    monkeypatch.setattr(module, "RUN", str(tmp_path))
    logs = []
    monkeypatch.setattr(module, "log", logs.append)
    calls = {"n": 0}

    def fail(*args):
        calls["n"] += 1
        return False

    monkeypatch.setattr(module, "deliver_capture", fail)
    module.state["capturing"] = True
    module.capture_and_deliver(1)
    assert calls["n"] == 2
    assert any("retrying" in message for message in logs)
    assert any("give up" in message for message in logs)
    assert module.state["capturing"] is False

    calls["n"] = 0
    monkeypatch.setattr(module, "deliver_capture", lambda *args: True)
    module.capture_and_deliver(1)
    assert calls["n"] == 0


def test_output_path_confines_pgm_files(tmp_path, monkeypatch):
    module = capture()
    monkeypatch.setattr(module, "OUTPUT_ROOT", tmp_path)
    good = tmp_path / "cap.pgm"
    assert module.output_path(str(good)) == good.resolve()
    with pytest.raises(SystemExit):
        module.output_path(str(tmp_path / "cap.png"))
    with pytest.raises(SystemExit):
        module.output_path("/etc/passwd.pgm")


def test_capture_main_paths(tmp_path, monkeypatch):
    module = capture()
    monkeypatch.setattr(module, "OUTPUT_ROOT", tmp_path)
    monkeypatch.setattr(sys, "argv", ["vfs495-capture"])
    with pytest.raises(SystemExit):
        module.main()

    monkeypatch.setattr(sys, "argv", ["vfs495-capture", str(tmp_path / "out.pgm")])
    monkeypatch.setattr(module.os.path, "exists", lambda path: False)
    with pytest.raises(SystemExit):
        module.main()

    def write_short(cmd, env=None, **kwargs):
        Path(env["VFS_ASM_OUT"]).write_bytes(b"short")
        return types.SimpleNamespace(returncode=0)

    monkeypatch.setattr(module.os.path, "exists", lambda path: True)
    monkeypatch.setattr(module.subprocess, "run", write_short)
    assert module.main() == 10

    def write_image(cmd, env=None, **kwargs):
        Path(env["VFS_ASM_OUT"]).write_bytes(struct.pack("<II", 4, 2) + b"abcdefgh")
        return types.SimpleNamespace(returncode=0)

    monkeypatch.setattr(module.subprocess, "run", write_image)
    assert module.main() == 0
    written = (tmp_path / "out.pgm").read_bytes()
    assert written.startswith(b"P5\n4 2\n255\n")
    assert written.endswith(b"abcdefgh")


def test_harvest_stop_filters_and_stores():
    module = harvest()
    gdb = sys.modules["gdb"]
    stopped, out = _stop(module, [(0).to_bytes(8, "little")])
    assert stopped is False
    assert module.hit["n"] == 0
    assert not out.exists()

    stopped, out = _stop(
        module,
        [
            (0x2000).to_bytes(8, "little"),
            (0).to_bytes(4, "little"),
            (2).to_bytes(4, "little"),
        ],
    )
    assert stopped is False
    assert module.hit["n"] == 0

    stopped, out = _stop(
        module,
        [
            (0x2000).to_bytes(8, "little"),
            (5000).to_bytes(4, "little"),
            (801).to_bytes(4, "little"),
        ],
    )
    assert stopped is False
    assert not out.exists()

    stopped, out = _stop(
        module,
        [
            (0x2000).to_bytes(8, "little"),
            (2).to_bytes(4, "little"),
            (3).to_bytes(4, "little"),
            b"abcdef",
        ],
    )
    assert stopped is False
    assert module.hit["n"] == 1
    assert out.read_bytes() == struct.pack("<II", 2, 3) + b"abcdef"

    stopped, out = _stop(module, [gdb.MemoryError("unmapped")])
    assert stopped is False
    assert module.hit["n"] == 0


def test_read_pgm_and_short_scan_filter(tmp_path, monkeypatch):
    module = match()
    good = tmp_path / "good.pgm"
    short = tmp_path / "short.pgm"
    comment = tmp_path / "comment.pgm"
    write_pgm(good, 2, 80)
    write_pgm(short, 2, 10)
    comment.write_bytes(b"P5\n# note\n2 80\n255\n" + b"\x02" * 160)
    assert module.read_pgm(comment)[0:2] == (2, 80)
    bad = tmp_path / "bad.pgm"
    bad.write_bytes(b"P2\n1 1\n1\n0\n")
    with pytest.raises(SystemExit):
        module.read_pgm(bad)

    device = MagicMock()
    device.get_driver.return_value = "virtual_image"
    monkeypatch.setattr(module, "open_device", lambda: (None, device))
    monkeypatch.setattr(module, "out", lambda message: None)
    monkeypatch.setattr(module, "err", lambda message: None)
    monkeypatch.setattr(module, "_conn", None)
    assert module.main(["vfs495-match", str(good), str(short)]) == 0
    device.close_sync.assert_called_once()


def test_capture_directory_guard_and_command(tmp_path, monkeypatch):
    module = match()
    root = tmp_path / "run"
    root.mkdir()
    monkeypatch.setattr(module, "CAPTURE_ROOT", root.resolve())
    monkeypatch.setattr(os, "geteuid", lambda: 0)
    monkeypatch.setattr(module.os.path, "exists", lambda path: True)
    monkeypatch.setattr(module.time, "sleep", lambda *args, **kwargs: None)
    monkeypatch.setattr(module, "out", lambda message: None)
    with pytest.raises(SystemExit):
        module.capture(1, "/etc")

    calls = []
    step = {"n": 0}

    def fake_run(cmd, **kwargs):
        calls.append(list(cmd))
        if not str(cmd[-1]).endswith(".pgm"):
            return types.SimpleNamespace(returncode=0)
        step["n"] += 1
        if step["n"] == 1:
            write_pgm(Path(cmd[-1]), 4, 90)
            return types.SimpleNamespace(returncode=0)
        if step["n"] == 2:
            write_pgm(Path(cmd[-1]), 4, 2)
            return types.SimpleNamespace(returncode=0)
        return types.SimpleNamespace(returncode=1)

    monkeypatch.setattr(module.subprocess, "run", fake_run)
    saved = module.capture(3, str(root / "swipes"))
    assert len(saved) == 1
    command = next(cmd for cmd in calls if str(cmd[-1]).endswith(".pgm"))
    assert command[:2] == ["/usr/bin/python3", "/usr/lib/vfs495-fprint/capture.py"]

    def only_tiny(cmd, **kwargs):
        if str(cmd[-1]).endswith(".pgm"):
            write_pgm(Path(cmd[-1]), 2, 1)
            return types.SimpleNamespace(returncode=0)
        return types.SimpleNamespace(returncode=0)

    monkeypatch.setattr(module.subprocess, "run", only_tiny)
    assert module.capture(1, str(root / "tiny")) == []


def test_install_template_uses_private_mode(tmp_path, monkeypatch):
    module = match()
    modes = []
    monkeypatch.setattr(os, "geteuid", lambda: 0)
    monkeypatch.setenv("SUDO_USER", "vfs-user")
    monkeypatch.setattr(module.os, "makedirs", lambda *args, **kwargs: None)
    monkeypatch.setattr(module.os.path, "exists", lambda path: False)
    monkeypatch.setattr(module.os, "chmod", lambda path, mode: modes.append((path, mode)))
    monkeypatch.setattr(module, "enroll_from_images", lambda *args: MagicMock(serialize=lambda: b"tmpl"))
    monkeypatch.setattr(module, "verify", lambda *args: (True, 40))
    monkeypatch.setattr(module, "out", lambda message: None)
    monkeypatch.setattr(module.subprocess, "run", lambda *args, **kwargs: None)
    real_open = open

    def fake_open(path, mode="r", *args, **kwargs):
        if isinstance(path, str) and path.startswith("/var/lib/fprint") and "w" in mode:
            return io.BytesIO()
        return real_open(path, mode, *args, **kwargs)

    monkeypatch.setattr("builtins.open", fake_open)
    image = tmp_path / "finger.pgm"
    write_pgm(image, 2, 80)
    module.install_template(MagicMock(), [str(image)], {str(image): (2, 80, b"xx")})
    assert ("/var/lib/fprint/vfs-user/virtual_image/0/7", 0o600) in modes


def test_main_template_capture_and_input_guard(tmp_path, monkeypatch):
    module = match()
    img = tmp_path / "a.pgm"
    img2 = tmp_path / "b.pgm"
    write_pgm(img, 2, 80)
    write_pgm(img2, 2, 80)
    tmpl = tmp_path / "tmpl"
    tmpl.write_bytes(b"x")
    device = MagicMock()
    monkeypatch.setattr(module, "open_device", lambda: (None, device))
    monkeypatch.setattr(module, "out", lambda message: None)
    monkeypatch.setattr(module, "err", lambda message: None)
    monkeypatch.setattr(module, "_conn", None)
    monkeypatch.setattr(module, "verify", lambda *args: (True, 50))
    monkeypatch.setattr(module, "enroll_from_image", lambda dev, image, name: None if name == str(img2) else object())
    assert module.main(["m", "--template", str(tmpl), str(img), str(img2)]) == 0

    monkeypatch.setattr(module, "capture", lambda n, d: [str(img)])
    monkeypatch.setattr(module, "find_templates", lambda: [str(tmpl)])
    assert module.main(["m", "--capture", "1"]) == 0
    monkeypatch.setattr(module, "capture", lambda n, d: [])
    with pytest.raises(SystemExit):
        module.main(["m", "--capture", "1"])

    module.FPrint.Print.deserialize.side_effect = module.GLib.Error("bad")
    module.GLib.Error.message = "bad"
    assert module.main(["m", "--template", str(tmpl), str(img)]) == 0

    with pytest.raises(SystemExit):
        module.input_path(tmp_path)
    assert module.read_input(tmpl) == b"x"


def test_main_enroll_installs_template(tmp_path, monkeypatch):
    module = match()
    img = tmp_path / "a.pgm"
    write_pgm(img, 2, 80)
    conn = MagicMock()
    installed = []
    monkeypatch.setattr(module, "open_device", lambda: (None, MagicMock()))
    monkeypatch.setattr(module, "out", lambda message: None)
    monkeypatch.setattr(module, "install_template", lambda *args: installed.append(args))
    monkeypatch.setattr(module, "_conn", conn)
    assert module.main(["m", "--enroll", str(img)]) == 0
    assert installed
    conn.close.assert_called_once()
