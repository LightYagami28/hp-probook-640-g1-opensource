# 07 — Touchpad & TrackPoint Synaptics PS/2

## 1. Dati Hardware
* **Dispositivo**: `SynPS/2 Synaptics TouchPad`
* **Bus / Porta**: `isa0060/serio3/input0` (interfaccia seriale multiplexata PS/2 dell'Embedded Controller KBC i8042)
* **Driver Linux**: `psmouse` con estensioni Synaptics avanzate

---

## 2. Architettura & Routing Segnali
Il touchpad e i pulsanti fisici superiori/inferiori non utilizzano un bus USB o I2C dedicato, ma comunicano direttamente con l'Embedded Controller SMSC KBC1126. L'EC agisce da multiplexer hardware PS/2, traducendo i pacchetti tattili nei registri standard della tastiera/mouse x86 (porte I/O `0x60` e `0x64`).

### Caratteristiche Hardware Supportate
* Sensore capacitivo con supporto fino a 2 dita simultanee (scorrimento verticale e orizzontale)
* Pulsanti fisici sinistro e destro indipendenti
* Funzionalità Tap-to-click e Palm Rejection hardware

---

## 3. Configurazione Ottimale Libinput
Per una risposta immediata su server Wayland e X11:
```ini
Section "InputClass"
    Identifier "touchpad"
    Driver "libinput"
    MatchIsTouchpad "on"
    Option "Tapping" "on"
    Option "NaturalScrolling" "true"
    Option "DisableWhileTyping" "true"
EndSection
```

---

## 4. Verifica dello Stato Operativo
```bash
# Elenco capacità rilevate da libinput:
libinput list-devices | grep -A 12 "SynPS/2 Synaptics TouchPad"
```
