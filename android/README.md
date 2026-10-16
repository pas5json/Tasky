# 🛒 KantinKu - Panduan Praktikum & Setup Flutter (Week 5)
**Alta Global School | IT Grade 10 & 11 (SHS)**  
*Sprint 1: Mobile App Development Bootcamp*

---

## 💡 Pilih Jalur Menjalankan Aplikasi Sesuai Laptop Kamu

Pilih salah satu dari 3 opsi di bawah ini yang paling sesuai dengan kondisi laptop kamu:

| Opsi | Kapan Memilih Opsi Ini? | Waktu Setup |
|---|---|---|
| 🌐 **Jalur 1: Google DartPad (Web Cloud)** | Laptop belum terinstall Flutter/IDE, atau spek laptop terbatas (RAM 4GB). | **0 Detik (Langsung Buka Browser)** |
| 🔵 **Jalur 2: VS Code + Chrome Web** | Laptop sudah terinstall VS Code, ingin proses coding ringan dan cepat. | **1 Menit** |
| 🟢 **Jalur 3: Android Studio** | Laptop sudah terinstall Android Studio dari pertemuan Week 1. | **2 Menit** |

---

## 🌐 JALUR 1: Google DartPad (Jalur Darurat / Tanpa Installasi Sama Sekali)
> Cocok untuk siswa yang belum menginstall software apapun atau terkendala memori laptop.

1. Buka browser (Google Chrome / Edge) dan kunjungi:  
   👉 **[https://dartpad.dev](https://dartpad.dev)**
2. Jika ada kode bawaan di layar, **hapus semua kode tersebut** (`Ctrl + A` ➡️ `Backspace`).
3. Buka file **`lib/screens/home_screen.dart`** dan **`lib/main.dart`** dari template ini.
4. Copy seluruh kodingan ke DartPad.
5. Klik tombol **Run** (biru) di pojok kanan atas DartPad.
6. **Hasil:** Tampilan aplikasi KantinKu akan langsung muncul di panel sebelah kanan browser!
7. Ubah teks/warna di panel kiri, lalu klik **Run** untuk melihat hasil modifikasi kelompokmu.

---

## 🔵 JALUR 2: Visual Studio Code (Paling Ringan & Cepat)
> Rekomendasi utama jika Android Studio terasa berat di laptop kamu.

### A. Jika Belum Terinstall Flutter di VS Code:
1. Buka aplikasi **VS Code**.
2. Buka menu **Extensions** di sidebar kiri (shortcut: `Ctrl + Shift + X` di Windows, atau `Cmd + Shift + X` di Mac).
3. Di kotak pencarian, ketik: **`Flutter`**.
4. Klik tombol **Install** pada ekstensi resmi Flutter (by *Dart-Code*). Tunggu beberapa detik hingga selesai.

### B. Menjalankan Project:
1. Ekstrak file **`AGS_Flutter_Starter.zip`** ke laptop kamu (misal: di folder `Documents/KantinKu`).
2. Di VS Code, klik menu **File** ➡️ **Open Folder...** ➡️ pilih folder **`AGS_Flutter_Starter`**.
3. Buka Terminal di VS Code (menu **Terminal** ➡️ **New Terminal** atau tekan `Ctrl + ~`).
4. Ketik perintah berikut lalu tekan Enter:
   ```bash
   flutter pub get
   ```
5. Di pojok kanan bawah jendela VS Code, klik target device lalu pilih **`Chrome (web)`** *(agar ringan dan tidak membebani laptop)*.
6. Tekan tombol **`F5`** pada keyboard (atau buka tab *Run and Debug* ➡️ klik tombol Play hijau).
7. Jendela Google Chrome akan otomatis terbuka menampilkan aplikasi KantinKu!
8. **Hot Reload:** Setiap kamu mengubah kode di `home_screen.dart` dan menekan **`Ctrl + S`** (`Cmd + S` di Mac), layar Chrome akan langsung terupdate dalam 1 detik.

---

## 🟢 JALUR 3: Android Studio (Jalur IDE Lengkap)
> Untuk siswa yang sudah menyiapkan Android Studio sejak Week 1.

### A. Pastikan Plugin Flutter Sudah Terpasang:
1. Buka aplikasi **Android Studio**.
2. Di layar selamat datang (atau menu **Android Studio / File** ➡️ **Settings** / **Preferences**):
   - Klik menu **Plugins** di sebelah kiri.
   - Pilih tab **Marketplace** di bagian atas.
   - Ketik **`Flutter`** di kotak pencarian.
   - Klik **Install** pada plugin resmi Flutter (by *flutter.dev*).
   - Klik **Restart IDE** jika diminta.

### B. Menjalankan Project:
1. Ekstrak file **`AGS_Flutter_Starter.zip`** ke laptop kamu.
2. Di Android Studio, klik **Open** (atau menu **File** ➡️ **Open...**).
3. Arahkan dan pilih folder **`AGS_Flutter_Starter`** ➡️ klik **OK**.
4. Ambil dependencies:
   - Buka file `lib/screens/home_screen.dart`.
   - Di bar notifikasi kuning di atas editor, klik **`Pub get`** (atau jalankan `flutter pub get` di tab *Terminal* bawah).
5. Pilih target device di toolbar bagian atas:
   - Pilih **`Chrome (web)`** (sangat direkomendasikan agar cepat), ATAU
   - Pilih emulator Android yang sudah kamu buat (misal: `Pixel 6 / 7`).
6. Klik tombol **Run** (ikon segitiga hijau Play `▶️`) di toolbar atas (atau shortcut `Shift + F10`).
7. **Hot Reload:** Klik ikon **Petir Kuning (`⚡`)** di toolbar atas atau simpan file (`Ctrl + S` / `Cmd + S`) untuk melihat perubahan secara instan.

---

## 🛠️ Panduan Koding: Menyesuaikan dengan Wireframe Figma

Semua pekerjaan koding kelompok kamu untuk Week 5 **HANYA** dilakukan di satu file:
📁 **`lib/screens/home_screen.dart`**

> ⚠️ *File `lib/main.dart` sudah disiapkan oleh guru dan tidak perlu diubah hari ini.*

Buka `lib/screens/home_screen.dart`, cari komentar bertanda **`[GANTI DI SINI]`**:

### 1. Komponen A: Header & Saldo Siswa
- **Avatar:** Ganti inisial `'BP'` dengan inisial nama persona kelompok kamu (misal: `'SK'`).
- **Nama & Kelas:** Ganti `'Budi Pratama'` dan `'Kelas 10-B • AGS'`.
- **Saldo:** Ganti nominal `'Rp 45.000'` sesuai kebutuhan wireframe kamu.

### 2. Komponen B: Banner Promo / Menu Spesial
- **Label Promo:** Ganti `'MENU SPESIAL HARI INI'`.
- **Judul Promo:** Ganti `'Nasi Goreng Spesial Kantin'` dengan menu promo tim kamu.
- **Deskripsi:** Ganti teks promo jam istirahat.
- **Warna Banner:** Ubah kode warna gradien di bagian `colors: [Color(0xFF0A5A61), Color(0xFF0E7C86)]`.

### 3. Komponen C: Daftar Menu Populer
Di template sudah disediakan **3 contoh kartu menu** (Mie Ayam Bakso, Nasi Ayam Geprek, dan Es Teh Manis Jumbo):
- Ubah nama makanan/minuman, harga, nama stan penjual, dan ikon tombol pesan.
- Ingin menambah menu ke-4? Cukup **copy-paste** satu blok `Container` menu dan ganti isinya!

---

## ❓ Solusi Kendala Umum (Troubleshooting)

| Kendala | Penyebab | Solusi Cepat |
|---|---|---|
| **Layar HP muncul garis belang kuning-hitam (Overflow)** | Konten melebihi ukuran layar HP | Pastikan seluruh isi berada di dalam `SingleChildScrollView` (sudah disediakan di template). |
| **Garis Merah di Kode Editor** | Kurang tanda koma `,`, titik koma `;`, atau tutup kurung `)` | Cek baris sebelum tanda merah, pastikan semua kurung buka `(` ada pasangannya `)`. |
| **Emulator Android Lambat / Berat / Crash** | RAM laptop penuh | **Ganti device target ke `Chrome (web)`** di pojok kanan bawah VS Code atau toolbar Android Studio. Jauh lebih ringan! |
| **Android Studio tidak bisa Run** | Plugin Flutter belum terinstall | Masuk ke **Settings** ➡️ **Plugins** ➡️ **Marketplace** ➡️ install **Flutter** ➡️ Restart IDE. |

---

## 📤 Pengumpulan Tugas (Sebelum Kelas Berakhir)

Setiap kelompok wajib mengumpulkan ke **Google Classroom: Sprint 1 UI Submission**:
1. **Screenshot Aplikasi:** Tangkapan layar aplikasi KantinKu yang sudah berjalan di browser / emulator.
2. **Source Code:** Zip kembali folder `AGS_Flutter_Starter` yang sudah kamu modifikasi.

---
*Semoga sukses dan selamat membangun aplikasi mobile pertamamu! 🚀*
