# Sicurezza

## Protezioni della piattaforma di fabbrica

- Descrittore: maschera di scrittura host disabilitata (`FLMSTR1 = 0x0a0b0000`).
- PRx del PCH (PR0..PR4) impostati dal BIOS HP.
- `BIOS_CNTL`: BLE/SMM_BWP attivi, la scrittura genera una SMI.

Per questo il primo flash richiede un programmatore esterno. Mai forzare la scrittura via software.

## Pratiche

- Backup 3 volte, hash identici, prima di ogni scrittura.
- Alimentazione e batteria scollegate durante l'uso della clip.
- Mai usare GbE o descrittori di altri dispositivi (il MAC è specifico).
- Conservare i dump solo in locale; il repository li esclude (vedi [`NOTICE.md`](../NOTICE.md)).
- Intel ME: resta un blob proprietario; il port non lo sostituisce.

## Dati nel repository

Seriali, UUID e numeri di serie PCI sono oscurati. La cronologia git contiene ancora i file rimossi nella PR #1.
