# Office 2024 di tiny10

## Versi yang diuji

Eksperimen ini memakai **Office LTSC 2024 Click-to-Run** dengan aplikasi:

- Word
- Excel
- PowerPoint

PowerPoint, Word, dan Excel dibuka sebagai dokumen kosong. Status aktivasi
tidak termasuk pengukuran.

## Minimum resmi vs pengukuran

| Hal | Minimum resmi Office LTSC 2024 | Eksperimen ini |
|---|---:|---:|
| CPU | 1,1 GHz, 2 core | Celeron N4020, 2C/2T |
| RAM | **4 GB** | **2 GB guest** |
| Disk kosong | 4 GB | 10 GiB total, hampir penuh |
| OS | Windows 10 LTSC 2019/2021, Windows 11 | tiny10 build 17763/1809 |
| Layar | 1280 x 768 | 1280 x 800 |

Sumber minimum: halaman Office LTSC 2024 Microsoft. Angka 2 GB pada eksperimen
**di bawah minimum**; hasil "bisa jalan" bukan berarti didukung.

## Ringkasan hasil

- Idle: 502 MB (25% dari 2 GB)
- Word: 722 MB (35%)
- Word + Excel: 785 MB (40%)
- Word + Excel + PowerPoint: 872 MB (45%)
- Working set aplikasi: PowerPoint 81,6 MB; Word 66,8 MB; Excel 39,5 MB;
  Click-to-Run 22,1 MB.

Detail dan screenshot ada di [`experiment.md`](experiment.md).

## Cara memasang Office 2024

1. Siapkan lisensi Office yang sah.
2. Unduh **Office Deployment Tool (ODT)** dari Microsoft.
3. Sesuaikan [`scripts/office-configuration.xml`](../scripts/office-configuration.xml)
   dengan produk/lisensi kamu.
4. Salin ODT dan XML ke guest.
5. Jalankan:

```bat
setup.exe /configure office-configuration.xml
```

Contoh XML hanya memasang Word, Excel, dan PowerPoint 64-bit. Tidak ada
product key di repo ini.

## Mengapa hasilnya bisa berbeda

- tiny10 menghapus komponen Windows; Click-to-Run membutuhkan WMI/BITS/SPP
  yang utuh.
- Office 2024 versi konsumen memiliki syarat OS yang berbeda dari LTSC.
- RAM guest 2 GB lebih kecil dari minimum 4 GB.
- Disk 10 GiB terlalu kecil setelah Office dan update.
- Dokumen nyata, add-in, dan file besar menaikkan kebutuhan RAM/CPU.

## Rekomendasi praktis

- Untuk laptop 4 GB: Office 2013/2016/2019 atau LibreOffice lebih realistis.
- Jika tetap ingin Office 2024: gunakan guest **4 GB** di host dengan RAM
  minimal **8 GB**.
- Jangan memakai image tiny10 untuk data penting tanpa backup.
- Jangan mengunggah installer Office, product key, atau aktivator ke repo.
