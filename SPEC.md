# SPEC: firmware open source per HP ProBook 640 G1

## Obiettivo

Il progetto è finito quando il port coreboot `hp/probook_640_g1` compila contro
l'ultima release di coreboot senza errori né avvisi, il portatile (Haswell,
chipset HM87) avvia con quel firmware flashato tramite programmatore SPI
esterno, gli esiti sono documentati e la proposta di upstream è stata inviata a
review.coreboot.org.

## Stato attuale verificato

Letto dai file e dalle fonti il 2026-11-11, ramo `main`. Repo pubblico.
Il lavoro è di reverse engineering e porting: il port **non è stato compilato
né provato su hardware** (nessuna immagine compilata o flashata).

| Elemento | Stato | File |
| --- | --- | --- |
| Port coreboot (Kconfig, devicetree, GPIO, verb HDA, romstage, ACPI/GNVS, EC) | scritto, non compilato | `coreboot/` |
| Tabelle ACPI OEM decompilate (DSDT, SSDT 1-9) | presenti | `acpi/`, `subsystems/15-acpi-tables/dsl/` |
| Mappe hardware (PCI, GPIO, PMBASE, Super I/O, SMBIOS con seriali oscurati) | presenti | `hardware_topology/`, `subsystems/14-motherboard-chipset-intel-hm87/dumps/` |
| Analisi del descrittore Intel | presente | `firmware_dump/DESCRIPTOR_ANALYSIS.md` |
| Guida al flashing con programmatore esterno | presente | `security_and_flashing/FLASHING_GUIDE.md` |
| 15 cartelle per componente hardware | presenti | `subsystems/01-...` a `subsystems/15-...` |
| Script Python del lettore di impronte | presenti, con test | `subsystems/02-fingerprint-vfs495/scripts/`, `tests/test_vfs495_scripts.py` |
| Avvertenze su licenze e file esclusi | presenti | `NOTICE.md` |

Versioni e fonti:

| Componente | Versione | Fonte |
| --- | --- | --- |
| coreboot | 26.09 (ultimo tag; verificato il 2026-11-11 con `git ls-remote --tags https://review.coreboot.org/coreboot.git`) | review.coreboot.org |
| Toolchain crossgcc inclusa in coreboot 26.09 | GCC 15.2.0, binutils 2.46.1, IASL 20251212 (verificate il 2026-10-31, da riconfermare) | `util/crossgcc/buildgcc` |
| flashrom | 1.8.0 (verificata il 2026-10-31, da riconfermare) | download.flashrom.org |
| ifdtool | quello di `util/ifdtool` nell'albero coreboot 26.09 | coreboot |
| actions/checkout | v7.0.1 (SHA) | `.github/workflows/ci.yml` |
| markdownlint-cli2-action | v25.0.0 (SHA) | `ci.yml` |
| lychee-action | v2.9.0 (SHA) | `ci.yml` |
| gitleaks-action | v3.0.0 (SHA) | `ci.yml` |
| sonarqube-scan-action | v8.4.1 (SHA) | `ci.yml` |

Esito dei test Python il 2026-11-11: `python -m pytest --cov` esegue 20 test,
tutti superati; coverage del 99% sugli script del lettore di impronte
(`match.py` 98%, 5 righe non coperte).

Incongruenze trovate:

- Il vecchio SPEC non descriveva la cartella `subsystems/` né i test Python.
- `coreboot/Kconfig` seleziona `BOARD_ROMSIZE_KB_12288`, ereditato da
  `hp/folio_9480m`, mentre la regione BIOS analizzata è 8 MB e la flash è
  16 MB.
- `sonar-project.properties` esclude `acpi/**` e `hardware_topology/**` ma non
  le copie in `subsystems/**/dumps` e `subsystems/15-acpi-tables/dsl`.
- La licenza della documentazione è ancora da scegliere (`NOTICE.md`, sezione
  4: segnaposto «DA COMPILARE»).
- `CITATION.cff` riporta l'indirizzo di posta dell'autore: scelta del
  proprietario, non modificata qui.

## Architettura

Dettaglio in [`docs/architettura.md`](docs/architettura.md).

```text
coreboot 26.09
  bootblock -> bootblock.c, gpio.c
  romstage  -> romstage.c, gpio.c         (SPD, mappa porte USB, RAM)
  ramstage  -> devicetree.cb, mainboard.c, hda_verb.c, acpi_tables.c,
               dsdt.asl + acpi/*.asl, gma-mainboard.ads (libgfxinit)
  payload   -> a scelta (SeaBIOS, edk2, LinuxBoot)
```

Piattaforma: CPU Haswell mobile (`northbridge/intel/haswell`), PCH HM87 Lynx
Point (`southbridge/intel/lynxpoint`), EC HP KBC1126 (GPE `0x16`, firmware EC
non in CBFS), audio IDT 92HD91BXX con verb table legacy, grafica Intel HD 4600
con libgfxinit e VBT da fornire. Scheda di riferimento upstream:
`hp/folio_9480m`. Layout flash SPI (16 MB): descrittore 4 KB, GbE 8 KB,
ME circa 8 MB, BIOS 8 MB.

Flussi principali:

1. Backup: lettura 3 volte della flash con flashrom, verifica SHA-256.
2. Estrazione: `ifdtool -x` per le regioni, VBT dal sistema originale.
3. Build: copia di `coreboot/` in `src/mainboard/hp/probook_640_g1`,
   configurazione, `make`.
4. Flash: scrittura della sola regione BIOS con `flashrom --ifd -i bios`.

Dati: file di configurazione coreboot (Kconfig, `devicetree.cb`) e tabelle
statiche (GPIO, verb HDA). Nessun database, nessuna API.

Interfacce hardware: SPI (flash), LPC (EC KBC1126, I/O `0x62`/`0x66`,
GPE `0x16`), HDA (IDT 92HD91BXX), DDI/eDP (libgfxinit).

## Requisiti funzionali

1. Il port compila con l'ultima release di coreboot. Accettazione: in un albero
   coreboot al tag 26.09, con il port copiato in
   `src/mainboard/hp/probook_640_g1`, `make olddefconfig && make` termina con
   codice 0 e produce `build/coreboot.rom`, senza avvisi.
2. La dimensione della ROM corrisponde alla flash. Accettazione: `Kconfig`
   seleziona una dimensione coerente con i 16 MB, `make` non segnala
   incoerenze con il layout `ifdtool`.
3. Il portatile avvia con il firmware flashato. Accettazione: dopo il flash
   della sola regione BIOS con programmatore esterno, il sistema arriva al
   payload; esito scritto in `docs/` con data, versione e log.
4. Il firmware originale è ripristinabile. Accettazione: esiste un backup
   verificato (3 letture identiche, SHA-256 uguali) prima del primo flash e la
   procedura di ripristino è provata.
5. Ogni sottosistema ha una scheda con dati verificabili. Accettazione: ogni
   cartella `subsystems/NN-*/` ha un `README.md`; le affermazioni sull'hardware
   citano un dump in `hardware_topology/` o `subsystems/`, o una tabella ACPI.
6. Gli script del lettore di impronte sono testati. Accettazione:
   `python -m pytest --cov=subsystems/02-fingerprint-vfs495/scripts` passa con
   coverage 100%.
7. I file proprietari non sono nel repository. Accettazione: `data.vbt`, i dump
   `.bin` e le regioni estratte non compaiono in `git ls-files`; gitleaks passa.
8. Documentazione senza errori. Accettazione: `npx markdownlint-cli2
   "**/*.md"` e lychee passano senza avvisi.

## Requisiti non funzionali

- Sicurezza: nessuna scrittura distruttiva sulla flash senza backup verificato;
  nessun blob proprietario, seriale o UUID nel repository (i dump hanno i campi
  oscurati); gitleaks in CI sull'intera storia; Intel ME resta un blob (regione
  2). Dettagli: [`docs/sicurezza.md`](docs/sicurezza.md), `SECURITY.md`.
- Accessibilità: i documenti Markdown hanno titoli ordinati e testo alternativo
  per le immagini (nessuna immagine presente oggi).
- Prestazioni: non applicabili al repository; il firmware deve avviare in un
  tempo documentato a ogni test su hardware (da definire).
- Privacy/GDPR: nessun dato personale. Seriali e UUID dell'esemplare analizzato
  restano oscurati.
- Qualità: coverage 100% sul codice Python, zero avvisi in markdownlint e
  lychee, SonarCloud A/A/A e hotspot A (esclusioni coerenti con i dump
  generati), dipendenze e azioni all'ultima versione.

## Roadmap

1. Compilare il port contro coreboot 26.09 e correggere gli errori di API
   (Haswell/Lynx Point possono essere cambiati dalla scrittura del port).
2. Allineare `BOARD_ROMSIZE_KB_12288` alla dimensione reale della ROM.
3. Primo avvio con programmatore esterno; documentare gli esiti.
4. Portare il test Python di `match.py` al 100% di coverage.
5. Allineare le esclusioni di `sonar-project.properties` e di `.codacy.yml` ai
   dump in `subsystems/`.
6. Proposta di upstream su review.coreboot.org.
7. Valutare `me_cleaner`/HAP per ridurre l'ME, con le dovute cautele.

## Fuori ambito

- Distribuzione di BIOS HP, regioni ME o immagini di flash.
- Garanzie su altri modelli della famiglia ProBook.
- Driver del sistema operativo oltre alle schede documentali per sottosistema.

## Decisioni aperte per il proprietario

- Licenza della documentazione (`NOTICE.md`, sezione 4).
- Se rimuovere dalla cronologia git i file già pubblicati (commit `231288e`):
  oggi non sono stati rimossi.
- Se mantenere il suo indirizzo di posta in `CITATION.cff`.
- Se proporre il port a coreboot anche prima del primo avvio su hardware.

## Come verificare

```bash
npx markdownlint-cli2 "**/*.md"
python -m venv .venv
.venv/bin/pip install pytest pytest-cov    # su Windows: .venv\Scripts\pip
.venv/bin/pytest --cov=subsystems/02-fingerprint-vfs495/scripts \
  --cov-report=term-missing
gitleaks detect
```

La CI esegue markdownlint, lychee (link), gitleaks e SonarCloud con i test.
La compilazione del port richiede un albero coreboot a parte (vedi
[`docs/sviluppo.md`](docs/sviluppo.md)).
