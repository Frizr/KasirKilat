# Kasir Kilat

Kasir Kilat adalah aplikasi Point of Sales (POS) / Kasir digital modern yang dirancang khusus untuk UMKM (Usaha Mikro, Kecil, dan Menengah). Aplikasi ini dibangun dengan menggunakan arsitektur yang bersih, antarmuka yang elegan (tema Dark Navy & Teal), dan dukungan database real-time.

## 📸 Screenshot Aplikasi

<div align="center">
  <img src="assets/dashboard.png" width="200" alt="Dashboard" />
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="assets/transaksi.png" width="200" alt="Transaksi" />
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="assets/produk.png" width="200" alt="Produk" />
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="assets/laporan.png" width="200" alt="Laporan" />
</div>

## ✨ Fitur Utama

Aplikasi ini memiliki 4 pilar fitur utama yang dapat diakses melalui navigasi bawah:

1. **📊 Dashboard**
   - Ringkasan performa bisnis.
   - Akses cepat ke metrik penting toko.
2. **💱 Transaksi**
   - Pencatatan transaksi penjualan secara real-time.
   - Manajemen keranjang belanja yang cepat dan responsif.
3. **📦 Manajemen Produk (Barang)**
   - Tambah, Edit, dan Hapus (CRUD) produk.
   - Sinkronisasi otomatis dengan database cloud.
4. **📈 Laporan**
   - Visualisasi data penjualan (Bar Charts).
   - Pembuatan (generate) dokumen CSV untuk laporan penjualan.

**Fitur Tambahan:**
- **Real-time Synchronization:** Menggunakan Firebase Cloud Firestore untuk sinkronisasi data antar perangkat.
- **Local Notifications:** Notifikasi lokal untuk pengingat atau aksi tertentu.
- **Camera Integration:** Pengambilan gambar langsung dari dalam aplikasi.
- **Pull-to-Refresh:** Pembaruan data manual dengan gestur tarik layar ke bawah/atas.

## 🛠️ Teknologi & Arsitektur

- **Framework:** [Flutter](https://flutter.dev/) (SDK >=3.4.0 <4.0.0)
- **State Management:** [GetX](https://pub.dev/packages/get)
- **Database & Storage:** [Firebase Cloud Firestore](https://firebase.google.com/docs/firestore) & [Firebase Storage](https://firebase.google.com/docs/storage)
- **UI & Styling:** Custom Theme (AppColors & AppTheme) dengan sentuhan warna *Navy* dan *Teal*. Lottie untuk animasi.
- **Lainnya:**
  - `intl` untuk format tanggal dan mata uang.
  - `responsive_grid` untuk layout grid dinamis.
  - `flutter_slidable` untuk interaksi geser pada list.

## 🚀 Memulai (Getting Started)

### Prasyarat
- Flutter SDK (Versi terbaru disarankan, >=3.4.0)
- Android Studio / VS Code
- Akses ke Firebase Project (file `google-services.json` untuk Android atau `GoogleService-Info.plist` untuk iOS sudah harus terkonfigurasi)

### Instalasi & Menjalankan Aplikasi

1. **Clone repositori ini** (jika menggunakan git):
   ```bash
   git clone https://github.com/Frizr/KasirKilat.git
   cd KasirKilat
   ```

2. Ambil dependency Flutter:

   ```powershell
   flutter pub get
   ```

3. Cek kualitas kode:

   ```powershell
   flutter analyze
   ```

   Hasil ideal:

   ```text
   No issues found!
   ```

## Setup Firebase

Project Android memakai package name:

```text
com.tutu.cashier
```

Langkah setup:

1. Buka Firebase Console.
2. Buat atau pilih Firebase Project.
3. Tambahkan aplikasi Android dengan package name `com.tutu.cashier`.
4. Download file `google-services.json`.
5. Letakkan file tersebut di:

   ```text
   android/app/google-services.json
   ```

6. Aktifkan Cloud Firestore.
7. Buat collection utama:

   ```text
   users
   barang
   transaksi
   ```

## 📁 Struktur Proyek (lib/)

- `barang/`: Layar dan komponen untuk manajemen produk.
- `controller/`: Logika state management GetX (contoh: `barangcontroller.dart`, `transaksicontroller.dart`).
- `dashboard/`: Antarmuka layar utama/dashboard.
- `laporan/`: Antarmuka dan logika laporan penjualan, grafik, pembukuan, dan export CSV.
- `manage/`: Manajemen aplikasi tambahan.
- `notification/`: Service untuk notifikasi lokal.
- `theme/`: Definisi warna, tipografi, dan tema aplikasi (`app_colors.dart`, `app_theme.dart`).
- `transaksi/`: Layar untuk mengelola transaksi POS.

---
*Dibuat untuk memudahkan operasional UMKM menjadi lebih cepat dan kilat!*

