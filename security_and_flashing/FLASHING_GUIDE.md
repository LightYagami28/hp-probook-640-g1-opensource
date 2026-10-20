# Guida Flashing e Architettura di Sicurezza HP ProBook 640 G1

## 1. Stato Attuale (Safe Coding & Zero Costi Hardware)
In questa fase è stata completata l'intera decodifica, dump delle regioni leggibili (Flash Descriptor, GbE, BIOS UEFI da 8 MB, tabelle ACPI e VBT) e la creazione del port Coreboot dedicato (`hp/probook_640_g1`).
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

Quando potrai investire pochi euro (circa 3-5 €) in un programmatore economico:

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

#### Passo 2: Sblocco Descrittore e Flash Coreboot
1. Integrare il descrittore sbloccato (`flash_descriptor_unlocked.bin`) e la regione GbE (`gbe_region.bin`).
2. Flashare solo la regione BIOS o l'intera immagine compilata di Coreboot:
   ```bash
   flashrom -p ch341a_spi --ifd -i bios -w build/coreboot.rom --noverify-all
   ```
3. In caso di qualsiasi problema, ripristinare il backup originale `dump1.bin` in 2 minuti:
   ```bash
   flashrom -p ch341a_spi -w dump1.bin
   ```
