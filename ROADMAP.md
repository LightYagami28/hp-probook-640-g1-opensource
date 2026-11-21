# Roadmap

Stato aggiornato al 2026-11-21. I limiti noti del port sono in [SPEC.md](SPEC.md).

## Stato attuale

Mappatura dei 15 sottosistemi, estrazione e decompilazione delle tabelle ACPI, dump della topologia hardware, analisi del descrittore SPI, script del lettore di impronte VFS495 con test automatici.

Verifiche eseguite sul repository:

- `python3 -m pytest -q`: 22 test superati, 0 errori, 0 warning.
- `ruff check .`: tutti i controlli superati, 0 errori (ordinamento degli import corretto).
- `npx --yes markdownlint-cli2 "**/*.md"`: 47 file, 0 problemi.

## Obiettivi

- Rendere il port coreboot compilabile e verificabile in modo riproducibile.
- Mantenere la documentazione hardware accurata e priva di dati proprietari non autorizzati.
- Mantenere zero errori e zero warning nei controlli automatici.

## Prossimi passi

1. **Compilare il port su coreboot 26.09.** Oggi non è mai stato compilato: aspettarsi errori di API da correggere (vedi [docs/sviluppo.md](docs/sviluppo.md)).
2. **Estrarre `data.vbt`** dalla macchina reale: non è inclusa nel repository (vedi [NOTICE.md](NOTICE.md)).
3. **Flash in-circuit** con payload SeaBIOS e validazione dell'avvio Linux con la sola inizializzazione grafica nativa, seguendo [guida al flashing](security_and_flashing/FLASHING_GUIDE.md).
4. **Neutralizzazione di Intel ME** nell'immagine finale, secondo l'analisi del descrittore in [analisi SPI](firmware_dump/DESCRIPTOR_ANALYSIS.md).
