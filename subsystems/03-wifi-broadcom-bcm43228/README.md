# 03 — Scheda Wi-Fi Broadcom BCM43228 Dual-Band (14e4:4359)

## 1. Dati Hardware
* **PCI ID**: `14e4:4359`
* **Subsystem**: `103c:17e2`
* **Chipset**: Broadcom Corporation BCM43228 802.11a/b/g/n (2.4 GHz e 5.0 GHz)
* **Bus**: PCI Express x1 (Porta PCIe #8 del PCH Lynx Point HM87)

---

## 2. Analisi Conflitti Driver Kernel
Nel kernel Linux standard sono presenti molteplici driver legacy che tentano di agganciare il controller Broadcom in modo incompleto:
1. `b43` / `b43legacy`: non supportano il core PHY della variante BCM43228, causando il blocco del dispositivo.
2. `bcma`: bus driver che tenta l'inizializzazione del chip ma non fornisce connettività 5 GHz affidabile.
3. `brcmsmac`: supporto sperimentale privo di calibrazione RF su questa revisione.

Il driver stabile è il modulo `wl` compilato tramite DKMS (`broadcom-wl-dkms`).

---

## 3. Configurazione Blacklist (`modprobe.d/broadcom-wl-blacklist.conf`)
Il file [`modprobe.d/broadcom-wl-blacklist.conf`](modprobe.d/broadcom-wl-blacklist.conf) deve essere posizionato in `/etc/modprobe.d/` per inibire i moduli concorrenti:
```text
blacklist b43
blacklist b43legacy
blacklist ssb
blacklist bcm43xx
blacklist brcm80211
blacklist brcmsmac
blacklist bcma
```

---

## 4. Verifica dello Stato Operativo
```bash
# Verifica del driver kernel attivo sulla scheda:
lspci -k -s 04:00.0
# Kernel driver in use: wl
# Kernel modules: bcma, wl

# Scansione reti wireless attive:
nmcli dev wifi list
```
