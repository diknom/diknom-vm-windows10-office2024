#!/bin/sh
# Unduh ISO tiny10 dari sumber NTDEV/Internet Archive.
# Repo ini tidak menyimpan ISO dan tidak berafiliasi dengan NTDEV/Microsoft.
set -eu

URL="https://archive.org/download/tiny-10-NTDEV/Tiny10%20B4%20x64.iso"
OUT="${1:-$HOME/Downloads/Tiny10 B4 x64.iso}"

say() { printf '%s\n' "$*"; }

case "${2:-}" in
    --yes|-y) YES=1 ;;
    *) YES=0 ;;
esac

say "== tiny10 B4 x64 =="
say "Sumber : NTDEV / Internet Archive"
say "URL    : $URL"
say "Tujuan : $OUT"
say ""
say "Peringatan:"
say "- Ini image Windows 10 modifikasi, bukan ISO resmi Microsoft."
say "- Kamu tetap membutuhkan lisensi Windows yang sah."
say "- Verifikasi sumber dan checksum sendiri sebelum memakai."
say "- Jangan unggah ISO ini ke repo GitHub."

if [ "$YES" -ne 1 ]; then
    printf 'Lanjutkan unduh? [y/N] '
    read -r answer
    case "$answer" in
        y|Y|ya|YA) ;;
        *) say "Dibatalkan."; exit 0 ;;
    esac
fi

mkdir -p "$(dirname "$OUT")"
if command -v curl >/dev/null 2>&1; then
    curl -L --fail --retry 3 --continue-at - -o "$OUT" "$URL"
elif command -v wget >/dev/null 2>&1; then
    wget -c -O "$OUT" "$URL"
else
    say "curl/wget tidak ditemukan."
    exit 1
fi

say ""
say "Selesai: $OUT"
if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$OUT"
fi
say "Catat checksum di atas. Sumber tidak menyediakan jaminan keamanan untuk image modifikasi."
