"""Unit tests for the vfs495 script changes. No sensor or libfprint required."""
import contextlib
import importlib.util
import io
import os
import runpy
import struct
import sys
import time
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
    monkeypatch.setattr(os, "geteuid", lambda: 0, raising=False)
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
    monkeypatch.setattr(os, "geteuid", lambda: 0, raising=False)
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


def test_bridge_pgm_and_socket_delivery(tmp_path, monkeypatch):
    module = bridge()
    image = tmp_path / "s.pgm"
    write_pgm(image, 3, 2)
    assert module.read_pgm(image) == (3, 2, b"\x10" * 6)

    sock = MagicMock()
    fake_socket = types.SimpleNamespace(AF_UNIX=1, SOCK_STREAM=1, socket=lambda *args: sock)
    monkeypatch.setattr(module, "socket", fake_socket)
    module.deliver(3, 2, b"abcdef")
    sock.connect.assert_called_once_with(module.SOCK)
    sock.sendall.assert_called_once_with(struct.pack("<ii", 3, 2) + b"abcdef")
    sock.close.assert_called_once()


def test_bridge_run_and_kill_capture(monkeypatch):
    module = bridge()
    proc = MagicMock(pid=42)
    proc.wait.return_value = 0
    monkeypatch.setattr(module.subprocess, "Popen", lambda *args, **kwargs: proc)
    assert module.run_capture("out.pgm") is True
    assert module.state["proc"] is None
    proc.wait.return_value = 1
    assert module.run_capture("out.pgm") is False

    killed = []
    pkills = []
    monkeypatch.setattr(module.os, "killpg", lambda pid, sig: killed.append(pid), raising=False)
    monkeypatch.setattr(module.subprocess, "run", lambda cmd, **kwargs: pkills.append(cmd))
    proc.poll.return_value = None
    module.state["proc"] = proc
    module.kill_capture()
    assert killed == [42] and len(pkills) == 1

    def refuse(pid, sig):
        raise OSError("gone")

    monkeypatch.setattr(module.os, "killpg", refuse, raising=False)
    module.kill_capture()
    assert len(pkills) == 2

    proc.poll.return_value = 0
    module.kill_capture()
    assert len(pkills) == 2
    module.state["proc"] = None


def test_bridge_dbus_event_handlers(monkeypatch):
    module = bridge()
    started = []
    monkeypatch.setattr(module, "log", lambda message: None)
    monkeypatch.setattr(module, "kill_capture", lambda: started.append("kill"))
    monkeypatch.setattr(
        module.threading, "Thread",
        lambda target, args, daemon: types.SimpleNamespace(start=lambda: started.append(args)),
    )
    module.state.update(capturing=False, wanted=False, gen=0)
    module.on_needed("test")
    assert started == [(1,)] and module.state["capturing"] is True
    module.on_needed("again")
    assert started == [(1,)]

    module.on_not_needed()
    assert module.state["wanted"] is False and module.state["gen"] == 2
    assert started[-1] == "kill"
    module.on_not_needed()
    assert started.count("kill") == 1

    module.state["capturing"] = False
    module.on_props_changed("other.iface", {"finger-needed": True}, [])
    assert module.state["wanted"] is False
    module.on_props_changed(module.DEV_IFACE, {"finger-needed": True}, [])
    assert module.state["wanted"] is True
    module.state["capturing"] = False
    module.on_props_changed(module.DEV_IFACE, {"finger-needed": False}, [])
    assert module.state["wanted"] is False
    module.on_verify_selected()
    assert module.state["wanted"] is True
    module.state.update(capturing=False, wanted=False)


def test_bridge_main_registers_receivers_and_checks_initial(monkeypatch):
    module = bridge()
    bus = MagicMock()
    needed = []
    props = MagicMock()
    props.Get.return_value = True
    manager = MagicMock()
    manager.GetDevices.return_value = ["/dev0"]
    interfaces = iter([manager, props])
    monkeypatch.setattr(module.dbus, "SystemBus", lambda: bus, raising=False)
    monkeypatch.setattr(module.dbus, "Interface", lambda obj, name: next(interfaces), raising=False)
    monkeypatch.setattr(module.dbus.mainloop.glib, "DBusGMainLoop", lambda **kwargs: None, raising=False)
    monkeypatch.setattr(module, "log", lambda message: None)
    monkeypatch.setattr(module, "on_needed", needed.append)
    module.main()
    assert bus.add_signal_receiver.call_count == 2
    check_initial = module.GLib.timeout_add.call_args[0][1]
    assert check_initial() is False
    assert needed == ["pending at startup"]

    bus.get_object.side_effect = module.dbus.DBusException("no fprintd")
    assert check_initial() is False


def test_capture_timeout_kills_sensor_helper(tmp_path, monkeypatch):
    module = capture()
    monkeypatch.setattr(module, "OUTPUT_ROOT", tmp_path)
    monkeypatch.setattr(sys, "argv", ["vfs495-capture", str(tmp_path / "out.pgm")])
    monkeypatch.setattr(module.os.path, "exists", lambda path: True)
    calls = []

    def timeout_then_kill(cmd, **kwargs):
        calls.append(cmd[0])
        if cmd[0] == "gdb":
            raise module.subprocess.TimeoutExpired(cmd, 1)

    def broken_unlink(path):
        raise OSError("busy")

    monkeypatch.setattr(module.subprocess, "run", timeout_then_kill)
    monkeypatch.setattr(module.os, "unlink", broken_unlink)
    assert module.main() == 10
    assert calls == ["gdb", "pkill"]


def test_match_send_image_retries_until_socket_accepts(monkeypatch):
    module = match()
    attempts = []

    class Sock:
        def connect(self, path):
            attempts.append(path)
            if len(attempts) == 1:
                raise OSError("not yet")

        def sendall(self, data):
            attempts.append(data)

    monkeypatch.setattr(module, "_conn", None)
    monkeypatch.setattr(module.time, "sleep", lambda *args: None)
    monkeypatch.setattr(module, "socket", types.SimpleNamespace(AF_UNIX=1, SOCK_STREAM=1, socket=lambda *args: Sock()))
    monkeypatch.setattr(
        module.threading, "Thread",
        lambda target, daemon: types.SimpleNamespace(start=target),
    )
    module.send_image((2, 1, b"ab"))
    assert attempts[-1] == struct.pack("<ii", 2, 1) + b"ab"
    module._conn = None


def test_match_open_device_and_enroll(monkeypatch):
    module = match()
    device = MagicMock()
    device.get_driver.return_value = "virtual_image"
    module.FPrint.Context.return_value.get_devices.return_value = [device]
    assert module.open_device()[1] is device
    device.open_sync.assert_called_once()
    module.FPrint.Context.return_value.get_devices.return_value = []
    with pytest.raises(SystemExit):
        module.open_device()

    sent = []
    monkeypatch.setattr(module, "send_image", lambda *args: sent.append(args))
    errors = []
    monkeypatch.setattr(module, "err", errors.append)
    dev = MagicMock()
    dev.get_nr_enroll_stages.return_value = 5

    def drive(tmpl, canc, progress, data):
        for completed in (1, 2, 20):
            progress(dev, completed, None, None)
        for _ in range(15):
            progress(dev, 1, None, None)
        return "print"

    dev.enroll_sync.side_effect = drive
    assert module.enroll_from_image(dev, (1, 1, b"x"), "a") == "print"
    assert module.enroll_from_images(dev, [(1, 1, b"x"), (1, 1, b"y")], "user") == "print"
    assert sent

    class Boom(Exception):
        message = "bad scan"

    monkeypatch.setattr(module.GLib, "Error", Boom)
    dev.enroll_sync.side_effect = Boom()
    assert module.enroll_from_image(dev, (1, 1, b"x"), "a") is None
    assert "bad scan" in errors[0]
    with pytest.raises(SystemExit):
        module.enroll_from_images(dev, [(1, 1, b"x")], "user")


def test_match_verify_scores_and_helpers(monkeypatch):
    module = match()
    monkeypatch.setattr(module, "send_image", lambda *args: None)
    monkeypatch.setattr(module, "err", lambda message: None)
    monkeypatch.setattr(module.time, "sleep", lambda *args: None)
    dev = MagicMock()

    def verified(*args):
        module._lines.extend(["score 12/40", "noise", "score 55/40"])
        return (True, None)

    dev.verify_sync.side_effect = verified
    assert module.verify(dev, "tmpl", (1, 1, b"x"), "a") == (True, 55)
    dev.verify_sync.side_effect = lambda *args: False
    assert module.verify(dev, "tmpl", (1, 1, b"x"), "a") == (False, -1)

    class Boom(Exception):
        message = "verify failed"

    monkeypatch.setattr(module.GLib, "Error", Boom)
    dev.verify_sync.side_effect = Boom()
    assert module.verify(dev, "tmpl", (1, 1, b"x"), "a") == (False, -1)

    assert "MATCH" in module.fmt(True, 50) and "no match" in module.fmt(False, 3)
    monkeypatch.setattr(module.glob, "glob", lambda pattern: ["/b", "/a"])
    monkeypatch.setenv("SUDO_USER", "someone")
    assert module.find_templates() == ["/a", "/b"]


def test_match_root_and_driver_guards(tmp_path, monkeypatch):
    module = match()
    monkeypatch.setattr(os, "geteuid", lambda: 1000, raising=False)
    with pytest.raises(SystemExit, match="--enroll needs root"):
        module.install_template(MagicMock(), [], {})
    with pytest.raises(SystemExit, match="--capture needs root"):
        module.capture(1, str(tmp_path))
    monkeypatch.setattr(os, "geteuid", lambda: 0, raising=False)
    monkeypatch.setattr(module.os.path, "exists", lambda path: False)
    with pytest.raises(SystemExit, match="HP driver not installed"):
        module.capture(1, str(tmp_path))


@contextlib.contextmanager
def preserved_stdout_fd():
    """match.py redirige il descrittore 1 in una pipe all'import: lo ripristina al termine."""
    saved = os.dup(1)
    try:
        yield
    finally:
        os.dup2(saved, 1)
        os.close(saved)


def test_match_collects_libfprint_debug_output():
    install_stubs()
    spec = importlib.util.spec_from_file_location("vfs495_match_debug", SCRIPTS / "match.py")
    module = importlib.util.module_from_spec(spec)
    with preserved_stdout_fd():
        spec.loader.exec_module(module)
        os.write(1, b"libfprint-print: score 57\n")
        deadline = time.monotonic() + 5
        while not module._lines and time.monotonic() < deadline:
            time.sleep(0.01)
    assert module._lines == ["libfprint-print: score 57\n"]


def test_match_script_entry_point_prints_usage_and_cleans_up(monkeypatch, capfd):
    install_stubs()
    monkeypatch.setattr(sys, "argv", ["vfs495-match", "--help"])
    with preserved_stdout_fd(), pytest.raises(SystemExit) as exit_info:
        runpy.run_path(str(SCRIPTS / "match.py"), run_name="__main__")
    assert exit_info.value.code == 0
    assert "vfs495-match IMG1.pgm" in capfd.readouterr().out
