# Guida Flashing e Architettura di Sicurezza HP ProBook 640 G1

## 1. Stato Attuale (Safe Coding & Zero Costi Hardware)
In questa fase è stata completata l'intera decodifica, analisi delle regioni leggibili (Flash Descriptor, GbE, BIOS UEFI da 8 MB, tabelle ACPI e VBT; i dump binari restano solo in locale, vedi [`NOTICE.md`](../NOTICE.md)) e la creazione del port Coreboot dedicato (`hp/probook_640_g1`).
**Nessuna scrittura distruttiva sulla flash è stata effettuata.** Il laptop rimane al 100% funzionante con il firmware originale HP L77.

## 2. Perché il Flashing Software da Linux è Bloccato
Il chipset Intel Lynx Point (HM87) e il firmware HP implementano diversi livelli di sicurezza hardware:
1. **Flash Descriptor Write Lock**: Nel Flash Descriptor di fabbrica, la maschera di scrittura della regione Descriptor per l'Host CPU è disabilitata (`FLMSTR1 = 0x0a0b0000`).
2. **Intel PCH Protected Range Registers (PR0..PR4)**: Il BIOS HP imposta registri hardware nel PCH che bloccano qualsiasi operazione di scrittura o cancellazione SPI al di fuori di sessioni autorizzate.
3. **SMM BIOS Lock Enable (BLE / SMM_BWP)**: Nel registro `BIOS_CNTL` del PCH, il bit `BLE` è abilitato. Tentativi di scrittura attivano un System Management Interrupt (SMI) che blocca la scrittura a livello System Management Mode.

> [!WARNING]
> **MAI tentare di forzare la scrittura del BIOS via software.**
> Senza programmatore hardware esterno, un'interruzione di scrittura o un errore di bootblock rende la macchina non avviabile (brick irreversibile senza programmatore esterno).

---

## 3. Procedura Futura con Hardware Programmer (Quando disponibile)

Quando potrai investire pochi euro (circa 3-5 EUR) in un programmatore economico:

### Attrezzatura necessaria
1. **Programmatore USB SPI**: CH341A (versione black o green con mod 3.3V verificata) o Raspberry Pi / RP2040 (Pico-Serprog).
2. **Clip SOIC-8**: Clip a molla (es. Pomona 5250 o clip standard 8-pin SOIC) per collegarsi al chip SPI senza dissaldarlo dalla scheda madre.

### Passi operativi sicuri

#### Passo 1: Backup fisico completo (3x)
1. Rimuovere alimentazione e batteria dal laptop.
2. Collegare la clip SOIC-8 al chip SPI sulla scheda madre.
3. Eseguire tre letture consecutive:
   ```bash
   flashrom -p ch341a_spi -r dump1.bin
   flashrom -p ch341a_spi -r dump2.bin
   flashrom -p ch341a_spi -r dump3.bin
   ```
4. Verificare che i dump siano identici al byte:
   ```bash
   sha256sum dump1.bin dump2.bin dump3.bin
   ```
   *Se gli hash differiscono, NON proseguire e controllare i contatti della clip.*

#### Passo 2: Ricavare descrittore, GbE e VBT dal proprio dump
I file `.bin` (`flash_descriptor.bin`, `flash_descriptor_unlocked.bin`, `gbe_region.bin`, `bios_region.bin`) **non sono nel repository** (vedi [`NOTICE.md`](../NOTICE.md)): ogni utente li ricava dal proprio `dump1.bin` verificato al passo 1. La GbE contiene il MAC del singolo portatile, quindi non va mai presa da altri.
1. Estrarre le regioni con `ifdtool` (si compila da `util/ifdtool` nell'albero coreboot):
   ```bash
   mkdir regioni && cd regioni
   ifdtool -x ../dump1.bin
   # produce flashregion_0_flashdescriptor.bin, flashregion_1_bios.bin,
   #         flashregion_2_intel_me.bin, flashregion_3_gbe.bin
   ```
2. Generare il descrittore sbloccato (facoltativo, serve solo per poter riscrivere il descrittore via software in futuro):
   ```bash
   ifdtool -u ../dump1.bin   # crea dump1.bin.new con le maschere FLMSTR sbloccate
   ```
3. Estrarre la VBT dal sistema originale in esecuzione, prima di flashare, e copiarla in `src/mainboard/hp/probook_640_g1/data.vbt` nell'albero coreboot:
   ```bash
   sudo cat /sys/kernel/debug/dri/0/i915_vbt > data.vbt
   ```
4. Conservare tutto in un backup privato, fuori da git (il `.gitignore` esclude `*.bin`, `*.rom`, `*.vbt`).

#### Passo 3: Flash di coreboot
1. Compilare coreboot (vedi [`docs/sviluppo.md`](../docs/sviluppo.md)). Verificare che la dimensione della ROM coincida con la regione BIOS del proprio descrittore (8 MB sul dump analizzato; il port seleziona `BOARD_ROMSIZE_KB_12288`, ereditato dalla scheda di riferimento: da correggere prima del primo flash, NON VERIFICATO su hardware).
2. Scrivere la sola regione BIOS, lasciando intatti descrittore, ME e GbE del proprio dump:
   ```bash
   flashrom -p ch341a_spi --ifd -i bios -w build/coreboot.rom
   ```
3. In caso di qualsiasi problema, ripristinare il backup originale `dump1.bin` in 2 minuti:
   ```bash
   flashrom -p ch341a_spi -w dump1.bin
   ```
