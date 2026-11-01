# 04 — Controller Bluetooth Broadcom BCM20702A0 (0a5c:21f1)

## 1. Dati Hardware
* **Dispositivo**: Broadcom Corp. BCM20702A0 Bluetooth 4.0
* **USB VID:PID**: `0a5c:21f1` (Subsystem `103c:17e2`)
* **Bus**: USB 2.0 (Porta interna del Lynx Point PCH)
* **Moduli Kernel Linux**: `btusb`, `btbcm`, `bluetooth`

---

## 2. Architettura del Firmware & Protocollo HCD
Il controller Broadcom BCM20702A0 integra una ROM minimale di avvio. Per abilitare la radio Bluetooth Low Energy (BLE 4.0), correggere i bug di clock e applicare le tabelle di calibrazione RF, il driver del kernel `btbcm` deve inviare comandi vendor-specific HCI per caricare una patch nella RAM volatile del chip:

* **Formato file patch**: Broadcom Hex Command Data (`.hcd`)
* **Nome file di destinazione**: `/usr/lib/firmware/brcm/BCM20702A1-0a5c-21f1.hcd`
* **Versione build risultante**: Build 1765

### Sequenza di Inizializzazione USB
1. Riconoscimento periferica con VID:PID iniziale `0a5c:21f1`.
2. Invio comando vendor HCI `HCI_VSC_DOWNLOAD_MINIDRIVER` (`0xfc2e`).
3. Stream sequenziale di pacchetti HCI vendor command contenenti i chunk della patch RAM.
4. Invio comando `HCI_VSC_LAUNCH_RAM` (`0xfc4e`).
5. Reset del dispositivo: il controller si ripresenta con il firmware Build 1765 pienamente operativo.

---

## 3. Configurazione Stack BlueZ (`config/main.conf`)
Il file [`config/main.conf`](config/main.conf) (`/etc/bluetooth/main.conf`) garantisce l'attivazione automatica dell'adattatore all'avvio del sistema:
```ini
[General]
AutoEnable=true
```

---

## 4. Verifica dello Stato Operativo
```bash
# Verifica del caricamento patch RAM nei log kernel:
dmesg | grep -i -E "bluetooth|bcm20702"
# btbcm: BCM20702A1 (001.002.014) build 1765
# Bluetooth: BCM20702A1 'BCM20702A1-0a5c-21f1.hcd' successfully loaded

# Controllo controller con bluetoothctl:
bluetoothctl show
```
