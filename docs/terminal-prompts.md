# Prompt Terminal Lengkap

Dokumen ini berisi perintah yang bisa disalin ke terminal Linux. Ganti bagian
di dalam `<...>` sesuai mesinmu.

> **Sebelum mulai:** ISO tiny10 tidak disediakan repo ini. Unduh dari sumber
> NTDEV/Internet Archive; baca [`source-and-licenses.md`](source-and-licenses.md).
> Jangan menjalankan skrip aktivasi ilegal.

## 0. Variabel nama VM

Kata **`w10on`**, **`w10off`**, dan **`w10shutdown`** hanyalah contoh. Pilih
nama VM sendiri, misalnya `vmkerja`, `winoffice`, atau `tiny10`.

```bash
VM_NAME="win10"                 # ganti sesuai keinginan
VM_DIR="$HOME/vms/$VM_NAME"
ISO="$HOME/Downloads/Tiny10 B4 x64.iso"
VNC_PASS="gantipas"           # maksimal 8 karakter
```

Semua skrip di repo memakai `VM_NAME`. Kalau kamu mengganti nama domain,
ganti nilai itu—bukan hanya nama file.

## 1. Cek virtualisasi

```bash
lscpu | grep -E 'Virtualization|Model name'
ls -l /dev/kvm
free -h
df -h /
```

Yang harus terlihat: `/dev/kvm` ada, dan CPU mendukung virtualization. Di
laptop uji, RAM host hanya 4 GB; ini akan menjadi batas utama.

## 2. Pasang KVM/libvirt

### Ubuntu / Debian

```bash
sudo apt update
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients \
  virtinst ovmf
sudo usermod -aG libvirt,kvm "$USER"
newgrp libvirt
```

### Fedora

```bash
sudo dnf install -y @virtualization
sudo usermod -aG libvirt,kvm "$USER"
newgrp libvirt
```

### Arch Linux

```bash
sudo pacman -S --needed qemu-full libvirt virt-install edk2-ovmf
sudo usermod -aG libvirt,kvm "$USER"
newgrp libvirt
```

### openSUSE

```bash
sudo zypper install -y qemu-kvm libvirt virt-install ovmf
sudo usermod -aG libvirt,kvm "$USER"
newgrp libvirt
```

Cek:

```bash
virsh --connect qemu:///session list --all
virt-install --version
qemu-system-x86_64 --version
```

## 3. Unduh ISO tiny10

Gunakan skrip yang meminta persetujuan:

```bash
chmod +x scripts/download-tiny10.sh
./scripts/download-tiny10.sh
```

Atau manual:

```bash
mkdir -p "$HOME/Downloads"
curl -L --fail --retry 3 --continue-at - \
  -o "$HOME/Downloads/Tiny10 B4 x64.iso" \
  "https://archive.org/download/tiny-10-NTDEV/Tiny10%20B4%20x64.iso"
```

Hitung checksum lokal:

```bash
sha256sum "$HOME/Downloads/Tiny10 B4 x64.iso"
```

Catat hasilnya. tiny10 adalah image modifikasi NTDEV, bukan ISO resmi
Microsoft.

## 4. Buat disk dan VM

```bash
mkdir -p "$VM_DIR"
qemu-img create -f qcow2 "$VM_DIR/disk.qcow2" 20G

virt-install \
  --connect qemu:///session \
  --name "$VM_NAME" \
  --memory 2048 \
  --vcpus 2 \
  --cpu host \
  --disk path="$VM_DIR/disk.qcow2",bus=sata,cache=writeback \
  --cdrom "$ISO" \
  --network user,model=e1000 \
  --graphics vnc,listen=127.0.0.1,password="$VNC_PASS" \
  --video vga \
  --osinfo win10 \
  --boot cdrom,hd \
  --noautoconsole
```

Untuk RAM 2 GB, host 4 GB akan sangat tertekan. Jangan menaikkan guest ke 4 GB
di laptop ini.

Lihat endpoint:

```bash
virsh --connect qemu:///session domdisplay "$VM_NAME"
virsh --connect qemu:///session dumpxml "$VM_NAME" | grep -m1 "type='vnc'"
```

## 5. Pasang Windows

Buka VNC/Remmina:

```text
vnc://127.0.0.1:5900
```

Di dalam Windows:

1. Pilih bahasa dan keyboard.
2. Pilih **Install now**.
3. Pilih edisi yang sesuai.
4. Pilih **Custom: Install Windows only**.
5. Pilih disk kosong, lanjutkan.
6. Setelah reboot, selesaikan OOBE dan buat akun lokal.

Jangan menyimpan file pribadi di screenshot atau repo.

## 6. Pasang Office 2024

Office 2024 membutuhkan lisensi. Repo ini hanya menyediakan contoh
konfigurasi ODT, bukan installer atau kunci.

Di host, unduh **Office Deployment Tool** dari Microsoft, lalu salin
`setup.exe` dan konfigurasi ke guest lewat share yang kamu percaya.

Contoh konfigurasi ada di
[`../scripts/office-configuration.xml`](../scripts/office-configuration.xml).
Jalankan di dalam Windows:

```bat
setup.exe /configure office-configuration.xml
```

Office akan mengunduh Word, Excel, dan PowerPoint saja. Sesuaikan Product ID
dengan lisensi yang kamu miliki.

**Catatan resmi:** Office LTSC 2024 mendukung Windows 10 LTSC 2019/2021 dan
Windows 11. Office 2024 konsumen mensyaratkan Windows 11. tiny10 adalah build
modifikasi; jangan menganggap dukungan resmi berlaku penuh.

## 7. Ganti nama shortcut

Ini bagian yang paling sering terlewat. File `w10on` di repo adalah **template**,
bukan nama wajib.

Contoh: nama VM `vmkerja`.

```bash
# salin template ke ~/.local/bin dengan nama baru
install -m755 scripts/w10on       "$HOME/.local/bin/vmkerjaon"
install -m755 scripts/w10off      "$HOME/.local/bin/vmkerjaoff"
install -m755 scripts/w10shutdown "$HOME/.local/bin/vmkerjashutdown"

# sesuaikan nama domain di dalam skrip
sed -i 's/^VM_NAME=.*/VM_NAME="vmkerja"/' \
  "$HOME/.local/bin/vmkerjaon" \
  "$HOME/.local/bin/vmkerjaoff" \
  "$HOME/.local/bin/vmkerjashutdown"
```

Atau edit manual dengan editor:

```bash
nano "$HOME/.local/bin/vmkerjaon"
```

Cari baris:

```bash
VM_NAME="${VM_NAME:-win10}"
```

Ganti `win10` dengan nama domainmu.

Pastikan `~/.local/bin` ada di `PATH`:

```bash
echo "$PATH" | tr ':' '\n' | grep -q "$HOME/.local/bin" \
  || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
```

## 8. Pakai shortcut

```bash
vmkerjaon        # start atau resume VM, tanpa membuka viewer
vmkerjaoff       # suspend (simpan state RAM)
vmkerjashutdown  # shutdown bersih
```

`on` akan mencetak:

```text
VM      : vmkerja
Status  : running
VNC     : 127.0.0.1:5900
SPICE   : 127.0.0.1:5901
Viewer  : tidak dibuka; buka Remmina sendiri
```

Skrip sengaja **tidak membuka viewer otomatis**. Buka profil Remmina/VNC
sendiri setelah VM siap.

## 9. Shortcut desktop (opsional)

Buat file `.desktop`:

```bash
cat > "$HOME/Desktop/vmkerjaon.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Start VMkerja
Comment=Start atau resume Windows VM
Exec=/path/to/home/.local/bin/vmkerjaon
Icon=computer
Terminal=true
Categories=System;
EOF
chmod +x "$HOME/Desktop/vmkerjaon.desktop"
gio set "$HOME/Desktop/vmkerjaon.desktop" metadata::trusted true 2>/dev/null || true
```

Ganti path `Exec` dan nama `vmkerja` sesuai mesinmu. Untuk XFCE, klik kanan
file → **Allow this file to run** jika diminta.

## 10. Ukur RAM di Windows

1. `Win+R` → `taskmgr` → Enter.
2. Tab **Performance** → **Memory**.
3. Catat **In use**, **Available**, **Cached**.
4. Buka Word kosong; catat.
5. Buka Excel kosong; catat (Word masih terbuka).
6. Buka PowerPoint kosong; catat.
7. Tab **Processes**, urutkan berdasarkan Memory; catat Word/Excel/PowerPoint.

Jangan memakai dokumen pribadi untuk screenshot. Gunakan **Blank document**,
**Blank workbook**, dan **Blank presentation**.

## 11. Shutdown

Selalu tutup aplikasi dan matikan VM dengan bersih:

```bash
vmkerjashutdown
```

Jangan biarkan VM menyala tanpa tujuan; di host 4 GB, VM 2 GB membuat desktop
Linux sangat sempit.

## 12. Jika VM tidak mau start

```bash
virsh --connect qemu:///session list --all
virsh --connect qemu:///session dominfo "$VM_NAME"
virsh --connect qemu:///session domblklist "$VM_NAME"
ls -lh "$VM_DIR"
df -h /
```

Penyebab umum:

- ISO/disk path salah.
- Domain sudah memiliki managed save; `vmkerjaoff` menyimpan state.
- Disk guest penuh.
- `/dev/kvm` tidak bisa diakses.
- Host kehabisan RAM/swap.

## 13. Catatan keamanan dan lisensi

- Jangan menjalankan aktivator, KMS ilegal, atau crack.
- Jangan mengunggah ISO Windows/tiny10 ke repo.
- Jangan menaruh product key atau password VNC asli di README.
- Gunakan lisensi Windows dan Office yang sah.
- tiny10 adalah image modifikasi pihak ketiga; verifikasi sumber dan checksum
  sendiri.
