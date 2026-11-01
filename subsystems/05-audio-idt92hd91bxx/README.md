# 05 — Sottosistema Audio IDT 92HD91BXX & Intel Haswell HDMI

## 1. Dati Hardware
* **Controller HDA**: Intel Corporation 8 Series/C220 Series Chipset High Definition Audio (`8086:8c20`, Subsystem `103c:1993`)
* **Codec Audio Analogico**: IDT 92HD91BXX (`111d:76e0`, Subsystem `103c:2105`, Rev `0x100303`)
* **Codec Audio Digitale**: Intel Haswell HDMI Audio (`8086:2807`, Subsystem `8086:0101`)

---

## 2. Reverse Engineering dei Nodi Azalia & Verb Table
Dall'estrazione dei registri ALSA in [`dumps/codec_idt92hd91bxx.txt`](dumps/codec_idt92hd91bxx.txt) e [`dumps/init_pin_configs.txt`](dumps/init_pin_configs.txt):

| Nodo | Funzione Fisica | Configurazione Pin (`Pin Default`) | Proprietà & Jack Sensing |
|---|---|---|---|
| **0x0a** | Line Out Posteriore / Dock | `0x21011030` | Jack stereo da 3.5mm sul retro dock |
| **0x0b** | Cuffie Frontali / Combo Jack | `0x0321101f` | Rilevamento presenza jack (Jack Detect) |
| **0x0c** | Ingresso Microfono Esterno | `0x03a11020` | Rilevamento jack mic |
| **0x0d** | Altoparlanti Stereo Interni | `0x90170110` | Amplificatore EAPD abilitato |
| **0x0f** | Line In Docking Station | `0x2181102e` | Ingresso linea dock |
| **0x11** | Microfono Digitale Integrato | `0xd5a30140` | Array microfoni interni display |

### Tabella Verb C per Coreboot (`coreboot/hda_verb.c`)
I comandi verb di inizializzazione per il firmware sono inclusi nel file `coreboot/hda_verb.c`:
```c
const u32 cim_verb_data[] = {
    0x111d76e0,    /* ID Codec IDT */
    0x103c2105,    /* Subsystem ID */
    11,            /* Numero di set da 4 dword */
    AZALIA_SUBVENDOR(0, 0x103c2105),
    AZALIA_PIN_CFG(0, 0x0a, 0x21011030),
    AZALIA_PIN_CFG(0, 0x0b, 0x0321101f),
    AZALIA_PIN_CFG(0, 0x0c, 0x03a11020),
    AZALIA_PIN_CFG(0, 0x0d, 0x90170110),
    AZALIA_PIN_CFG(0, 0x0e, 0x40f000f0),
    AZALIA_PIN_CFG(0, 0x0f, 0x2181102e),
    AZALIA_PIN_CFG(0, 0x10, 0x40f000f0),
    AZALIA_PIN_CFG(0, 0x11, 0xd5a30140),
    AZALIA_PIN_CFG(0, 0x1f, 0x40f000f0),
    AZALIA_PIN_CFG(0, 0x20, 0x40f000f0),
};
```

---

## 3. Verifica dello Stato Operativo
```bash
# Ispezione schede audio riconosciute dal kernel:
cat /proc/asound/cards

# Controllo endpoint e volumi PipeWire:
wpctl status
```
