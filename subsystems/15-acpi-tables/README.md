# 15 — Tabelle ACPI OEM Complete (DSDT & SSDT 1..9)

## 1. Panoramica
Questa sezione contiene il dump completo e il disassemblato ASL (`.dsl`) di tutte le tabelle ACPI originali del BIOS UEFI HP L77 Ver. 01.43 decompilate tramite `iasl -d`.

---

## 2. Elenco Tabelle Decompilate (`dsl/`)
1. [`dsl/dsdt.dsl`](dsl/dsdt.dsl) (30.323 righe): Differentiated System Description Table master. Contiene l'albero completo dei dispositivi (`\_SB.PCI0`), l'Embedded Controller `EC0`, la gestione termica `\_TZ`, i metodi di transizione energetica `_PTS` / `_WAK` e l'interfaccia WMI di HP.
2. [`dsl/ssdt1.dsl`](dsl/ssdt1.dsl) (`SataAhci`): metodi di power management per il controller SATA.
3. [`dsl/ssdt2.dsl`](dsl/ssdt2.dsl) (`PtidDevc`): Intel Power and Thermal Information Device.
4. [`dsl/ssdt3.dsl`](dsl/ssdt3.dsl) (`Cpu0Ist`): tabelle P-States Intel SpeedStep per il Core 0 della CPU.
5. [`dsl/ssdt4.dsl`](dsl/ssdt4.dsl) (`CpuPm`): configurazione C-States e risparmio energetico CPU.
6. [`dsl/ssdt5.dsl`](dsl/ssdt5.dsl) (`LakeTiny`): algoritmi Intel LakeTiny per caching I/O SSD.
7. [`dsl/ssdt6.dsl`](dsl/ssdt6.dsl) (`SaSsdt`): System Agent SSDT (inizializzazione grafica integrata Haswell, audio HDMI e controller memoria).
8. [`dsl/ssdt7.dsl`](dsl/ssdt7.dsl) (`Cpu0Cst`): tabelle C-States avanzate per Core 0.
9. [`dsl/ssdt8.dsl`](dsl/ssdt8.dsl) (`ApIst`): tabelle P-States per i core logici ausiliari (Application Processors).
10. [`dsl/ssdt9.dsl`](dsl/ssdt9.dsl) (`ApCst`): tabelle C-States per i core ausiliari.

---

## 3. Utilizzo per lo Sviluppo di Coreboot
Queste tabelle costituiscono la "ground truth" hardware del portatile. Durante la stesura del codice Coreboot (`coreboot/dsdt.asl` e `coreboot/devicetree.cb`), i riferimenti a GPIO, routing degli interrupt e comandi dell'EC sono stati ricavati direttamente dalla decodifica di queste tabelle.
