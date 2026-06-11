# Kasir Kilat

Kasir Kilat adalah aplikasi POS/kasir Flutter untuk demo akademik UMKM.
Aplikasi memakai Firebase Cloud Firestore sebagai database real-time dan GetX
untuk state management.

## Fitur Utama

- Login user berdasarkan collection Firestore `users`.
- Role `admin` dan `karyawan`.
- Dashboard ringkasan penjualan dan stok.
- Transaksi kasir dengan update stok produk.
- Manajemen produk/barang.
- Laporan transaksi harian, mingguan, bulanan, dan ekspor CSV.
- Scanner barcode menggunakan `mobile_scanner`.

## Akun Demo

Pastikan dokumen di collection `users` memiliki field:

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

Admin dapat membuka menu Kelola. Karyawan tidak dapat membuka menu Kelola.

## Setup

1. Clone repository:

   ```bash
   git clone https://github.com/Frizr/KasirKilat.git
   cd KasirKilat
   ```

2. Pasang dependency:

   ```bash
   flutter pub get
   ```

3. Setup Firebase Android:

   - Buat project Firebase.
   - Tambahkan app Android dengan package name `com.tutu.cashier`.
   - Unduh `google-services.json`.
   - Letakkan file tersebut di `android/app/google-services.json`.
   - Aktifkan Cloud Firestore.
   - Buat collection `users`, `barang`, dan `transaksi`.

4. Jalankan aplikasi:

   ```bash
   flutter run
   ```

## Catatan Security

Project ini masih membandingkan password plaintext di Firestore untuk kebutuhan
demo akademik. Jangan gunakan pola ini untuk production. Untuk production,
gunakan Firebase Authentication atau password hashing yang benar, rules
Firestore yang ketat, dan jangan izinkan client membaca password.

## Troubleshooting Android

Jika muncul error Kotlin incremental cache atau error terkait `mobile_scanner`,
coba bersihkan cache build tanpa menghapus fitur scanner:

```bash
flutter clean
flutter pub get
cd android
./gradlew clean
cd ..
flutter build apk --debug
```

Di Windows PowerShell:

```powershell
flutter clean
flutter pub get
cd android
.\gradlew.bat clean
cd ..
flutter build apk --debug
```

Jika error tetap muncul karena cache berada di root drive berbeda antara
Pub Cache `C:\` dan project `D:\`, hapus cache build Gradle project
(`build/` dan `android/.gradle/`) lalu jalankan ulang perintah di atas. Jika
masih gagal, pertimbangkan update atau downgrade `mobile_scanner` setelah
mengecek kompatibilitas Flutter, Kotlin, dan Android Gradle Plugin yang dipakai.

Project ini juga menonaktifkan Kotlin incremental cache di
`android/gradle.properties` sebagai mitigasi error lintas drive tersebut.

## Struktur Project

- `lib/auth/`: login dan kelola user.
- `lib/controller/`: controller GetX untuk auth, user, barang, dan transaksi.
- `lib/dashboard/`: dashboard.
- `lib/barang/`: manajemen produk.
- `lib/transaksi/`: alur transaksi dan riwayat.
- `lib/laporan/`: laporan penjualan.
- `lib/manage/`: utilitas seperti formatter dan scanner.
- `lib/theme/`: warna dan theme aplikasi.
