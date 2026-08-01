#!/usr/bin/env bash

set -eux

module_path=/etc/modprobe.d/nvidia.conf
udev_path=/lib/udev/rules.d/50-disable-nvidia.rules
dracuit_path=/etc/dracut.conf.d/nvidia.conf
enable() {
  sudo rm -f "$module_path" "$udev_path"

  cat <<'EOF' | sudo tee "$module_path"
options nvidia_drm modeset=1
EOF

  cat <<'EOF' | sudo tee "$dracuit_path"
add_drivers+=" nvidia nvidia_modeset nvidia_uvm nvidia_drm "
install_items+=" /etc/modprobe.d/nvidia.conf "
EOF

  dnf install -y akmod-nvidia nvidia-container-toolkit xorg-x11-drv-nvidia-power xorg-x11-drv-nvidia-cuda \
    kmod-nvidia nvidia-vaapi-driver

  grubby --update-kernel=ALL --args='nvidia-drm.modeset=1'

  while pgrep akmod; do
    sleep 5
  done

  dracut --regenerate-all --force
}

disable() {
  sudo rm -f "$dracuit_path"

  cat <<'EOF' | sudo tee "$module_path"
blacklist i2c_nvidia_gpu
blacklist nouveau
blacklist nvidia
blacklist nvidia-drm
blacklist nvidia-modeset
EOF

  cat <<'EOF' | sudo tee "$udev_path"
# Remove NVIDIA USB xHCI Host Controller devices, if present
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{remove}="1"

# Remove NVIDIA USB Type-C UCSI devices, if present
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{remove}="1"

# Remove NVIDIA Audio devices, if present
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{remove}="1"

# Remove NVIDIA VGA/3D controller
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{remove}="1"
EOF
}

if [[ ${1:-} == "enable" ]] ; then
  enable
else
  disable
fi
