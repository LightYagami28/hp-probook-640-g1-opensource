# 06 — Scheda Grafica Integrata Intel HD Graphics 4600 (Haswell GT2)

## 1. Dati Hardware
* **PCI ID**: `8086:0416` (Intel 4th Generation Core Processor Mobile Graphics Controller)
* **Subsystem**: `103c:1993`
* **Architettura**: Intel Haswell GT2 (20 Execution Units / Shaders)
* **Driver Linux**: modulo open-source `i915` (Mesa Hasvk per Vulkan 1.2, i965 per VA-API)

---

## 2. Reverse Engineering del Video BIOS Table (VBT)
La Video BIOS Table (VBT) contiene le impostazioni a basso livello del controller display integrate da HP nel BIOS UEFI. Il blocco è stato estratto dal debugfs DRM (`/sys/kernel/debug/dri/0000:00:02.0/i915_vbt`):

* **Firma Intestazione**: `$VBT HASWELL Cyclone VBIOS 2175`
* **Pannello eDP Integrato**:
  - Delay di alimentazione accensione (`up_delay_ms`): 200 ms
  - Delay spegnimento (`down_delay_ms`): 50 ms
  - Ciclo di reset pannello (`cycle_delay_ms`): 500 ms
  - Frequenza modulazione retroilluminazione PWM (`backlight_pwm_hz`): 200 Hz
* **Porte Esterne**:
  - DDI B: Porta DisplayPort fisica integrata sul lato sinistro
  - DDI C: Uscita video digitale docking station
  - DDI D: Convertitore analogico VGA per monitor esterni legacy

### Inizializzazione Nativa in Coreboot (`libgfxinit`)
Coreboot inizializza la scheda video Haswell senza ricorrere a binary blob VBIOS legacy a 16 bit, utilizzando l'implementazione formale open-source scritta in SPARK/Ada (`libgfxinit`). I parametri estratti sono configurati in `coreboot/devicetree.cb` e `coreboot/gma-mainboard.ads`.

---

## 3. Accelerazione Hardware VA-API
Per consentire la decodifica video a zero carico CPU di flussi H.264/MPEG-2, `/etc/environment` è configurato con:
```text
LIBVA_DRIVER_NAME=i965
```

---

## 4. Verifica dello Stato Operativo
```bash
# Verifica dei profili VA-API supportati dalla GPU:
vainfo
# vaInitialize: VA-API version 1.22
# VAProfileH264ConstrainedBaseline: VAEntrypointVLD
# VAProfileH264Main               : VAEntrypointVLD
# VAProfileH264High               : VAEntrypointVLD
```
