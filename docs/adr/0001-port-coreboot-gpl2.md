# 0001 - Port coreboot con licenza GPL-2.0-only

Stato: accettata

## Contesto

I file del port sono pensati per entrare nell'albero di coreboot, che usa la
GPL-2.0.

## Decisione

I sorgenti in `coreboot/` portano `SPDX-License-Identifier: GPL-2.0-only` e il
repository usa la stessa
licenza ([LICENSE](../../LICENSE)). Le tabelle ACPI e le verb table sono
ricavate osservando il
comportamento dell'hardware.

## Conseguenze

Chi distribuisce un'immagine compilata deve rispettare la sezione 3 della
GPL-2.0.
