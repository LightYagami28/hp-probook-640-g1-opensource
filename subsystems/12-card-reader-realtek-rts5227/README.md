# 12 — Lettore Schede SD Realtek RTS5227 (10ec:5227)

## 1. Dati Hardware
* **PCI ID**: `10ec:5227` (Realtek Semiconductor Co., Ltd. RTS5227 PCI Express Card Reader)
* **Subsystem**: `103c:1993`
* **Bus**: PCI Express x1 (Porta PCIe #7 del PCH Lynx Point HM87)
* **Driver Linux**: `rtsx_pci` (controller hardware bus) e `rtsx_pci_sdmmc` (interfaccia storage MMC/SD)

---

## 2. Caratteristiche Tecniche & Supporto Standard
* **Standard Supportati**: SDSC, SDHC, SDXC, MMC (capacità massima teorica fino a 2 TB)
* **Bus Speed**: UHS-I SDR104 (velocità di trasferimento fino a 104 MB/s su schede compatibili)
* **Gestione Risparmio Energetico**: supporto hardware agli stati ASPM L1.2 (Active State Power Management) con autosuspend automatico dei clock PCIe quando nessuna scheda è inserita nello slot.

---

## 3. Verifica dello Stato Operativo
```bash
# Ispezione del controller PCI Express:
lspci -vnn -s 03:00.0
# Kernel driver in use: rtsx_pci
# Kernel modules: rtsx_pci

# Verifica moduli caricati:
lsmod | grep rtsx
```
