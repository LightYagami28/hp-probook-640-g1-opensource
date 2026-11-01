# 01 — Firmware BIOS OEM & Porting Coreboot

## 1. Panoramica Hardware & Flash SPI
L'HP ProBook 640 G1 monta un chip flash SPI da 16 MB (16.384 KB / 128 Mbit) gestito dal controller SPI integrato nel Platform Controller Hub (PCH) Intel Lynx Point HM87.

* **Capacità totale**: 16.777.216 byte (16 MB)
* **Controller Host**: Intel Lynx Point PCH SPI Controller
* **Interfaccia kernel Linux**: `intel-spi` (`/dev/mtd0`)
* **BIOS di fabbrica OEM**: HP UEFI BIOS L77 Ver. 01.43

---

## 2. Reverse Engineering del Descrittore Intel (IFD)
Dall'analisi della regione Flash Descriptor (4 KB) estratta con `ifdtool -d`:

| Regione | Indirizzo Iniziale | Indirizzo Finale | Dimensione | Permessi Host CPU (OEM) | Permessi Host CPU (Sbloccato) |
|---|---|---|---|---|---|
| **0. Flash Descriptor** | `0x00000000` | `0x00000FFF` | 4 KB | Read: SI / Write: NO | Read: SI / Write: SI |
| **3. GbE (Gigabit Ethernet)** | `0x00001000` | `0x00002FFF` | 8 KB | Read: SI / Write: SI | Read: SI / Write: SI |
| **2. Intel ME** | `0x00003000` | `0x007FFFFF` | 8.180 KB (~8 MB) | Read: NO / Write: NO | Read: SI / Write: SI |
| **1. BIOS Region** | `0x00800000` | `0x00FFFFFF` | 8.192 KB (8 MB) | Read: SI / Write: SI | Read: SI / Write: SI |

### Maschere Master (`FLMSTR1`)
* **Originale HP di fabbrica**: `0x0a0b0000` (accesso in scrittura bloccato sulla regione Descriptor e su ME).
* **Versione sbloccata generata**: `0xffff0000` (accesso totale Read/Write per Host CPU su tutte le regioni).

---

## 3. Architettura di Sicurezza & Limiti Software
Il flashing diretto via software da Linux è bloccato dall'hardware di protezione Intel Haswell/Lynx Point:
1. **Protected Range Registers (PR0..PR4)**: registri hardware nel PCH che intercettano e abortiscono scritture SPI.
2. **SMM BIOS Lock Enable (`SMM_BWP` / `BLE`)**: qualsiasi tentativo di scrittura genera un System Management Interrupt (SMI) catturato dal codice proprietario SMM di HP.
3. **Soluzione sicura**: primo flash tramite programmatore hardware esterno (CH341A o Raspberry Pi) con clip SOIC-8.

---

## 4. Porting Coreboot (`coreboot/`)
Il porting completo della scheda madre è integrato nel repository nella cartella [`../../coreboot/`](../../coreboot/) compatibile con `src/mainboard/hp/probook_640_g1`:
* `devicetree.cb`: definizione albero bus, periferiche Lynx Point, EC e clock.
* `gpio.c`: configurazione registri GPIO Set 1, 2, 3.
* `hda_verb.c`: tabella verb Azalia per codec IDT 92HD91BXX.
* `mainboard.c`, `bootblock.c`, `romstage.c`, `acpi_tables.c`.

### Verifica Build Coreboot
```bash
cd /home/light/coreboot_src
echo -e "CONFIG_VENDOR_HP=y\nCONFIG_BOARD_HP_PROBOOK_640_G1=y" > .config
make olddefconfig
grep -E "CONFIG_BOARD_HP_PROBOOK_640_G1|CONFIG_MAINBOARD_DIR" .config
```
Output:
```text
CONFIG_MAINBOARD_DIR="hp/probook_640_g1"
CONFIG_BOARD_HP_PROBOOK_640_G1=y
```
