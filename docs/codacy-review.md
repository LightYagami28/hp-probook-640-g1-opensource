---
tags: [codacy, qualita, analisi-statica]
aggiornato: 2026-11-22
---

# Codacy: revisione dei falsi positivi

Data verifica: 2026-11-22. Repository
`gh/LightYagami28/hp-probook-640-g1-opensource`,
ramo `main`. Conteggio iniziale: 20 issue
(Error 1, High 1, Warning 3, Info 15),
tutte classificate `belowThreshold` dall'overview API.

Questo documento registra i falsi positivi dimostrati.
Nessuna issue e' stata chiusa come "accepted"/"won't fix";
non sono state usate soppressioni, baseline, esclusioni in
`.codacy.yml`, soglie o gate abbassati.

## Falsi positivi dimostrati

### dangerous-spawn-process-audit — exec_command.py:158

Falso positivo gia' dimostrato e documentato nella PR #20 di questo
repository; si riutilizza identicamente la motivazione ivi riportata:

1. La regola Semgrep ufficiale, nel percorso
   `python/lang/security/audit/dangerous-spawn-process-audit.yaml`,
   esclude con `pattern-not: os.$METHOD($MODE, "...", ...)`:
   pattern scritto per `os.spawnve(mode, percorso, argv, env)`.
   In `os.posix_spawn(percorso, argv, env, file_actions=...)`
   il secondo argomento e' sempre la lista `argv`, mai un letterale
   stringa: la regola non puo' quindi escludere nessuna chiamata
   valida a `posix_spawn`.
2. Nessun dato esterno raggiunge la chiamata:
   `EXECUTABILI_CONSENTITI` e' una frozenset di soli 4 percorsi
   assoluti e `argv[0]` deve iniziare con `/`. Il test dedicato
   `test_spawn_accepts_only_whitelisted_absolute_executables`
   verifica che `["python3"]` e `["/bin/sh", "-c", "true"]`
   vengano rifiutati con `ValueError`.
3. Sostituire `posix_spawn` con `execve` farebbe sparire Semgrep
   ma farebbe comparire Bandit B606: i due scanner richiedono API
   mutually esclusive per lo stesso avvio senza shell.

### arbitrary-sleep — exec_command.py:110

La regola segnala `time.sleep(0.02)` nelle due procedure di attesa.
Il sonno non e' arbitrario: e' l'intervallo di polling di un ciclo
con scadenza esplicita e monotona.

- `_wait`: `deadline = time.monotonic() + timeout`; ad ogni
  iterazione verifica `os.waitpid(pid, os.WNOHANG)` e interrompe
  al raggiungimento della scadenza.
- `_terminate`: `deadline = time.monotonic() + 2`; stesso schema,
  poi `SIGKILL` se il processo non e' uscito.

L'intervallo impedisce il busy-wait senza introdurre attese
indefinite. Prova: `pytest -q tests` -> 25 passati, 0 falliti,
inclusi i test di timeout e terminazione.

### vulture — execute in exec_command.py:162

Vulture segnala `execute` come funzione non usata, ma la funzione
e' richiamata da tre moduli che la importano esplicitamente.
Comando usato per l'evidenza:

```text
grep -n "^from exec_command import\|execute(" \
  subsystems/02-fingerprint-vfs495/scripts/*.py
```

Risultato: `bridge.py:20,107`, `capture.py:17,61,77`,
`match.py:29,230,275,308`. L'analisi di Vulture non risolve le
importazioni tra moduli e produce quindi un falso positivo.

### referenced-files-exist — SECURITY.md:1

Il rule segnala il link a `NOTICE.md` come file mancante.
Il file e' presente e tracciato:

```text
git ls-files NOTICE.md
NOTICE.md
```

Il percorso e' relativo alla radice del repository, quindi il link
in `SECURITY.md` (anch'esso alla radice) e' corretto.

## Issue reali

Le restanti issue sono state affrontate nel codice:

- 7 `Prospector_pydocstyle`, 1 `PyLintPython3_C0103` e 1
  `Prospector_vulture` (`_close`): PR #24.
- 7 `Lizard` di complessita' e lunghezza: PR successiva.

## Verifiche

- `pytest -q tests`: 25 passati, 0 falliti.
- Nessuna modifica a `.codacy.yml`.
