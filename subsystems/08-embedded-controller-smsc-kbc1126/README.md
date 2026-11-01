# 08 — Embedded Controller SMSC KBC1126 / MEC1322 (KBC Version 16.3C)

## 1. Dati Hardware
* **Chip EC**: SMSC KBC1126 / MEC1322 (Microcontrollore 8051 con memoria on-chip)
* **Versione Firmware OEM**: `KBC Version 16.3C`
* **Interfaccia Host**: LPC Bridge (Intel Lynx Point HM87 PCH)
* **Porte I/O di Comando & Dati**:
  - Dati: `0x0062`
  - Stato / Comando: `0x0066`
* **Porte Mailbox I/O Aggiuntive**: `0x0200` e `0x0201` (`MAIO` in DSDT)
* **General Purpose Event (GPE)**: `_GPE 0x16` (22 decimale, instradato via `gpi6_routing = 2` al Southbridge)

---

## 2. Reverse Engineering dei Registri EC (`OperationRegion ECRM`)
Dalla decompilazione del DSDT OEM (blocco integrale in [`asl/ec0_complete.asl`](asl/ec0_complete.asl)):

| Offset | Dimensione | Campo | Significato / Funzione |
|---|---|---|---|
| `0x00` | 32 bit | `PMCD` | Power Management Control Data |
| `0x04` | 8 bit | `S0FL` | Flag di stato operativo S0 |
| `0x07` | 16 bit | `CPWR` | Potenza assorbita istantanea (mW) |
| `0x09` | 16 bit | `CVLT` | Tensione attuale della batteria (mV) |
| `0x0B` | 16 bit | `CCUR` | Corrente di carica/scarica istantanea (mA) |
| `0x22` | 8 bit | `CRZN` | ID Zona Termica attiva |
| `0x23` | 8 bit | `THTA` | Soglia di allarme temperatura (°C) |
| `0x24` | 8 bit | `HYST` | Isteresi termica (°C) |
| `0x25` | 8 bit | `CRIT` | Soglia critica di arresto immediato (°C) |
| `0x26` | 8 bit | `TEMP` | Lettura sensore temperatura istantanea (°C) |
| `0x2E` | 8 bit | `FRDC` | Fan Read Count (tachimetro giri ventola) |
| `0x2F` | 8 bit | `FTGC` | Fan Target Count (impostazione PWM ventola) |
| `0x40..0x45` | 48 bit | `ABDI..ABST` | Advanced Battery Interface (SBS 1.1) |
| `0x81` | 4 bit | `SLPT` | Transizione stati sleep (S3, S4, S5) |
| `0x81.2` | 1 bit | `ACPI` | Flag modalità ACPI abilitata |

---

## 3. Gestione Eventi e Metodi di Query (`_Qxx`)
* `_Q03`: Notifica pulsante di alimentazione / dock
* `_Q06`: Cambio alimentazione rete AC (`Notify (\_SB.AC, 0x80)`)
* `_Q08`: Notifica aggiornamento dati batteria `BAT0` (`Notify (\_SB.BAT0, 0x81)`)
* `_Q09`: Cambio stato carica batteria `BAT0` (`Notify (\_SB.BAT0, 0x80)`)
* `_Q0A`: Rilevamento apertura/chiusura coperchio (`Notify (\_SB.LID, 0x80)`)
* `_Q05` & `_Q0C`: Allarme superamento soglia termica (`\_TZ.ECTE`)
* `_Q20`: Hotkey hardware / switch Wi-Fi propagati a HP WMI (`\_SB.WMID.WGWE`)

---

## 4. Driver Coreboot Corrispondente
In Coreboot, l'EC è gestito dal modulo `src/ec/hp/kbc1126`:
* File di configurazione in `coreboot/devicetree.cb`:
  ```text
  chip ec/hp/kbc1126
      register "ec_data_port" = "0x62"
      register "ec_cmd_port"  = "0x66"
      register "ec_ctrl_reg"  = "0x81"
      register "ec_fan_ctrl_value" = "0x6b"
      device pnp ff.1 off end
  end
  ```
