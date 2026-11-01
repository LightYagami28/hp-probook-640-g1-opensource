# 02 — Lettore Impronte Digitali Validity Sensors VFS495 (138a:003f)

## 1. Dati Hardware
* **Dispositivo**: Validity Sensors, Inc. VFS495 Fingerprint Reader
* **USB VID:PID**: `138a:003f`
* **Bus**: USB 2.0 Full Speed (12 Mbps) su controller Intel PCH Lynx Point
* **ROM Versione Sensore**: 4.60

---

## 2. Reverse Engineering del Protocollo Proprietario

### Tabella Chiavi RSA del Sensore (`gSSPubKeyList`)
La tabella delle chiavi pubbliche del sensore è localizzata a offset `0x237c80` nel binario originale `validity-sensor`. Contiene 4 moduli statici RSA-2048:
* **Entry #3 (Sensore in uso)**: modulo RSA da 256 byte con prefisso esadecimale `51a04289...`.

### Patch RAM del Sensore
1. **Boot Patch 1**: 693 byte statici estratti a offset `0x171085`.
2. **Calibration Patch 2**: 1.301 byte letti dinamicamente dalla EEPROM SPI fisica del sensore tramite comando `0x1F 0x05` a offset `0x0F90`.

### Handshake Crittografico Personalizzato
* Variante custom del protocollo SSLv3 con cipher suite `0x0044` (RSA-2048, AES-256-CBC, HMAC-SHA1).
* I messaggi `ServerHello` e `ServerHelloDone` sono impacchettati in un singolo record di 53 byte.
* Etichetta di verifica per il digest del messaggio `Finished`: costante little-endian `0x434C4E54` (`CLNT`).
* Algoritmo MAC proprietario: omette il campo lunghezza record dal buffer di hashing.

### Sblocco Binario & Patch a 5 Byte
Il binario OEM impone controlli di licenza e ambiente. A offset `0x44122d`, la sequenza originale di branching è stata sostituita da un salto incondizionato a 5 byte (`e9 ...`), consentendo l'inizializzazione autonoma su qualsiasi distribuzione Linux.

---

## 3. Architettura del Driver Open-Source & Bridge
* **`scripts/bridge.py`**: demone Python che apre il socket virtuale `/run/fprint/virtimg_sock` per `fprintd`, riceve i frame raw dal sensore, esegue l'interpolazione geometrica e li invia al demone di sistema.
* **`scripts/capture.py` & `scripts/match.py`**: routine di estrazione minuzie e verifica biometrica.
* **`docs/VFS495_COMPLETE_SPEC.md`**: specifica tecnica formale con tutti i diagrammi di sequenza e i codici operativi USB.

---

## 4. Installazione & Verifica
```bash
# Avvio del servizio bridge di sistema:
sudo systemctl enable --now vfs495-bridge.service

# Registrazione biometrica dell'utente:
fprintd-enroll

# Verifica riconoscimento impronta:
fprintd-verify
```
