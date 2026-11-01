# HP ProBook 640 G1 Open-Source Firmware & Hardware Porting Project

Progetto completo di reverse engineering, dump hardware/firmware e porting
open-source a **Coreboot** per il portatile **HP ProBook 640 G1**.

Tutti i componenti proprietari, le mappature hardware, i registri del chipset, i
descrittori SPI e le tabelle ACPI sono stati estratti, decodificati e
documentati per rendere l'intera piattaforma trasparente, modificabile e
sbloccata.

---

## 💻 Scheda Tecnica della Macchina Target

- **Modello**: HP ProBook 640 G1 (Subsystem ID: `103c:1993`)
- **Processore**: Intel Core i5-4210M @ 2.60GHz (Haswell Mobile, 2 core / 4
  thread)
- **Northbridge**: Haswell Host Bridge (`8086:0c04`)
- **Southbridge / Chipset**: Intel HM87 Lynx Point PCH (`8086:8c4b`)
- **Grafica Integrata**: Intel HD Graphics 4600 (`8086:0416`)
- **Embedded Controller (EC)**: SMSC KBC1126 / MEC1322 compatibile (KBC Ver.
  `16.3C`, I/O `0x62`/`0x66`, GPE `0x16`)
- **Audio Codec**: IDT 92HD91BXX (`111d:76e0`, Subsystem `103c:2105`) + Intel
  Haswell HDMI
- **Wi-Fi**: Broadcom BCM43228 802.11a/b/g/n (`14e4:4359`)
- **Ethernet**: Intel Gigabit Ethernet I217-LM (`8086:153b`)
- **SD Card Reader**: Realtek RTS5227 PCI-E Card Reader (`10ec:5227`)
- **Fingerprint Reader**: Validity Sensors VFS495 (`138a:003f`)
- **Chip Flash SPI**: 16 MB (16.384 KB) collegato via Intel PCH SPI Sequencer
- **Firmware OEM di Fabbrica**: HP UEFI BIOS L77 Ver. 01.43 (01/25/2018)

---

## 📂 Struttura del Repository

```text
coreboot/               Porting coreboot (src/mainboard/hp/probook_640_g1)
  Kconfig, Kconfig.name, Makefile.mk
  devicetree.cb         Periferiche PCH, EC, PCI
  gpio.c                GPIO Set 1, 2, 3
  hda_verb.c            Pin verb Azalia, codec IDT 92HD91BXX
  romstage.c            Memoria e porte USB
  bootblock.c           Bootblock
  acpi_tables.c         GNVS ACPI
  dsdt.asl, acpi/       DSDT master e sotto-tabelle ASL
  (data.vbt)            NON inclusa, da estrarre (vedi NOTICE.md)

subsystems/             15 cartelle dedicate per ogni componente hardware del laptop
  01-firmware-bios-coreboot/              Firmware SPI & Coreboot port
  02-fingerprint-vfs495/                  Lettore impronte VFS495 & protocollo
  03-wifi-broadcom-bcm43228/              Scheda Wi-Fi Broadcom dual-band
  04-bluetooth-bcm20702a0/                Controller Bluetooth 4.0 & HCD
  05-audio-idt92hd91bxx/                  Codec audio IDT & HDMI
  06-graphics-intel-hd4600/               Grafica Haswell GT2 & VBT
  07-touchpad-trackpoint/                 Touchpad Synaptics PS/2 multiplexato
  08-embedded-controller-smsc-kbc1126/    EC SMSC KBC1126 & registri ACPI
  09-thermal-cooling/                     Zone termiche & controllo ventola
  10-battery-power-management/            Smart Battery & Smart AC Adapter
  11-storage-hdd-odd-accelerometer/       Storage SATA, DVD & HP 3D DriveGuard
  12-card-reader-realtek-rts5227/         Lettore schede SD Realtek PCIe
  13-webcam-chicony-hd/                   Webcam Chicony HD 720p UVC
  14-motherboard-chipset-intel-hm87/      PCH HM87, GPIO & decode LPC
  15-acpi-tables/                         Tabelle DSDT e SSDT 1..9 decompilate

firmware_dump/          Analisi del chip SPI da 16 MB
  DESCRIPTOR_ANALYSIS.md
                        (i file .bin NON sono inclusi: vedi NOTICE.md)

acpi/                   Tabelle ACPI OEM decompilate in ASL
  dsdt.dsl              DSDT completo
  ssdt1.dsl - ssdt9.dsl SSDT secondarie (SpeedStep, C-States, ecc.)

hardware_topology/      Mappe registri e architettura hardware
  lspci_verbose.txt     Registri di configurazione PCI
  pci_tree.txt          Albero dei bus PCI Express
  dmidecode.txt         Dump SMBIOS
  superiotool_dump.txt  Registri Super I/O SMSC / Microchip
  gpio.txt              Registri GPIO PCH (inteltool)
  pmbase.txt            Registri Power Management (PMBASE)

security_and_flashing/  Guida sicurezza hardware e procedura flash
  FLASHING_GUIDE.md     Blocchi Intel PRx/SMM e flasher CH341A
```

---

## 🧩 Sottosistemi Hardware & Reverse Engineering (`subsystems/`)

Ogni singolo componente hardware del portatile è analizzato, decodificato e documentato nella propria cartella:

- [**`01-firmware-bios-coreboot/`**](subsystems/01-firmware-bios-coreboot/): Analisi descrittore IFD sbloccato, limiti PRx/SMM e guida flashing.
- [**`02-fingerprint-vfs495/`**](subsystems/02-fingerprint-vfs495/): Reverse engineering protocollo Validity, chiavi RSA, patch e bridge fprintd.
- [**`03-wifi-broadcom-bcm43228/`**](subsystems/03-wifi-broadcom-bcm43228/): Modulo kernel `wl`, risoluzione conflitti e blacklist driver legacy.
- [**`04-bluetooth-bcm20702a0/`**](subsystems/04-bluetooth-bcm20702a0/): Firmware patch RAM HCD (Build 1765) e configurazione BlueZ.
- [**`05-audio-idt92hd91bxx/`**](subsystems/05-audio-idt92hd91bxx/): Nodi Azalia, tabella verb, jack sensing e routing altoparlanti.
- [**`06-graphics-intel-hd4600/`**](subsystems/06-graphics-intel-hd4600/): Timing eDP dal VBT, inizializzazione libgfxinit e VA-API.
- [**`07-touchpad-trackpoint/`**](subsystems/07-touchpad-trackpoint/): Multiplexing EC i8042, gesture multi-touch e configurazione libinput.
- [**`08-embedded-controller-smsc-kbc1126/`**](subsystems/08-embedded-controller-smsc-kbc1126/): Mappa registri ECRM, porte `0x62`/`0x66`, mailbox `0x0200` ed eventi `_Qxx`.
- [**`09-thermal-cooling/`**](subsystems/09-thermal-cooling/): 8 zone termiche ACPI, trip point (90°C/100°C) e PWM ventola.
- [**`10-battery-power-management/`**](subsystems/10-battery-power-management/): Specifica SBS 1.1, handshake Smart AC su linea 1-Wire e ACPI `BAT0`.
- [**`11-storage-hdd-odd-accelerometer/`**](subsystems/11-storage-hdd-odd-accelerometer/): Controller SATA AHCI, unità ottica e sensore anti-caduta LIS3LV02DL.
- [**`12-card-reader-realtek-rts5227/`**](subsystems/12-card-reader-realtek-rts5227/): Controller PCIe Realtek, bus UHS-I SDR104 e autosuspend ASPM.
- [**`13-webcam-chicony-hd/`**](subsystems/13-webcam-chicony-hd/): Controller UVC 720p 30 FPS MJPEG/YUYV e microfoni digitali array.
- [**`14-motherboard-chipset-intel-hm87/`**](subsystems/14-motherboard-chipset-intel-hm87/): Topologia PCIe, range decode LPC (`gen1_dec`..`gen4_dec`) e GPIO Set 1-3.
- [**`15-acpi-tables/`**](subsystems/15-acpi-tables/): Tabelle DSDT e SSDT 1..9 decompilate.

---

## 🚀 Come Compilare Coreboot per HP ProBook 640 G1

Il porting è nella directory `coreboot/`, scritto per l'albero di Coreboot.
**Non è stato ancora compilato né provato su hardware con coreboot 26.09**: vedi
i limiti in [`SPEC.md`](SPEC.md).

### 1. Clonare Coreboot

```bash
git clone https://review.coreboot.org/coreboot.git
cd coreboot
git checkout 26.09   # ultima release verificata il 2026-10-31
```

### 2. Installare il port della mainboard

Copiare i file del port all'interno del percorso standard di Coreboot:

```bash
cp -r /path/to/hp-probook-640-g1-opensource/coreboot src/mainboard/hp/probook_640_g1
```

### 3. Configurare la build

Creare o generare la configurazione selezionando il vendor `HP` e la mainboard
`ProBook 640 G1`:

```bash
echo -e "CONFIG_VENDOR_HP=y\nCONFIG_BOARD_HP_PROBOOK_640_G1=y" > .config
make olddefconfig
```

### 4. Compilazione

```bash
make crossgcc-i386 CPUS=$(nproc)
make
```

Il binario risultante `build/coreboot.rom` conterrà il payload (es. SeaBIOS,
TianoCore EDK2 o LinuxBoot) con inizializzazione nativa di grafica Haswell
tramite `libgfxinit` e gestione dell'Embedded Controller HP.

---

## 🛡️ Sicurezza Hardware e Flashing (Safe Coding)

- **Zero Rischio Attuale**: Nessuna scrittura distruttiva è stata eseguita sulla
  memoria non volatile del laptop.
- **Backup in locale**: i dump necessari al ripristino (BIOS, descrittore, GbE)
  e la VBT vanno conservati **solo in locale**, fuori da git: non sono più
  pubblicati in questo repository (vedi [`NOTICE.md`](NOTICE.md)).
- **Prossimo Passo Hardware**: Quando vorrai installare Coreboot sulla scheda
  madre fisica, sarà sufficiente utilizzare un programmatore esterno da pochi
  euro (es. CH341A con clip SOIC-8) per eseguire il primo flash senza alcun
  rischio di brick, come descritto in
  [`security_and_flashing/FLASHING_GUIDE.md`](security_and_flashing/FLASHING_GUIDE.md).

---

## 📦 File da estrarre in locale

Per compilare e per il ripristino servono file proprietari che **non** sono
distribuiti qui:

- `data.vbt`: estrarla dal proprio sistema (es. `sudo cat
  /sys/kernel/debug/dri/0/i915_vbt > data.vbt`) e copiarla in
  `src/mainboard/hp/probook_640_g1/` nell'albero coreboot.
- Dump della flash SPI (`flashrom -p ch341a_spi -r dump1.bin`, vedi la guida) e
  regioni estratte con `ifdtool -x`: da tenere in un backup privato.

## 📚 Documentazione

- [`SPEC.md`](SPEC.md): specifica, stack con versioni, limiti, roadmap.
- [`docs/architettura.md`](docs/architettura.md),
  [`docs/sviluppo.md`](docs/sviluppo.md),
  [`docs/sicurezza.md`](docs/sicurezza.md).
- [`CONTRIBUTING.md`](CONTRIBUTING.md), [`SECURITY.md`](SECURITY.md),
  [`CHANGELOG.md`](CHANGELOG.md).

## 🧰 Versioni di riferimento (2026-10-31)

coreboot 26.09 (crossgcc: GCC 15.2.0, binutils 2.46.1, IASL 20251212), flashrom
1.8.0. CI: markdownlint, lychee, gitleaks con azioni fissate per SHA.

## ⚖️ Licenza

- Port coreboot (`coreboot/`): **GPL-2.0-only**, testo in [`LICENSE`](LICENSE).
- Dump hardware e tabelle ACPI decompilate: non coperti dalla GPL, diritti dei
  rispettivi titolari; seriali e UUID oscurati.
- Dettagli, file esclusi e marchi: [`NOTICE.md`](NOTICE.md).
