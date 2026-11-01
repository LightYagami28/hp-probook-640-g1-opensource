# SPEC: firmware open source per HP ProBook 640 G1

## Scopo

Rendere il firmware dell'HP ProBook 640 G1 (Haswell, chipset HM87) sostituibile
con coreboot, documentando l'hardware e fornendo un port della scheda. Il
progetto è un lavoro di reverse engineering e porting; **non è stato testato su
hardware** (nessuna immagine compilata o flashata).

## Funzionalità

- Port coreboot `hp/probook_640_g1` (`coreboot/`): Kconfig, devicetree, GPIO,
  verb HDA, romstage, ACPI/GNVS, EC HP KBC1126.
- Tabelle ACPI OEM decompilate (`acpi/`) come riferimento.
- Mappe hardware (`hardware_topology/`) e analisi del descrittore Intel
  (`firmware_dump/DESCRIPTOR_ANALYSIS.md`).
- Guida al flashing hardware con programmatore SPI esterno.

## Architettura

Vedi [`docs/architettura.md`](docs/architettura.md).

## Flussi principali

1. Backup: lettura 3 volte della flash con flashrom, verifica SHA-256.
2. Estrazione: `ifdtool -x` per le regioni, VBT dal sistema originale.
3. Build: copia di `coreboot/` in `src/mainboard/hp/probook_640_g1`,
   configurazione, `make`.
4. Flash: scrittura della sola regione BIOS con `flashrom --ifd -i bios`.

## Modello dati

File di configurazione coreboot (Kconfig, `devicetree.cb`) e tabelle statiche
(GPIO, verb HDA). Nessun database.

## Interfacce

Nessuna API. Interfacce hardware: SPI (flash), LPC (EC KBC1126, I/O
`0x62`/`0x66`, GPE `0x16`), HDA (IDT 92HD91BXX), DDI/eDP (libgfxinit).

## Stack e versioni (verificate il 2026-10-31)

- coreboot: Versione di riferimento 26.09 (tag `26.09`); Fonte
  review.coreboot.org, doc.coreboot.org
- Toolchain crossgcc inclusa: Versione di riferimento GCC 15.2.0, binutils
  2.46.1, IASL 20251212; Fonte `util/crossgcc/buildgcc` a 26.09
- flashrom: Versione di riferimento 1.8.0; Fonte download.flashrom.org
- ifdtool: Versione di riferimento quello di `util/ifdtool` nell'albero coreboot
  26.09; Fonte coreboot
- GitHub Actions: Versione di riferimento checkout v7.0.1,
  markdownlint-cli2-action v25.0.0, lychee-action v2.9.0, gitleaks-action v3.0.0
  (SHA nel workflow); Fonte release GitHub

Tutto alla latest; nessun blocco noto.

## Sicurezza

Vedi [`docs/sicurezza.md`](docs/sicurezza.md) e [`SECURITY.md`](SECURITY.md).
Dump e blob proprietari esclusi dal repository.

## Limiti noti

- Port non compilato né testato su hardware con coreboot 26.09: le API di
  Haswell/Lynx Point possono essere cambiate rispetto alla scrittura del port.
- `BOARD_ROMSIZE_KB_12288` è ereditato da `hp/folio_9480m`, ma la regione BIOS
  analizzata è 8 MB: da correggere.
- Intel ME resta un blob (regione 2); con il descrittore di fabbrica non è
  leggibile dall'host.
- `coreboot/data.vbt` non è incluso e va estratto dal proprio sistema.
- Licenza della documentazione ancora da scegliere (vedi `NOTICE.md`, sezione
  4).
- I file nella cronologia git (commit `231288e`) non sono stati rimossi:
  decisione del titolare.

## Roadmap

1. Compilare il port contro coreboot 26.09 e sistemare gli errori di API.
2. Allineare la dimensione della ROM alla regione BIOS.
3. Primo boot con programmatore esterno; documentare gli esiti.
4. Proposta di upstream su review.coreboot.org.
5. Valutare `me_cleaner`/HAP per ridurre l'ME, con le dovute cautele.
