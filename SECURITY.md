# Sicurezza

## Segnalare un problema

Non aprire una issue pubblica per vulnerabilità o dati sensibili trovati nel
repository (seriali, indirizzi MAC (Media Access Control), UUID, blob
proprietari). Usare la segnalazione privata
di GitHub ("Security" > "Report a vulnerability") sul repository.

## Cosa non va mai committato

- Dump della flash SPI (Serial Peripheral Interface), regioni Intel Flash
  Descriptor (IFD), Management Engine (ME) e Gigabit Ethernet (GbE),
  `data.vbt`, `*.rom`: restano solo in
  locale (vedi [`NOTICE.md`](NOTICE.md)).
- Seriali, UUID, MAC e numeri di serie dei dispositivi PCI (Peripheral Component
  Interconnect).
- Chiavi o token. La CI esegue gitleaks su ogni push e PR.

## Rischi del flashing

Vedi [`docs/sicurezza.md`](docs/sicurezza.md) e
[`security_and_flashing/FLASHING_GUIDE.md`](security_and_flashing/FLASHING_GUIDE.md).

## Avvio processi

Tutti gli script avviano processi da un unico punto, in
`subsystems/02-fingerprint-vfs495/scripts/exec_command.py::spawn`:
`posix_spawn` senza shell, con argomenti separati e whitelist di
quattro eseguibili assoluti ammessi (`/usr/bin/python3`,
`/usr/bin/gdb`, `/usr/bin/pkill`, `/usr/bin/systemctl`).
Qualunque altro percorso viene rifiutato prima della chiamata.

## Stato analisi statica (2026-11-21)

Prima degli interventi: 19 finding (1 Error, 2 Warning,
16 Info). Nessuna soppressione aggiunta.

- `dangerous-spawn-process-audit` (1 Error): il primo
  argomento di `posix_spawn` e' una variabile perche' la
  scelta tra i quattro eseguibili e' dinamica; e'
  comunque limitata alla whitelist soprastante.
- `Prospector_pydocstyle` (8), `Lizard_nloc-minor` (4),
  `Lizard_ccn-minor` (2): stile e soglie di complessita'
  sotto il limite critico.
- `sleep.arbitrary-sleep` (1): polling deliberato di 20 ms
  nell'attesa del figlio, con timeout massimo.
- `Prospector_vulture` (1): funzione `_close` non usata.
