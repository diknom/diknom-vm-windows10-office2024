# Eksperimen: tiny10 + Office 2024 di Laptop 4 GB

Dokumen ini mencatat eksperimen yang benar-benar dijalankan di mesin uji.
Semua angka RAM berasal dari **Task Manager Windows di dalam guest**, bukan
perkiraan dari kebutuhan resmi.

## Tujuan

Menjawab satu pertanyaan:

> Bisa tidak laptop 4 GB menjalankan Windows di VM dan membuka Word, Excel,
> serta PowerPoint 2024 tanpa langsung kehabisan RAM?

Jawaban singkat: **bisa dibuka, tetapi tidak nyaman untuk kerja berat dan
tidak memenuhi minimum resmi Office 2024.**

## Hardware uji

| Komponen | Nilai |
|---|---|
| Laptop | Dynabook K50/FR |
| CPU | Intel Celeron N4020, 2 core / 2 thread |
| RAM host | 4 GB tersolder |
| Penyimpanan | eMMC 64 GB |
| OS host | Ubuntu 26.10, XFCE |
| Virtualisasi | KVM + libvirt (qemu:///session) |
| Viewer | VNC/SPICE, biasanya Remmina |

## Konfigurasi VM

| Komponen | Nilai |
|---|---|
| Nama domain | `win10` (contoh; bisa diganti) |
| Image | tiny10 B4 x64, build 17763 / 1809 |
| vCPU | 2 |
| RAM guest | 2048 MB |
| Disk | qcow2 10 GiB, SATA |
| Network | user-mode, e1000 |
| Display | VNC 5900, SPICE 5901 |
| Office | LTSC 2024 Click-to-Run, Word/Excel/PowerPoint |

tiny10 B4 x64 adalah image modifikasi NTDEV, bukan ISO resmi Microsoft. Sumber
dan peringatan lisensi ada di [`source-and-licenses.md`](source-and-licenses.md).

## Cara pengukuran

1. Boot Windows sampai desktop benar-benar idle; tunggu startup selesai.
2. Buka **Task Manager → Performance → Memory**.
3. Catat `In use`, `Available`, `Cached`, dan grafik.
4. Buka Word kosong, tunggu jendela siap, lalu baca Task Manager.
5. Buka Excel kosong; Word tetap terbuka. Catat perubahan.
6. Buka PowerPoint kosong; Word dan Excel tetap terbuka. Catat perubahan.
7. Buka **Processes**, urutkan berdasarkan Memory, catat working set tiap
   aplikasi.
8. Catat juga kondisi host dari Linux: `free -m`, RSS QEMU, dan `df -h /`.

Pengukuran dilakukan berurutan, jadi angka Excel adalah **Word + Excel**, dan
angka PowerPoint adalah **Word + Excel + PowerPoint**. Ini bukan angka
aplikasi tunggal yang terisolasi.

## Hasil RAM

### 1. Windows idle

- In use: **502 MB**
- Total: 2,0 GB
- Persentase: **25%**
- Available: **1,5 GB**
- Cached: **171 MB**
- Paged pool: 36,5 MB
- Non-paged pool: 30,6 MB
- CPU: **2%**
- Proses: 40
- Virtual processor: 2
- Uptime saat screenshot: sekitar 2 menit 43 detik

Screenshot: [`01-idle-memory.png`](../assets/experiment/01-idle-memory.png)

### 2. Word kosong

- In use: **722 MB**
- Persentase: **35%**
- Available: **1,3 GB**
- Cached: **280 MB**
- CPU: **4%**

Screenshot: [`02-word-memory.png`](../assets/experiment/02-word-memory.png)

### 3. Word + Excel kosong

- In use: **785 MB**
- Persentase: **40%**
- Available: **1,2 GB**
- Cached: **309 MB**
- CPU: **3%**

Screenshot: [`03-excel-memory.png`](../assets/experiment/03-excel-memory.png)

### 4. Word + Excel + PowerPoint kosong

- In use: **872 MB**
- Persentase: **45%**
- Available: **1,1 GB**
- Cached: **329 MB**
- CPU: **3%**

Screenshot: [`04-all-three-memory.png`](../assets/experiment/04-all-three-memory.png)

### 5. Working set per proses

Saat ketiga aplikasi terbuka, Task Manager menunjukkan:

| Proses | Working set |
|---|---:|
| Microsoft PowerPoint (2) | **81,6 MB** |
| Microsoft Word (2) | **66,8 MB** |
| Microsoft Excel | **39,5 MB** |
| Microsoft Office Click-to-Run | **22,1 MB** |
| Desktop Window Manager | 19,9 MB |
| Windows Explorer | 13,3 MB |
| Task Manager | 9,5 MB |

Screenshot: [`05-process-memory.png`](../assets/experiment/05-process-memory.png)

Catatan: header Task Manager pada screenshot proses terbaca **43%** karena
sampel diambil beberapa saat setelah tab Memory; angka yang dipakai untuk tabel
adalah **872 MB / 45%** dari tab Memory. Perbedaan kecil ini normal karena Task
Manager menyegarkan angka secara berkala.

Angka working set tidak dijumlahkan menjadi total RAM karena Windows berbagi
DLL, cache, dan memori terkompresi.

## Kondisi host

Saat guest berjalan dengan tiga aplikasi terbuka:

- Total RAM host: 3.713 MB
- Used: sekitar **3.269 MB**
- Free: sekitar **168 MB**
- Available: sekitar **444 MB**
- Swap used: sekitar **1.536 MB**
- RSS QEMU: sekitar **1.600 MB**
- Disk root: 48 GB, terpakai 36 GB, bebas 9,0 GB

**Penting:** free 168 MB adalah kondisi host secara keseluruhan, bukan RAM
Windows saja. Pada saat pengukuran, host juga menjalankan **Hermes Agent,
Chrome, desktop XFCE, cache, dan zram/swap**. Hermes adalah proses agent yang
memantau/mengendalikan eksperimen; Chrome dan desktop juga aktif. Jadi host
terlihat hampir kehabisan RAM karena beban gabungan, bukan karena guest
memakai seluruh 4 GB.

CPU host masih aman:

- Celeron N4020: 2 core / 2 thread.
- Task Manager guest: **2% idle**, **4% saat Word**, **3% saat tiga aplikasi**.
- Proses QEMU: sekitar **41–90%** CPU process (kira-kira 0,4–0,9 core,
  tergantung fase boot/aplikasi).
- Dua core tidak tersaturasi; bottleneck utama adalah RAM dan eMMC.

Artinya: guest 2 GB bukan "gratis". Host Linux, cache, QEMU, Hermes, Chrome,
dan zram/swap semua berebut RAM. Desktop host bisa terasa berat saat Office
membuka dokumen besar, walaupun CPU tidak mentok.

## Kenyamanan penggunaan

Pengalaman langsung selama eksperimen:

- Mengetik di Word, Excel, dan PowerPoint terasa nyaman; input keyboard, klik,
  scroll, dan pindah jendela tetap responsif selama guest tidak menjalankan
  aplikasi berat lain.
- Dokumen ringan bisa dibuka dan diedit tanpa lag yang mengganggu. Ini bukan
  benchmark latensi; ini observasi penggunaan.
- **Browser di guest:** batasi sekitar **4 tab** jika harus browsing di
  Windows. Lebih dari itu, pindahkan browser ke host Linux atau remote ke
  mesin lain. RAM 2 GB cepat habis, terutama untuk situs dengan video,
  ekstensi, atau banyak script.
- Pola yang disarankan: Office di guest, browser di host. Ini menjaga input
  tetap enak dan mengurangi tekanan RAM.

Batas 4 tab adalah saran konservatif, bukan hasil pengukuran tab yang presisi.
Setiap tab dapat memakai puluhan sampai ratusan MB tergantung isi halaman.

## Disk

- qcow2 virtual: 10 GiB
- qcow2 aktual setelah Office: **9,23 GiB**
- Sisa ruang C: sangat sedikit
- Office C2R menambah sekitar 3,5 GiB dari kondisi awal

**Jangan pakai 10 GiB untuk pemakaian nyata.** Gunakan minimal **20 GiB**,
ideal 24–32 GiB, supaya update Windows dan file dokumen tidak langsung
memenuhi disk.

## Interpretasi

1. **Angka 45% terlihat ringan, tetapi konteksnya penting.** Guest hanya 2 GB;
   Office 2024 resminya meminta 4 GB. Sistem bisa "jalan" karena Windows
   memakai cache dan kompresi, bukan karena Office 2024 benar-benar ringan.
2. **Word/Excel/PowerPoint kosong bukan beban kerja nyata.** Dokumen dengan
   gambar, tabel besar, animasi, dan add-in akan menaikkan RAM dan CPU.
3. **Host 4 GB adalah batas keras.** Upgrade RAM tidak mungkin karena soldered.
   Swap/zram membantu tetapi tidak menghilangkan lag dan aus eMMC.
4. **Untuk kerja Office serius**, gunakan Office 2013/2016/2019, LibreOffice,
   Office web, atau remote ke mesin yang lebih kuat.
5. **Untuk eksperimen dan dokumen ringan**, konfigurasi ini terbukti bisa
   membuka ketiga aplikasi bersamaan.

## Batasan eksperimen

- Tidak mengukur dokumen besar.
- Tidak mengukur Office dengan add-in, macro, atau file 100+ MB.
- Tidak mengukur baterai dan suhu secara rinci.
- Status aktivasi/lisensi Office tidak dinilai.
- tiny10 bukan Windows resmi; hasil bisa berbeda pada build lain.
- Task Manager menunjukkan 2 socket / 2 virtual processor; konfigurasi
  topology VM bisa memengaruhi performa.

## Reproduksi

Ikuti [`terminal-prompts.md`](terminal-prompts.md), lalu ulangi urutan
pengukuran di atas. Jangan mengunggah screenshot dokumen pribadi; gunakan
dokumen kosong seperti pada repo ini.
