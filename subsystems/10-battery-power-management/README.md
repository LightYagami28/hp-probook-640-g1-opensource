# 10 — Gestione Batteria & Alimentazione (Smart Battery System SBS 1.1)

## 1. Dati Hardware
* **Batteria Principale (`BAT0`)**: pacco a 6 celle agli ioni di litio (55 Wh / 10.8V nominali)
* **Predisposizione Batteria Secondaria (`BAT1`)**: interfaccia docking station per batteria ausiliaria UltraSlim Slice
* **Alimentatore AC (`AC`)**: HP Smart AC Adapter da 65W o 90W (connettore coassiale 7.4mm con pin centrale smart)

---

## 2. Reverse Engineering del Protocollo Smart Battery (SBS 1.1)
La batteria comunica con l'EC tramite bus SMBus/I2C interno. I dati vengono esposti al sistema operativo tramite i campi ACPI dell'Embedded Controller (`ABDI`, `ABAD`, `ABIX`, `ABDA`, `ABST`):

* `_STA` (Status): verifica la presenza fisica del modulo batteria (`0x1F` = presente, integro e alimentato).
* `_BIF` / `_BIX` (Battery Information): esporta capacità di fabbrica (Design Capacity), capacità a piena carica (Last Full Charge Capacity), chimica delle celle (Li-Ion), tensione di progetto e numero seriale.
* `_BST` (Battery Status): riporta in tempo reale lo stato (carica, scarica, idle), il rate di scarica in mA/mW, la capacità residua e la tensione attuale misurata ai morsetti.

### Handshake Smart AC Pin (1-Wire)
Il pin centrale dell'alimentatore HP invia un segnale di tensione di riferimento resistivo letto dall'EC:
* Tensione ~1.5V: identificato alimentatore originale HP da 65W.
* Tensione ~2.1V: identificato alimentatore HP da 90W.
* Pin sconnesso/generico: l'EC limita la velocità di ricarica per proteggere i MOSFET della scheda madre.

---

## 3. Verifica dello Stato Operativo
```bash
# Ispezione dati energetici via UPower:
upower -i $(upower -e | grep BAT)

# Lettura attributi sysfs della batteria:
cat /sys/class/power_supply/BAT0/uevent
```
