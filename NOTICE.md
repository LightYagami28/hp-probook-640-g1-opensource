# NOTICE — licenze e diritti

Questo repository contiene materiali con titolari e licenze diversi. Leggere questo file prima di riusare o ridistribuire qualcosa.

## 1. Port coreboot (`coreboot/`)
- I file sorgente in `coreboot/` sono scritti per essere integrati nell'albero di coreboot e portano l'intestazione `SPDX-License-Identifier: GPL-2.0-only`.
- Licenza: **GNU General Public License v2.0 only** (testo integrale in [`LICENSE`](LICENSE)), la stessa usata dal progetto coreboot per le mainboard.
- Chi distribuisce un'immagine `coreboot.rom` compilata da questi file deve rispettare la GPL-2.0 (in particolare la sezione 3: sorgente corrispondente disponibile).

## 2. File proprietari NON inclusi
Per tutelare i diritti dei titolari, i seguenti file **non sono più presenti nel ramo principale** e non devono essere ricaricati:

| File rimosso | Contenuto | Titolare |
|---|---|---|
| `firmware_dump/bios_region.bin` | Immagine del BIOS UEFI di fabbrica | HP Inc. e fornitori (Intel, AMI/Insyde, ecc.) |
| `firmware_dump/gbe_region.bin` | Regione GbE Intel (contiene il MAC del dispositivo) | Intel Corporation / dato del dispositivo |
| `firmware_dump/flash_descriptor.bin`, `flash_descriptor_unlocked.bin` | Descrittore Intel della flash SPI del dispositivo | Intel Corporation / HP Inc. |
| `coreboot/data.vbt` | Video BIOS Table Intel | Intel Corporation |

Ognuno deve estrarre questi file **dal proprio** dispositivo (vedi `security_and_flashing/FLASHING_GUIDE.md` e la sezione «File da estrarre in locale» del README) e conservarli solo in locale. Il `.gitignore` li esclude.

Nota: i file restano nella **cronologia git** dei commit precedenti. La loro rimozione dalla cronologia richiede una riscrittura (decisione separata del titolare del repository).

## 3. Dump e analisi hardware (`hardware_topology/`, `acpi/`, `firmware_dump/DESCRIPTOR_ANALYSIS.md`)
- `hardware_topology/*.txt` sono output di strumenti (`dmidecode`, `lspci`, `inteltool`, `superiotool`) sul dispositivo dell'autore. Numeri di serie, UUID e numeri di serie dei dispositivi PCI sono stati **oscurati** (`[OSCURATO]`).
- `acpi/*.dsl` sono tabelle ACPI del firmware HP decompilate con `iasl`: il contenuto originario appartiene a HP Inc. e ai suoi fornitori. Sono pubblicate solo come riferimento tecnico per l'interoperabilità e **non sono coperte dalla licenza GPL-2.0** di questo repository.

## 4. Documentazione
README, guide e analisi scritte dall'autore: licenza **[DA COMPILARE: scegliere la licenza della documentazione, es. CC BY 4.0 oppure GPL-2.0-only come il codice]**.

## 5. Marchi
HP, ProBook, Intel e gli altri nomi citati sono marchi dei rispettivi titolari. Il progetto non è affiliato né approvato da HP Inc. o Intel Corporation.
