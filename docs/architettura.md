# Architettura

```text
coreboot (26.09)
  bootblock  -> bootblock.c, gpio.c         (GPIO e EC minimi)
  romstage   -> romstage.c, gpio.c          (SPD 0x50/0x52, mappa porte USB, RAM)
  ramstage   -> devicetree.cb, mainboard.c, (PCH, EC, PCI, HDA, GMA)
                hda_verb.c, acpi_tables.c, dsdt.asl + acpi/*.asl,
                gma-mainboard.ads           (libgfxinit)
  payload    -> a scelta (SeaBIOS, edk2, LinuxBoot)
```

## Piattaforma

- CPU Haswell mobile (`northbridge/intel/haswell`), PCH HM87 Lynx Point (`southbridge/intel/lynxpoint`).
- EC HP KBC1126 (`EC_HP_KBC1126`, GPE `0x16`), firmware EC non in CBFS.
- Audio: IDT 92HD91BXX con verb table legacy (`AZALIA_USE_LEGACY_VERB_TABLE`).
- Grafica: Intel HD 4600, init nativo libgfxinit, VBT da fornire.
- Scheda di riferimento upstream: `hp/folio_9480m` (stessa famiglia).

## Layout flash SPI (16 MB)

Vedi [`firmware_dump/DESCRIPTOR_ANALYSIS.md`](../firmware_dump/DESCRIPTOR_ANALYSIS.md): Descriptor 4 KB, GbE 8 KB, ME circa 8 MB, BIOS 8 MB.

## Directory

- `coreboot/`: sorgenti del port (GPL-2.0-only).
- `acpi/`: DSL decompilati dal BIOS OEM (riferimento, non GPL).
- `hardware_topology/`: output di dmidecode, lspci, inteltool, superiotool (identificativi oscurati).
- `security_and_flashing/`: guida al flashing.
