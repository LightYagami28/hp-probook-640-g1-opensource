# Glossario

| Termine | Significato |
| --- | --- |
| coreboot | Firmware libero che sostituisce il BIOS/UEFI del produttore. |
| SeaBIOS / EDK2 | Payload che coreboot avvia dopo l'inizializzazione dell'hardware. |
| PCH | Chipset di piattaforma Intel (qui HM87 Lynx Point). |
| Descrittore SPI | Struttura all'inizio del chip flash che divide la memoria in regioni (descrittore, BIOS, ME, GbE). |
| Intel ME | Motore di gestione integrato nel chipset, con firmware proprietario. |
| EC | Embedded controller: tastiera, batteria, ventole (qui SMSC KBC1126). |
| DSDT / SSDT | Tabelle ACPI che descrivono l'hardware al sistema operativo. |
| ASL / DSL | Linguaggio sorgente delle tabelle ACPI. |
| VBT | Tabella del BIOS video Intel con la configurazione dello schermo. |
| Verb table | Comandi di configurazione dei pin del codec audio HDA. |
| flashrom | Programma per leggere e scrivere i chip flash SPI. |
| serprog | Protocollo di programmatore SPI seriale (usato con Raspberry Pi Pico). |
| VFS495 | Lettore di impronte Validity Sensors presente nel portatile. |
