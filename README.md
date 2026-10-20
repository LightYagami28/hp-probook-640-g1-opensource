# HP ProBook 640 G1 Open-Source Firmware & Hardware Porting Project

Progetto completo di reverse engineering, dump hardware/firmware e porting open-source a **Coreboot** per il portatile **HP ProBook 640 G1**.

Tutti i componenti proprietari, le mappature hardware, i registri del chipset, i descrittori SPI e le tabelle ACPI sono stati estratti, decodificati e documentati per rendere l'intera piattaforma trasparente, modificabile e sbloccata.

---

## 💻 Scheda Tecnica della Macchina Target

| Componente | Specifiche Rilevate |
|---|---|
| **Modello** | HP ProBook 640 G1 (Subsystem ID: `103c:1993`) |
| **Processore** | Intel Core i5-4210M @ 2.60GHz (Haswell Mobile, 2 core / 4 thread) |
| **Northbridge** | Haswell Host Bridge (`8086:0c04`) |
| **Southbridge / Chipset** | Intel HM87 Lynx Point PCH (`8086:8c4b`) |
| **Grafica Integrata** | Intel HD Graphics 4600 (`8086:0416`) |
| **Embedded Controller (EC)** | SMSC KBC1126 / MEC1322 compatibile (KBC Ver. `16.3C`, I/O `0x62`/`0x66`, GPE `0x16`) |
| **Audio Codec** | IDT 92HD91BXX (`111d:76e0`, Subsystem `103c:2105`) + Intel Haswell HDMI |
| **Wi-Fi** | Broadcom BCM43228 802.11a/b/g/n (`14e4:4359`) |
| **Ethernet** | Intel Gigabit Ethernet I217-LM (`8086:153b`) |
| **SD Card Reader** | Realtek RTS5227 PCI-E Card Reader (`10ec:5227`) |
| **Fingerprint Reader** | Validity Sensors VFS495 (`138a:003f`) |
| **Chip Flash SPI** | 16 MB (16.384 KB) collegato via Intel PCH SPI Sequencer |
| **Firmware OEM di Fabbrica** | HP UEFI BIOS L77 Ver. 01.43 (01/25/2018) |

---

## 📂 Struttura del Repository

```text
├── coreboot/                      # Porting completo per Coreboot (src/mainboard/hp/probook_640_g1)
│   ├── Kconfig                   # Opzioni di configurazione Kconfig della scheda
│   ├── Kconfig.name              # Dichiarazione modello scheda nel menu Coreboot
│   ├── Makefile.mk               # Regole di compilazione ramstage/romstage/bootblock
│   ├── devicetree.cb             # Albero periferiche PCH, EC, PCI e bus mapping
│   ├── gpio.c                    # Configurazione completa registri GPIO Set 1, 2, 3
│   ├── hda_verb.c                # Pin verb tables Azalia per codec IDT 92HD91BXX
│   ├── romstage.c                # Inizializzazione precoce memoria e routing porte USB
│   ├── bootblock.c               # Configurazione bootblock
│   ├── acpi_tables.c             # Riempimento GNVS ACPI
│   ├── dsdt.asl                  # DSDT master ASL Coreboot
│   ├── data.vbt                  # Video BIOS Table Intel estratto direttamente dal driver i915
│   └── acpi/                     # Sotto-tabelle ACPI (ec.asl, platform.asl, superio.asl)
│
├── firmware_dump/                 # Dump fisici estratti dal chip SPI da 16 MB
│   ├── flash_descriptor.bin      # Descrittore Intel originale (4 KB, protetto in scrittura)
│   ├── flash_descriptor_unlocked.bin # Descrittore Intel 100% SBLOCCATO (Master RW mask 0xFFFF)
│   ├── gbe_region.bin            # Regione GbE Intel (8 KB, configurazione LAN e MAC)
│   ├── bios_region.bin           # Immagine completa BIOS UEFI HP (8 MB)
│   └── DESCRIPTOR_ANALYSIS.md    # Analisi tecnica dettagliata delle regioni SPI e permessi
│
├── acpi/                          # Tabelle ACPI del BIOS OEM decompilate in ASL (.dsl)
│   ├── dsdt.dsl                  # DSDT completo (1.041.309 byte, oltre 15.000 righe di ASL)
│   ├── ssdt1.dsl - ssdt9.dsl     # Tutte le 9 tabelle SSDT secondarie (SpeedStep, C-States, ecc.)
│   └── *.dat                     # File binari estratti da ACPI
│
├── hardware_topology/             # Mappe registri e architettura hardware
│   ├── lspci_verbose.txt         # Dump esaustivo registri di configurazione PCI (spazi di tutti i device)
│   ├── pci_tree.txt              # Gerarchia grafica ad albero dei bus PCI Express
│   ├── dmidecode.txt             # Dump SMBIOS completo (memoria, sensori, slot, connettori)
│   ├── superiotool_dump.txt      # Mappatura registri chip Super I/O SMSC / Microchip
│   ├── gpio.txt                  # Registri GPIO PCH estratti via porta I/O (inteltool)
│   └── pmbase.txt                # Registri Power Management (PMBASE) PCH
│
└── security_and_flashing/         # Guida sicurezza hardware e procedura flash
    └── FLASHING_GUIDE.md         # Spiegazione blocchi Intel PRx/SMM e guida flasher CH341A
```

---

## 🚀 Come Compilare Coreboot per HP ProBook 640 G1

Il porting è già predisposto nella directory `coreboot/` e compatibile con l'albero master di Coreboot.

### 1. Clonare Coreboot
```bash
git clone https://review.coreboot.org/coreboot.git
cd coreboot
```

### 2. Installare il port della mainboard
Copiare i file del port all'interno del percorso standard di Coreboot:
```bash
cp -r /path/to/hp-probook-640-g1-opensource/coreboot src/mainboard/hp/probook_640_g1
```

### 3. Configurare la build
Creare o generare la configurazione selezionando il vendor `HP` e la mainboard `ProBook 640 G1`:
```bash
echo -e "CONFIG_VENDOR_HP=y\nCONFIG_BOARD_HP_PROBOOK_640_G1=y" > .config
make olddefconfig
```

### 4. Compilazione
```bash
make crossgcc-i386 CPUS=$(nproc)
make
```
Il binario risultante `build/coreboot.rom` conterrà il payload (es. SeaBIOS, TianoCore EDK2 o LinuxBoot) con inizializzazione nativa di grafica Haswell tramite `libgfxinit` e gestione dell'Embedded Controller HP.

---

## 🛡️ Sicurezza Hardware e Flashing (Safe Coding)
- **Zero Rischio Attuale**: Nessuna scrittura distruttiva è stata eseguita sulla memoria non volatile del laptop.
- **Preparazione Completa**: Tutti i dump necessari al ripristino o alla compilazione sono al sicuro in questo repository.
- **Prossimo Passo Hardware**: Quando vorrai installare Coreboot sulla scheda madre fisica, sarà sufficiente utilizzare un programmatore esterno da pochi euro (es. CH341A con clip SOIC-8) per eseguire il primo flash senza alcun rischio di brick, come descritto in [`security_and_flashing/FLASHING_GUIDE.md`](security_and_flashing/FLASHING_GUIDE.md).
