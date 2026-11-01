#!/bin/bash
# Complete automated installer for Arch Linux (Validity VFS495 138a:003f)
set -euo pipefail

echo "=== Installing VFS495 Fingerprint Subsystem for Arch Linux ==="

# 1. Install system dependencies
sudo pacman -S --needed --noconfirm fprintd libfprint 7zip gdb python-pyusb python-numpy python-scipy python-pillow libusb-compat

# 2. Setup directories
sudo mkdir -p /usr/lib/vfs495-fprint/lib /etc/systemd/system/fprintd.service.d /etc/udev/rules.d /var/lib/vfs495-fprint/lib

# 3. Copy binaries & tools
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
sudo cp -r "$ROOT_DIR"/packaging/vfs495-fprint/usr/lib/vfs495-fprint/* /usr/lib/vfs495-fprint/
sudo cp "$ROOT_DIR"/packaging/vfs495-fprint/usr/bin/* /usr/bin/
sudo chmod +x /usr/bin/vfs495-* /usr/lib/vfs495-fprint/*.sh /usr/lib/vfs495-fprint/*.py

# 4. Compile SSL stubs
sudo gcc -shared -fPIC -Wl,-soname,libssl.so.0.9.8 -o /usr/lib/vfs495-fprint/lib/libssl.so.0.9.8 /usr/lib/vfs495-fprint/stub.c
sudo gcc -shared -fPIC -Wl,-soname,libcrypto.so.0.9.8 -o /usr/lib/vfs495-fprint/lib/libcrypto.so.0.9.8 /usr/lib/vfs495-fprint/stub.c

# 5. Setup HP diagnostic binary and patch gate
sudo /usr/lib/vfs495-fprint/setup-hp-driver.sh

# 6. Install udev & systemd configurations
sudo cp "$ROOT_DIR"/packaging/vfs495-fprint/lib/udev/rules.d/60-vfs495.rules /etc/udev/rules.d/
sudo cp "$ROOT_DIR"/packaging/vfs495-fprint/etc/systemd/system/fprintd.service.d/vfs495.conf /etc/systemd/system/fprintd.service.d/
sudo cp "$ROOT_DIR"/packaging/vfs495-fprint/lib/systemd/system/vfs495-bridge.service /etc/systemd/system/

# 7. Configure PAM if not already present
if ! grep -q "pam_fprintd.so" /etc/pam.d/system-auth; then
  echo "Adding pam_fprintd.so to /etc/pam.d/system-auth..."
  sudo sed -i "/^auth.*pam_faillock.so.*preauth/i auth       sufficient                  pam_fprintd.so" /etc/pam.d/system-auth
fi

# 8. Reload & restart services
sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=usb
sudo systemctl daemon-reload
sudo systemctl restart fprintd.service
sudo systemctl enable --now vfs495-bridge.service

echo ""
echo "=== INSTALLATION COMPLETE ==="
echo "Enroll your finger with:   fprintd-enroll"
echo "Verify enrollment with:    fprintd-verify"
echo "Test sudo unlock with:     sudo -k && sudo true"
