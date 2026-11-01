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
