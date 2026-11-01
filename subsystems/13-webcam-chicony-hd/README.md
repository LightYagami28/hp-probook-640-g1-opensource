# 13 — Webcam Chicony HP HD (04f2:b39a)

## 1. Dati Hardware
* **Dispositivo**: Chicony Electronics Co., Ltd HP HD Webcam
* **USB VID:PID**: `04f2:b39a`
* **Bus**: USB 2.0 High Speed (collegamento interno cornice display al controller Lynx Point)
* **Driver Linux**: modulo standard `uvcvideo` (USB Video Class)
* **Nodi Device**: `/dev/video0` (video capture stream) e `/dev/video1` (metadata stream)

---

## 2. Formati & Risoluzioni Supportate
Dall'ispezione dei descrittori USB UVC:
* **Risoluzione nativa**: 1280x720 (720p HD) a 30 FPS
* **Formati Colore**:
  - `YUYV 4:2:2`: segnale raw non compresso (ideale per cattura a bassa latenza)
  - `MJPEG`: stream Motion-JPEG compresso (ideale per videochiamate a basso throughput USB)
* **Controlli Immagine Hardware**: esposizione automatica, bilanciamento del bianco (AWB), guadagno, nitidezza e filtro anti-flicker regolabile (50 Hz / 60 Hz).
* **Array Microfoni Integrati**: due capsule microfoniche digitali stereo integrate nella cornice superiore, collegate direttamente al codec audio IDT su Pin 0x11.

---

## 3. Verifica dello Stato Operativo
```bash
# Ispezione nodo video attivo:
v4l2-ctl --list-formats-ext --device=/dev/video0

# Verifica gestione PipeWire Media:
wpctl status | grep -A 4 "Video"
```
