# 11 — Storage SATA AHCI, Unità Ottica & Accelerometro HP 3D DriveGuard

## 1. Dati Hardware
* **Controller SATA**: Intel Corporation 8 Series/C220 Series Chipset Family 6-port SATA Controller [AHCI mode] (`8086:8c03`, Subsystem `103c:1993`)
  - Porta 0: alloggiamento interno 2.5" SATA III a 6 Gbps (`/dev/sda`)
  - Porta 1: masterizzatore ottico slimline HP DVD-RAM UJ8DB (`/dev/sr0`, ATAPI)
* **Accelerometro 3D**: STMicroelectronics LIS3LV02DL (HP 3D DriveGuard)
  - Driver Linux: `hp_accel` e `lis3lv02d`
  - Nodi sysfs/dev: `/dev/freefall` e `/sys/devices/faux/lis3lv02d/position`

---

## 2. Ottimizzazione I/O Storage Meccanico (`udev/60-ioschedulers.rules`)
Per garantire fluidità e prevenire blocchi dell'interfaccia su hard disk meccanici rotazionali (5400 RPM), la regola udev [`udev/60-ioschedulers.rules`](udev/60-ioschedulers.rules) attiva in automatico lo scheduler BFQ:
```udev
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
```

---

## 3. Reverse Engineering dell'Accelerometro Anti-Caduta
Il sensore LIS3LV02DL è collegato internamente al bus ACPI/I2C dell'Embedded Controller. Quando il modulo `hp_accel` rileva un'accelerazione vicina a $0\,\text{m/s}^2$ su tutti e 3 gli assi (caduta libera), genera un interrupt istantaneo inviando il comando ATA `IDLE IMMEDIATE` con il flag di scaricamento delle testine (head parking) per evitare danni ai piatti magnetici del disco fisso prima dell'urto.

---

## 4. Verifica dello Stato Operativo
```bash
# Lettura posizione spaziale istantanea (assi X, Y, Z):
cat /sys/devices/faux/lis3lv02d/position
# (18, 0, 1098)

# Verifica dello scheduler attivo su sda:
cat /sys/block/sda/queue/scheduler
# mq-deadline [bfq] kyber none
```
