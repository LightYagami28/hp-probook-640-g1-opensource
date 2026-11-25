"""Esecuzione di comandi fissi senza shell e senza PATH per gli script vfs495."""

# Ogni chiamante passa un eseguibile assoluto e una lista di argomenti separati;
# i valori dinamici (percorso dello swipe o azione di systemctl) vengono convalidati
# prima di costruire la lista. Al posto di ``fork`` + ``execve`` si usa
# ``posix_spawn`` con file_actions: nessuna stringa viene interpretata da una shell,
# i nomi non sono risolti via PATH e nel figlio non corre codice Python.

from __future__ import annotations

import os
import signal
import threading
import time
from dataclasses import dataclass, field
from typing import Final, Self

DEVNULL = object()

# Unico punto di avvio processi: solo questi eseguibili assoluti sono ammessi.
# La lista non deriva da input dell'utente né da variabili d'ambiente.
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
        """Registra gli argomenti e il tempo massimo del comando interrotto."""
        self.argv = tuple(argv)
        self.seconds = seconds
        super().__init__(f"comando interrotto dopo {seconds}s: {argv[0]}")


@dataclass
class ChildProcess:
    """Processo avviato da ``spawn``, con interfaccia minima di attesa.

    ``wait``, ``poll`` e ``terminate`` possono arrivare da thread diversi (il bridge
    attende la cattura in un thread e la annulla da quello degli eventi D-Bus).
    Il pid viene raccolto con ``waitpid`` una sola volta e sempre sotto ``_lock``:
    i segnali partono solo finché il processo non è stato raccolto, quindi non
    possono colpire un pid riassegnato e nessun thread riceve ``ECHILD``.
    """

    pid: int
    _status: int | None = None
    _lock: threading.Lock = field(default_factory=threading.Lock, repr=False, compare=False)

    def __enter__(self) -> Self:
        """Restituisce il processo come context manager, pronto per l'attesa."""
        return self

    def __exit__(self, *_exc: object) -> None:
        """Attende il processo alla chiusura del context manager."""
        self.wait()

    def _reap(self) -> bool:
        """Raccoglie il processo se è uscito; va chiamato con ``_lock`` preso."""
        if self._status is None:
            done, status = os.waitpid(self.pid, os.WNOHANG)
            if done:
                self._status = status
        return self._status is not None

    def _signal_alive(self, sig: int, children: bool = False) -> bool:
        """Invia ``sig`` solo se il processo non è ancora stato raccolto."""
        with self._lock:
            if self._reap():
                return False
            if children:
                for child in _children(self.pid):
                    _signal(child, sig)
            return _signal(self.pid, sig)

    def _wait_until(self, deadline: float | None) -> bool:
        """Attende l'uscita fino a ``deadline``; restituisce True se è uscito."""
        while True:
            with self._lock:
                if self._reap():
                    return True
            if deadline is not None and time.monotonic() >= deadline:
                return False
            time.sleep(0.02)

    def _exit_code(self) -> int:
        """Codice di uscita del processo già raccolto."""
        if self._status is None:
            raise RuntimeError("processo non ancora raccolto")
        return os.waitstatus_to_exitcode(self._status)

    def poll(self) -> int | None:
        """Restituisce il codice di uscita se il processo è terminato."""
        with self._lock:
            if not self._reap():
                return None
        return self._exit_code()

    def wait(self, timeout: float | None = None) -> int:
        """Attende il processo e ne restituisce il codice di uscita."""
        deadline = None if timeout is None else time.monotonic() + timeout
        if not self._wait_until(deadline):
            self.terminate()
            code = self._exit_code()
            if code < 0:
                raise CommandTimeout([str(self.pid)], timeout or 0)
            return code
        return self._exit_code()

    def terminate(self) -> None:
        """Termina il processo e i figli, conservandone lo stato di uscita."""
        if self._signal_alive(signal.SIGTERM, children=True) and not self._wait_until(
            time.monotonic() + 2
        ):
            self._signal_alive(signal.SIGKILL)
        self._wait_until(None)


def _signal(pid: int, sig: int) -> bool:
    """Invia un segnale; restituisce False se il processo è già uscito."""
    try:
        os.kill(pid, sig)
    except ProcessLookupError:
        return False
    return True


def _children(pid: int) -> list[int]:
    """Restituisce i figli diretti di ``pid`` leggendoli da /proc."""
    try:
        with open(f"/proc/{pid}/task/{pid}/children", encoding="ascii") as handle:
            return [int(value) for value in handle.read().split() if value.isdigit()]
    except (OSError, ValueError):
        return []


def _validate_executable(argv: list[str]) -> str:
    """Convalida ``argv`` e restituisce l'eseguibile assoluto consentito."""
    if not argv:
        raise ValueError("lista di argomenti vuota")
    executable = argv[0]
    if not executable.startswith("/"):
        raise ValueError("l'eseguibile deve essere un percorso assoluto")
    if executable not in EXECUTABILI_CONSENTITI:
        raise ValueError(f"eseguibile non consentito: {executable}")
    return executable


def _spawn_actions(stdout: object, stderr: object) -> list[tuple[int | str, ...]]:
    """Costruisce le redirezioni dei descrittori per ``posix_spawn``."""
    actions: list[tuple[int | str, ...]] = []
    for descriptor, target in ((1, stdout), (2, stderr)):
        if target is DEVNULL:
            actions.append((os.POSIX_SPAWN_OPEN, descriptor, os.devnull, os.O_WRONLY, 0))
        elif isinstance(target, int):
            actions.append((os.POSIX_SPAWN_DUP2, target, descriptor))
    return actions


def spawn(
    argv: list[str],
    env: dict[str, str] | None = None,
    stdout: object = DEVNULL,
    stderr: object = DEVNULL,
) -> ChildProcess:
    """Avvia ``argv`` senza shell e restituisce un handle sul processo."""
    executable = _validate_executable(argv)
    actions = _spawn_actions(stdout, stderr)
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
