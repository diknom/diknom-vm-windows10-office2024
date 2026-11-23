#!/bin/sh
# Buat domain libvirt untuk tiny10/Windows 10 di QEMU session.
set -eu

VM_NAME="${VM_NAME:-win10}"
VM_DIR="${VM_DIR:-}"
ISO=""
RAM="${RAM:-2048}"
CPUS="${CPUS:-2}"
DISK_GB="${DISK_GB:-20}"
VNC_PASS="${VNC_PASS:-changeme}"   # maksimal 8 karakter

say() { printf '%s\n' "$*"; }
die() { printf 'Error: %s\n' "$*" >&2; exit 1; }

while [ "$#" -gt 0 ]; do
    case "$1" in
        --iso) ISO="${2:-}"; shift 2 ;;
        --name) VM_NAME="${2:-}"; shift 2 ;;
        --ram) RAM="${2:-}"; shift 2 ;;
        --cpus) CPUS="${2:-}"; shift 2 ;;
        --disk) DISK_GB="${2:-}"; shift 2 ;;
        --help|-h)
            cat <<EOF
Pemakaian: ./create-vm.sh --iso /path/Tiny10.iso [opsi]

  --name NAMA    nama domain (default: win10)
  --ram MB       RAM guest (default: 2048)
  --cpus N       vCPU (default: 2)
  --disk GB      ukuran qcow2 (default: 20)

Environment: VM_NAME, VM_DIR, VNC_PASS
EOF
            exit 0 ;;
        *) die "Opsi tidak dikenal: $1" ;;
    esac
done

[ -n "$VM_DIR" ] || VM_DIR="$HOME/vms/$VM_NAME"
[ -n "$ISO" ] || die "Gunakan --iso /path/Tiny10.iso"
[ -f "$ISO" ] || die "ISO tidak ditemukan: $ISO"
command -v virt-install >/dev/null 2>&1 || die "virt-install belum terpasang."
command -v qemu-img >/dev/null 2>&1 || die "qemu-img belum terpasang."
[ -e /dev/kvm ] || die "/dev/kvm tidak ada; aktifkan virtualisasi."

if virsh --connect qemu:///session dominfo "$VM_NAME" >/dev/null 2>&1; then
    die "Domain '$VM_NAME' sudah ada. Pilih nama lain atau hapus domain lama."
fi

if [ "$(printf '%s' "$VNC_PASS" | wc -c)" -gt 8 ]; then
    die "VNC_PASS maksimal 8 karakter (batas libvirt)."
fi

mkdir -p "$VM_DIR"
DISK="$VM_DIR/disk.qcow2"
if [ ! -f "$DISK" ]; then
    say "Membuat disk qcow2 ${DISK_GB}G: $DISK"
    qemu-img create -f qcow2 "$DISK" "${DISK_GB}G"
else
    say "Disk sudah ada: $DISK"
fi

say "Membuat domain $VM_NAME (RAM ${RAM}MB, ${CPUS} vCPU) ..."
virt-install \
    --connect qemu:///session \
    --name "$VM_NAME" \
    --memory "$RAM" \
    --vcpus "$CPUS" \
    --cpu host \
    --disk path="$DISK",bus=sata,cache=writeback \
    --cdrom "$ISO" \
    --network user,model=e1000 \
    --graphics vnc,listen=127.0.0.1,password="$VNC_PASS" \
    --video vga \
    --osinfo win10 \
    --boot cdrom,hd \
    --noautoconsole

say ""
say "Domain dibuat. Buka VNC:"
say "  vnc://127.0.0.1:5900"
say ""
say "Pasang Windows, lalu Office 2024 lewat ODT."
say "Jangan biarkan VM menyala tanpa tujuan di host RAM 4 GB."
