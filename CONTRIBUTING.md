# Contribuire

1. Aprire un ramo da `main`; mai push diretti su `main`.
2. Modificare i file in `coreboot/` mantenendo l'intestazione `SPDX-License-Identifier: GPL-2.0-only`.
3. Non aggiungere dump, blob proprietari o dati identificativi del dispositivo (vedi [`NOTICE.md`](NOTICE.md)); il `.gitignore` li esclude.
4. Verificare in locale: `npx markdownlint-cli2 "**/*.md"`. Per il port, compilare nell'albero coreboot come in [`docs/sviluppo.md`](docs/sviluppo.md).
5. Aprire una PR con titolo e descrizione brevi; la CI (markdownlint, lychee, gitleaks) deve essere verde.
6. Indicare sempre cosa è stato provato su hardware reale e cosa no.
