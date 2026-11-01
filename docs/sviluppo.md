# Sviluppo e build

## Requisiti

Linux con toolchain di base (gcc, make, git, flex, bison, m4, pkg-config, zlib e
ncurses di sviluppo). Per il flash: flashrom 1.8.0 o successivo e un
programmatore SPI (CH341A, Raspberry Pi Pico serprog).

## Build

```bash
git clone https://review.coreboot.org/coreboot.git
cd coreboot
git checkout 26.09
git submodule update --init --checkout
cp -r /percorso/hp-probook-640-g1-opensource/coreboot src/mainboard/hp/probook_640_g1
cp /percorso/data.vbt \
   src/mainboard/hp/probook_640_g1/data.vbt
make crossgcc-i386 CPUS=$(nproc)
make menuconfig    # vendor HP, board ProBook 640 G1, payload a scelta
make
```

Risultato: `build/coreboot.rom` (non va committata, il `.gitignore` la esclude).

## Controlli del repository

```bash
npx markdownlint-cli2 "**/*.md"
```

La CI esegue anche lychee (link) e gitleaks (segreti).

## Stato

Il port non è stato compilato su 26.09: aspettarsi errori di API da correggere
(vedi i limiti in [`SPEC.md`](../SPEC.md)).
