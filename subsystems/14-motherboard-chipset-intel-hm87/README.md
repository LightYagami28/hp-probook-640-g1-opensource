# 14 — Scheda Madre & Chipset Intel Lynx Point HM87 (8086:8c4b)

## 1. Specifiche Scheda Madre
* **Modello Scheda**: Hewlett-Packard 1993
* **Chipset**: Intel HM87 Express Chipset (Lynx Point PCH, `8086:8c4b`)
* **Socket CPU**: rPGA946B (Socket G3) compatibile con processori Intel Core di 4ª generazione Haswell Mobile 22nm
* **Memoria RAM**: 2 slot SO-DIMM DDR3L a 1.35V fino a 16 GB (Dual-Channel 1600 MT/s)

---

## 2. Reverse Engineering dei Range di Decode LPC (`genX_dec`)
Configurati nel Southbridge per inoltrare le porte legacy e proprietarie all'Embedded Controller SMSC:
* `gen1_dec = LPC_IO(0x200, 0x80)`: range mailbox EC (`0x0200..0x027F`)
* `gen2_dec = LPC_IO(0x100, 0x10)`: range porte diagnostiche OEM HP (`0x0100..0x010F`)
* `gen4_dec = LPC_IO(0x2e8, 0x8)`: range porta seriale ausiliaria COM4 / debug

---

## 3. Mappatura Registri GPIO PCH (`inteltool -g`)
Base I/O `GPIOBASE = 0x0800`:
* `GPIO_USE_SEL` = `0xb9ebefdf` (GPIO Set 1 Mode)
* `GP_IO_SEL`    = `0xafbfe7db` (GPIO Set 1 Direzione)
* `GP_LVL`       = `0x8fd377db` (GPIO Set 1 Livello)
* `GPI_INV`      = `0x006822da` (GPIO Set 1 Polarità di inversione)
* `GPIO_USE_SEL2`= `0x3bff0ffe` (GPIO Set 2 Mode)
* `GP_IO_SEL2`   = `0x0e93fffc` (GPIO Set 2 Direzione)
* `GP_LVL2`      = `0xdf369fec` (GPIO Set 2 Livello)
* `GPIO_USE_SEL3`= `0x000005f9` (GPIO Set 3 Mode)
* `GP_IO_SEL3`   = `0x00000b29` (GPIO Set 3 Direzione)
* `GP_LVL3`      = `0x00000ff6` (GPIO Set 3 Livello)

I valori estratti corrispondono esattamente a quelli incorporati in `coreboot/gpio.c`.

---

## 4. File Inclusi nella Cartella `dumps/`
* [`dumps/lspci_verbose.txt`](dumps/lspci_verbose.txt): spazio di configurazione esteso PCI per ogni periferica del bus.
* [`dumps/pci_tree.txt`](dumps/pci_tree.txt): gerarchia ad albero dei bridge e dispositivi PCIe.
* [`dumps/dmidecode.txt`](dumps/dmidecode.txt): tabelle SMBIOS (dati scheda, socket, slot, RAM).
* [`dumps/superiotool_dump.txt`](dumps/superiotool_dump.txt): registri logici Super I/O / KBC.
* [`dumps/gpio.txt`](dumps/gpio.txt) e [`dumps/pmbase.txt`](dumps/pmbase.txt): registri PCH catturati con `inteltool`.
