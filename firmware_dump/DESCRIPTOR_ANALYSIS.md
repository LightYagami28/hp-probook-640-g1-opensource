# Analisi Intel Flash Descriptor & Mappatura SPI Flash

## Chip SPI Flash
- **Capacità totale**: 16 MB (16.384 KB / 134.217.728 bit)
- **Controller Host**: Intel Lynx Point PCH (Series 8) SPI Controller
- **Frequenza SPI**: 50 MHz (Fast Read Dual Output supportato)
- **Driver Linux Kernel**: `intel-spi` (`/dev/mtd0`)

## Mappa delle Regioni (Intel Flash Descriptor Layout)

| Regione | Nome | Indirizzo Iniziale | Indirizzo Finale | Dimensione | Permessi Host CPU (Originale) | Permessi Host CPU (Sbloccato) |
|---|---|---|---|---|---|---|
| **0** | **Flash Descriptor (IFD)** | `0x00000000` | `0x00000FFF` | 4 KB | Read: **SI** / Write: **NO** | Read: **SI** / Write: **SI** |
| **3** | **GbE (Gigabit Ethernet)** | `0x00001000` | `0x00002FFF` | 8 KB | Read: **SI** / Write: **SI** | Read: **SI** / Write: **SI** |
| **2** | **Intel ME (Management Engine)** | `0x00003000` | `0x007FFFFF` | 8.180 KB (~8 MB) | Read: **NO** / Write: **NO** | Read: **SI** / Write: **SI** |
| **1** | **BIOS Region (UEFI/Coreboot)** | `0x00800000` | `0x00FFFFFF` | 8.192 KB (8.0 MB) | Read: **SI** / Write: **SI** | Read: **SI** / Write: **SI** |

## Tabella Flash Masters & Maschere di Accesso

### Originale HP (Lock di fabbrica)
```text
FLMSTR1 (Host CPU / BIOS): 0x0a0b0000
  Flash Descriptor Access: Read: SI  | Write: NO
  BIOS Region Access:     Read: SI  | Write: SI
  Intel ME Region Access:  Read: NO  | Write: NO
  GbE Region Access:       Read: SI  | Write: SI

FLMSTR2 (Intel ME):        0x0c0d0000
  Flash Descriptor Access: Read: SI  | Write: NO
  BIOS Region Access:     Read: NO  | Write: NO
  Intel ME Region Access:  Read: SI  | Write: SI
  GbE Region Access:       Read: SI  | Write: SI

FLMSTR3 (GbE Controller): 0x08080118
  GbE Region Access:       Read: SI  | Write: SI
```

### Sbloccato (`flash_descriptor_unlocked.bin`)
Generato con `ifdtool -u`:
```text
FLMSTR1 (Host CPU / BIOS): 0xffff0000 (100% UNLOCKED)
  Flash Descriptor Access: Read: SI  | Write: SI
  BIOS Region Access:     Read: SI  | Write: SI
  Intel ME Region Access:  Read: SI  | Write: SI
  GbE Region Access:       Read: SI  | Write: SI
```
Con questo descrittore sbloccato, l'host CPU può leggere e scrivere l'intera memoria SPI da 16 MB.
