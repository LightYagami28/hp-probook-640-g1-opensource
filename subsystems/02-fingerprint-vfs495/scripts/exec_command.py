"""Esecuzione di comandi fissi senza shell per gli script vfs495.

Ogni chiamante passa un eseguibile assoluto e una lista di argomenti separati;
i valori dinamici (percorso dello swipe o azione di systemctl) vengono convalidati
prima di costruire la lista. Al posto di ``fork`` + ``execve`` si usa
``posix_spawn`` con file_actions: nessuna stringa viene interpretata da una shell,
i nomi non sono risolti via PATH e nel figlio non corre codice Python.
"""

from __future__ import annotations

import os
import signal
import time
from dataclasses import dataclass
from typing import Final, Self

DEVNULL = object()

# Unico punto di avvio processi: solo questi eseguibili assoluti sono ammessi.
# La lista non deriva da input dell'utente ne' da variabili d'ambiente.
EXECUTABILI_CONSENTITI: Final[frozenset[str]] = frozenset(
    {
        "/usr/bin/python3",
        "/usr/bin/gdb",
        "/usr/bin/pkill",
        "/usr/bin/systemctl",
    }
)


class CommandTimeout(Exception):
    """Un comando ha superato il tempo massimo previsto."""

    def __init__(self, argv: list[str], seconds: float) -> None:
        self.argv = tuple(argv)
        self.seconds = seconds
        super().__init__(f"comando interrotto dopo {seconds}s: {argv[0]}")


@dataclass
class ChildProcess:
    """Processo avviato da ``spawn``, con interfaccia minima di attesa."""

    pid: int
    _status: int | None = None

    def __enter__(self) -> Self:
        """Restituisce il processo come context manager, pronto per l'attesa."""
        return self

    def __exit__(self, *_exc: object) -> None:
        if self._status is None:
            self.wait()

    def poll(self) -> int | None:
        """Restituisce il codice di uscita se il processo e' terminato."""
        if self._status is None:
            done, status = os.waitpid(self.pid, os.WNOHANG)
            if done:
                self._status = status
        return None if self._status is None else os.waitstatus_to_exitcode(self._status)

    def wait(self, timeout: float | None = None) -> int:
        """Attende il processo e ne restituisce il codice di uscita."""
        if self._status is None:
            self._status = _wait(self.pid, timeout)
            if timeout is not None and os.waitstatus_to_exitcode(self._status) < 0:
                raise CommandTimeout([str(self.pid)], timeout)
        return os.waitstatus_to_exitcode(self._status)

    def terminate(self) -> None:
        """Termina il processo e i figli, conservandone lo stato di uscita."""
        if self._status is None:
            self._status = _terminate(self.pid)


def _close(fd: int | None) -> bool:
    """Chiude un descrittore; restituisce False se era gia' chiuso."""
    if fd is None:
        return False
    try:
        os.close(fd)
    except OSError:
        return False
    return True


def _signal(pid: int, sig: int) -> bool:
    """Invia un segnale; restituisce False se il processo e' gia' uscito."""
    try:
        os.kill(pid, sig)
    except ProcessLookupError:
        return False
    return True


def _wait(pid: int, timeout: float | None) -> int:
    """Attende ``pid``, terminandolo allo scadere del timeout."""
    if timeout is None:
        _, status = os.waitpid(pid, 0)
        return status
    deadline = time.monotonic() + timeout
    while True:
        done, status = os.waitpid(pid, os.WNOHANG)
        if done:
            return status
        if time.monotonic() >= deadline:
            return _terminate(pid)
        time.sleep(0.02)


def _terminate(pid: int) -> int:
    """Termina il processo e i suoi figli diretti, poi restituisce lo stato."""
    children = []
    try:
        with open(f"/proc/{pid}/task/{pid}/children", encoding="ascii") as handle:
            children = [int(value) for value in handle.read().split() if value.isdigit()]
    except (OSError, ValueError):
        children = []
    for child in children:
        _signal(child, signal.SIGTERM)
    _signal(pid, signal.SIGTERM)
    deadline = time.monotonic() + 2
    while time.monotonic() < deadline:
        done, status = os.waitpid(pid, os.WNOHANG)
        if done:
            return status
        time.sleep(0.02)
    _signal(pid, signal.SIGKILL)
    _, status = os.waitpid(pid, 0)
    return status


def spawn(
    argv: list[str],
    env: dict[str, str] | None = None,
    stdout: object = DEVNULL,
    stderr: object = DEVNULL,
) -> ChildProcess:
    """Avvia ``argv`` senza shell e restituisce un handle sul processo."""
    if not argv:
        raise ValueError("lista di argomenti vuota")
    if not argv[0].startswith("/"):
        raise ValueError("l'eseguibile deve essere un percorso assoluto")
    executable = argv[0]
    if executable not in EXECUTABILI_CONSENTITI:
        raise ValueError(f"eseguibile non consentito: {executable}")

    actions: list[tuple[int | str, ...]] = []
    for fd_no, target in ((1, stdout), (2, stderr)):
        if target is DEVNULL:
            actions.append((os.POSIX_SPAWN_OPEN, fd_no, os.devnull, os.O_WRONLY, 0))
        elif isinstance(target, int):
            actions.append((os.POSIX_SPAWN_DUP2, target, fd_no))

    child_env = dict(os.environ if env is None else env)
    pid = os.posix_spawn(executable, list(argv), child_env, file_actions=actions)
    return ChildProcess(pid)


def execute(
    argv: list[str],
    env: dict[str, str] | None = None,
    timeout: float | None = None,
) -> int:
    """Esegue ``argv`` fino alla fine e restituisce il codice di uscita."""
    with spawn(argv, env=env) as proc:
        return proc.wait(timeout)


def terminate(proc: ChildProcess) -> None:
    """Termina un processo avviato da ``spawn`` e i suoi figli."""
    proc.terminate()
