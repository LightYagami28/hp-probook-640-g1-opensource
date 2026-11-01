# Changelog

## Non rilasciato

- Documentazione completa: SPEC.md, `docs/`, CONTRIBUTING, SECURITY.
- CI: markdownlint, lychee, gitleaks (azioni fissate per SHA) e dependabot per
  le azioni.
- Guida al flashing: spiega come ricavare descrittore, GbE e VBT dal proprio
  dump.
- Versioni di riferimento aggiornate: coreboot 26.09, flashrom 1.8.0.
- Analisi SonarCloud da CI (richiede il segreto `SONAR_TOKEN`), `.codacy.yml`.
- Documenti conformi a markdownlint con regole di default; sorgenti coreboot
  ripuliti da FIXME e codice ridondante.

## Precedente

- Rimozione dei dump firmware HP/Intel, oscuramento identificativi, licenza
  GPL-2.0 (PR #1).
- Port coreboot iniziale per HP ProBook 640 G1, tabelle ACPI e mappe hardware.
