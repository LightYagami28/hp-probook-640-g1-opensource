# 0002 - Niente file proprietari nel repository

Stato: accettata

## Contesto
Alcuni file (`data.vbt`, dump del firmware del produttore) derivano da codice proprietario non
redistribuibile.

## Decisione
Non stanno nel ramo principale e non vanno ricaricati; chi compila li estrae dalla propria macchina.
L'elenco è in [NOTICE.md](../../NOTICE.md).

## Conseguenze
La compilazione richiede un passo manuale (estrazione di `data.vbt`), documentato in
[docs/sviluppo.md](../sviluppo.md).
