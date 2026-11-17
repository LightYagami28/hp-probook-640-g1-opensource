# Roadmap

Stato al 2026-11-16. I limiti noti del port sono in [SPEC.md](SPEC.md).

## Prossimi passi

1. **Compilare il port su coreboot 26.09.** Oggi non è mai stato compilato: aspettarsi errori di
   API da correggere (vedi [docs/sviluppo.md](docs/sviluppo.md)).
2. **Estrarre `data.vbt`** dalla macchina reale: non è inclusa nel repository (vedi
   [NOTICE.md](NOTICE.md)).
3. **Flash in-circuit** con payload SeaBIOS e validazione dell'avvio Linux con la sola
   inizializzazione grafica nativa, seguendo [security_and_flashing/FLASHING_GUIDE.md](security_and_flashing/FLASHING_GUIDE.md).
4. **Neutralizzazione di Intel ME** nell'immagine finale, secondo l'analisi del descrittore in
   [firmware_dump/DESCRIPTOR_ANALYSIS.md](firmware_dump/DESCRIPTOR_ANALYSIS.md).
## Fatto

Mappatura dei 15 sottosistemi, estrazione e decompilazione delle tabelle ACPI, dump della topologia
hardware, analisi del descrittore SPI, script del lettore di impronte VFS495 con test.
