# Risoluzione dei problemi

## La compilazione di coreboot fallisce con errori di API

Il port è stato scritto per coreboot 26.09 ma non è mai stato compilato (vedi
[docs/sviluppo.md](docs/sviluppo.md)).
Confronta le firme con una scheda Haswell già presente nell'albero di coreboot e
correggi.

## `data.vbt` non si trova

Va estratto dalla propria macchina e copiato in
`src/mainboard/hp/probook_640_g1/data.vbt`: non è nel
repository.

## flashrom non riconosce il chip

Controlla il cablaggio della pinza e l'alimentazione del programmatore (vedi
[guida al flashing](security_and_flashing/FLASHING_GUIDE.md)), usa flashrom
1.8.0 o successivo e
prova a leggere più volte: due letture identiche confermano il collegamento.

## `pytest` non trova gli script

Lancia `pytest` dalla radice del repository: i test importano gli script di
`subsystems/02-fingerprint-vfs495/scripts`.

## markdownlint segnala errori

`make lint-md` usa la configurazione del repository: correggi come indicato.
