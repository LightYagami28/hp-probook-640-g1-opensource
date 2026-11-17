# Domande frequenti

## Cos'è questo repository?
Documentazione, dump e porting coreboot per il portatile HP ProBook 640 G1 (Subsystem ID `103c:1993`).
Vedi [README.md](README.md).

## Posso flashare direttamente il firmware?
No, non ancora: il port non è stato compilato su coreboot 26.09 né provato su hardware. Leggi
[security_and_flashing/FLASHING_GUIDE.md](security_and_flashing/FLASHING_GUIDE.md) e [SPEC.md](SPEC.md)
prima di toccare il chip: un flash sbagliato può rendere la macchina non avviabile.

## Perché manca `data.vbt`?
È un file derivato dal firmware proprietario del produttore e non è redistribuibile. Va estratto dalla
propria macchina: vedi [NOTICE.md](NOTICE.md).

## Quali strumenti servono?
Per compilare: Linux con gcc, make, git, flex, bison, m4, pkg-config, zlib e ncurses di sviluppo. Per
il flash: flashrom 1.8.0 o successivo e un programmatore SPI (CH341A o Raspberry Pi Pico serprog).

## Come eseguo i test?
```bash
python3 -m venv .venv
.venv/bin/pip install pytest pytest-cov
.venv/bin/pytest
```
I test coprono gli script del lettore VFS495 (`subsystems/02-fingerprint-vfs495/scripts`).

## Con quale licenza posso riusare il materiale?
Il port coreboot è GPL-2.0-only; altri materiali hanno titolari diversi. Leggi [NOTICE.md](NOTICE.md).

## Dove chiedo aiuto?
Nelle [Discussioni](https://github.com/LightYagami28/hp-probook-640-g1-opensource/discussions).
Per le vulnerabilità vedi [SECURITY.md](SECURITY.md).
