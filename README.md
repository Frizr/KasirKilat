# Kasir Kilat

Kasir Kilat adalah aplikasi POS/kasir berbasis Flutter untuk membantu proses
penjualan UMKM. Aplikasi ini memakai Firebase Cloud Firestore untuk database
real-time dan GetX untuk state management.

README ini dibuat sebagai panduan agar client atau penguji dapat memahami,
menjalankan, dan mengetes project dengan benar.

## Ringkasan Fitur

- Login user dari collection Firestore `users`.
- Role `admin` dan `karyawan`.
- Dashboard ringkasan penjualan dan stok.
- Transaksi kasir dengan pengurangan stok.
- Manajemen produk/barang.
- Laporan penjualan harian, mingguan, bulanan, dan ekspor CSV.
- Scanner barcode memakai `mobile_scanner`.

## Kebutuhan Awal

Pastikan komputer sudah memiliki:

- Flutter SDK.
- Android Studio atau VS Code.
- Android SDK dan emulator Android, atau perangkat Android fisik.
- Java/JDK yang sesuai dengan Android Studio.
- Akses ke Firebase Project.
- Terminal PowerShell, Command Prompt, atau terminal bawaan IDE.

Cek instalasi Flutter:

```powershell
flutter doctor
```

Jika ada error di `flutter doctor`, selesaikan dulu sebelum menjalankan project.

## Clone dan Install Dependency

1. Clone repository:

   ```powershell
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

## Struktur Data Firestore

### Collection `users`

Field yang dibutuhkan:

```text
nama: String
username: String
password: String
role: String        // admin atau karyawan
aktif: Boolean
createdAt: Timestamp
```

Contoh akun demo:

| Role | Username | Password |
| --- | --- | --- |
| Admin | `admin01` | `admin123` |
| Karyawan | `kasir01` | `kasir123` |

Catatan role:

- `admin` bisa membuka menu Kelola dan mengatur user.
- `karyawan` tidak bisa membuka menu Kelola.

### Collection `barang`

Field umum produk:

```text
bar: String
nama: String
harga: Number
jumlah: Number
modal: Number
tgl: Timestamp
```

### Collection `transaksi`

Transaksi dibuat otomatis oleh aplikasi saat checkout.

Field umum:

```text
data: Array
bayar: Number
metode: String
tgl: Timestamp
```

Setiap item transaksi menyimpan data produk, jumlah beli, total harga, dan
modal produk saat transaksi dibuat.

## Menjalankan Project untuk Testing Bug

Gunakan mode debug saat masih mengetes bug atau fitur baru.

### Jalankan di emulator/perangkat

```powershell
flutter run --debug
```

Jika ada lebih dari satu device:

```powershell
flutter devices
flutter run --debug -d <device_id>
```

Mode debug cocok untuk:

- Melihat log error di terminal.
- Mengecek bug login, transaksi, stok, laporan, dan scanner.
- Testing perubahan kode harian.

### Build APK debug

Gunakan ini jika ingin mengirim APK debug ke tester:

```powershell
flutter build apk --debug
```

Output APK:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

APK debug cocok untuk test internal. Jangan pakai APK debug untuk rilis final.

## Build untuk Tes Final atau Release

Gunakan mode release saat fitur sudah dianggap siap dan ingin dites performa
final.

```powershell
flutter build apk --release
```

Output APK:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Catatan penting:

- Build release lebih cepat dan ringan saat dijalankan.
- Log debug tidak sebanyak mode debug.
- Jika ingin publish ke Play Store, konfigurasi signing release harus dibuat
  dengan keystore resmi. Jangan membagikan file keystore atau password ke repo.

## Alur Testing Manual

Gunakan checklist ini setelah menjalankan aplikasi.

1. Login admin:

   ```text
   username: admin01
   password: admin123
   ```

   Pastikan menu Kelola muncul.

2. Login karyawan:

   ```text
   username: kasir01
   password: kasir123
   ```

   Pastikan menu Kelola tidak muncul.

3. Test produk:

   - Tambah produk.
   - Edit produk.
   - Hapus produk.
   - Pastikan stok tampil benar.

4. Test transaksi:

   - Tambahkan produk ke keranjang.
   - Checkout dengan stok cukup.
   - Pastikan transaksi tersimpan.
   - Pastikan stok produk berkurang.
   - Coba checkout lebih dari stok, transaksi harus gagal dan cart tidak hilang.

5. Test laporan:

   - Buka filter Hari Ini.
   - Buka filter Minggu Ini.
   - Buka filter Bulan Ini.
   - Pastikan total transaksi dan pendapatan sesuai.

6. Test scanner:

   - Buka fitur scanner.
   - Beri izin kamera.
   - Scan barcode.
   - Pastikan hasil scan masuk ke flow aplikasi.

## Command yang Sering Dipakai

Membersihkan build cache:

```powershell
flutter clean
flutter pub get
```

Cek error kode:

```powershell
flutter analyze
```

Run debug:

```powershell
flutter run --debug
```

Build APK debug:

```powershell
flutter build apk --debug
```

Build APK release:

```powershell
flutter build apk --release
```

Lihat device:

```powershell
flutter devices
```

## Troubleshooting

### Dependency error

Jalankan:

```powershell
flutter clean
flutter pub get
flutter analyze
```

### Build Android error

Jalankan:

```powershell
flutter clean
flutter pub get
cd android
.\gradlew.bat clean
cd ..
flutter build apk --debug
```

### Error Kotlin incremental cache atau `mobile_scanner`

Project ini sudah menonaktifkan Kotlin incremental cache di:

```text
android/gradle.properties
```

Konfigurasi tersebut membantu menghindari error saat Pub Cache berada di drive
`C:\` tetapi project berada di drive `D:\`.

Jika error masih muncul:

```powershell
flutter clean
flutter pub get
flutter build apk --debug
```

### Login gagal

Cek hal berikut:

- Collection `users` sudah ada.
- Field user sesuai struktur README.
- `username` dan `password` benar.
- Field `aktif` bernilai `true`.
- Field `role` bernilai `admin` atau `karyawan`.
- Perangkat memiliki koneksi internet.
- Firestore rules mengizinkan aplikasi membaca data login untuk kebutuhan demo.

## Catatan Keamanan

Untuk demo akademik, project ini masih memakai password plaintext di Firestore.
Jangan gunakan pola ini untuk production.

Untuk production, gunakan:

- Firebase Authentication.
- Password hashing yang aman.
- Firestore rules yang ketat.
- Pembatasan akses data user.
- Signing APK release dengan keystore resmi.

## Struktur Folder

```text
lib/auth/          login dan kelola user
lib/controller/    controller GetX untuk auth, user, barang, transaksi
lib/dashboard/     halaman dashboard
lib/barang/        manajemen produk
lib/transaksi/     transaksi dan riwayat
lib/laporan/       laporan penjualan
lib/manage/        formatter, scanner, utilitas tambahan
lib/theme/         warna dan tema aplikasi
android/           konfigurasi Android
assets/            gambar, font, dan aset aplikasi
```

## Catatan untuk Client

Gunakan `flutter run --debug` atau `flutter build apk --debug` saat masih
mengetes bug. Gunakan `flutter build apk --release` hanya untuk tes final atau
paket rilis setelah fitur dianggap stabil.

Jika terjadi error, kirimkan screenshot terminal dan jelaskan langkah yang
dilakukan sebelum error muncul.
