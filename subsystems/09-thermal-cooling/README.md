# 09 — Gestione Termica & Raffreddamento (Thermal Zones & Fan Control)

## 1. Dati Hardware
* **Sensori CPU**: Intel Digital Thermal Sensors (DTS) integrati nei core Haswell
* **Sensori Scheda & PCH**: Monitorati direttamente dall'EC SMSC KBC1126
* **Ventola**: Ventola brushless a 4 pin controllata in PWM e tachimetrata

---

## 2. Reverse Engineering delle Zone Termiche ACPI (`\_TZ`)
Nel DSDT originale (blocco estratto in [`asl/thermal_zones.asl`](asl/thermal_zones.asl)) sono definite 8 zone termiche indipendenti:
1. `\_TZ.CPUZ`: temperatura del die del processore Intel Haswell (Core 0 e Core 1)
2. `\_TZ.GFXZ`: temperatura del processore grafico Intel HD 4600
3. `\_TZ.PCHZ`: temperatura del silicio Intel Lynx Point HM87
4. `\_TZ.BATZ`: temperatura interna del pacco batterie
5. `\_TZ.LOCZ`: temperatura ambiente sulla scheda madre (zona VRM alimentazione)
6. `\_TZ.EXTZ`: sensore termico ausiliario per connettore docking station
7. `\_TZ.DM1Z` & `\_TZ.DM2Z`: sensori termici dei due banchi SO-DIMM DDR3L

---

## 3. Curve di Intervento & Controllo Ventola
Nel firmware Coreboot (`coreboot/acpi_tables.c`) e nelle tabelle OEM:
* **Temperatura Critica di Spegnimento (`tcrt`)**: 100°C (spegnimento hardware istantaneo per salvaguardare il silicio).
* **Temperatura di Throttling Passivo (`tpsv`)**: 90°C (riduzione frequenza e tensione del processore tramite P-States).
* **Algoritmo Ventola**: l'EC calcola l'errore termico ogni 500 ms e aggiorna il valore target `FTGC`. La velocità reale di rotazione viene letta dal registro `FRDC`.

---

## 4. Verifica dello Stato Operativo
```bash
# Lettura istantanea delle zone termiche da sysfs:
paste <(cat /sys/class/thermal/thermal_zone*/type) <(cat /sys/class/thermal/thermal_zone*/temp | awk '{print $1/1000 " °C"}')

# Stato del demone di controllo termico attivo:
systemctl status thermald.service
```
