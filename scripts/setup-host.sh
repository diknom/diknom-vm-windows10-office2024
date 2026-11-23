#!/bin/sh
# Siapkan host KVM/libvirt untuk DikNom TinyWin.
set -eu

say() { printf '%s\n' "$*"; }
die() { printf 'Error: %s\n' "$*" >&2; exit 1; }

if [ "$(id -u)" -eq 0 ]; then
    SUDO=""
else
    SUDO="sudo"
fi

say "== DikNom TinyWin — setup host =="
say "Host: $(uname -srm)"

if [ -z "${SUDO}" ]; then
    say "Menjalankan sebagai root."
elif ! command -v sudo >/dev/null 2>&1; then
    die "Butuh root; jalankan sebagai root atau pasang sudo."
fi

if command -v apt-get >/dev/null 2>&1; then
    $SUDO apt-get update
    $SUDO apt-get install -y qemu-kvm libvirt-daemon-system libvirt-clients \
        virtinst ovmf
elif command -v dnf >/dev/null 2>&1; then
    $SUDO dnf install -y @virtualization
elif command -v yum >/dev/null 2>&1; then
    $SUDO yum install -y qemu-kvm libvirt virt-install
elif command -v pacman >/dev/null 2>&1; then
    $SUDO pacman -S --needed --noconfirm qemu-full libvirt virt-install \
        edk2-ovmf
elif command -v zypper >/dev/null 2>&1; then
    $SUDO zypper install -y qemu-kvm libvirt virt-install ovmf
elif command -v apk >/dev/null 2>&1; then
    $SUDO apk add qemu-system-x86_64 libvirt virt-install ovmf
elif command -v xbps-install >/dev/null 2>&1; then
    $SUDO xbps-install -y qemu libvirt virt-install ovmf
else
    die "Package manager tidak dikenali. Pasang QEMU, libvirt, dan virt-install manual."
fi

[ -e /dev/kvm ] || die "/dev/kvm tidak ditemukan. Aktifkan VT-x/AMD-V di BIOS."

if command -v systemctl >/dev/null 2>&1; then
    $SUDO systemctl enable --now libvirtd 2>/dev/null || true
fi

say ""
say "Selesai. Cek:"
say "  virsh --connect qemu:///session list --all"
say "  ls -l /dev/kvm"
say ""
say "Kalau user belum masuk grup libvirt/kvm, jalankan:"
say "  sudo usermod -aG libvirt,kvm \"$USER\""
say "lalu logout/login."
