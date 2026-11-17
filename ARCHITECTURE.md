# Architettura

Repository di documentazione e porting, non un'applicazione.

| Percorso | Contenuto |
| --- | --- |
| `coreboot/` | Port della scheda per l'albero di coreboot (`src/mainboard/hp/probook_640_g1`): devicetree, GPIO, verb audio, romstage, bootblock, GNVS e DSDT |
| `acpi/` | Tabelle ACPI originali decompilate (`dsdt.dsl`, `ssdt1..9.dsl`) |
| `hardware_topology/` | Dump della macchina: `lspci`, albero PCI, `dmidecode`, GPIO, PMBASE, `superiotool` |
| `firmware_dump/` | Analisi del descrittore SPI |
| `security_and_flashing/` | Guida al flash in-circuit |
| `subsystems/01..15` | Una cartella per componente hardware (firmware, impronte, Wi-Fi, Bluetooth, audio, grafica, touchpad, EC, termica, batteria, storage, lettore SD, webcam, chipset, ACPI) |
| `tests/` | Test degli script del lettore di impronte |
| `docs/` | `architettura.md`, `sicurezza.md`, `sviluppo.md` |

## Flusso

1. Si legge l'hardware (`hardware_topology/`, `acpi/`) e il chip flash
   (`firmware_dump/`).
2. Dai dati si scrive il port in `coreboot/`, copiato nell'albero coreboot per
   la compilazione.
3. L'immagine risultante si scrive con flashrom secondo la guida.

Dettagli per componente in [docs/architettura.md](docs/architettura.md).
