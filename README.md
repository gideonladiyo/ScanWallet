# ScanWallet

ScanWallet membantu kamu mencatat dan memahami keuangan harian dengan lebih
praktis. Foto struk, rapikan detail transaksi, dan tetap bisa mencatat meski
sedang tidak terhubung ke internet.

## Apa yang bisa dilakukan

- Scan struk dan bukti pembayaran dari kamera atau galeri.
- Mencatat pemasukan dan pengeluaran secara manual.
- Mengatur beberapa dompet atau rekening dalam satu aplikasi.
- Mengelompokkan transaksi berdasarkan kategori.
- Melihat saldo, transaksi terbaru, dan ringkasan pengeluaran.
- Tetap mencatat saat offline; data akan disinkronkan saat koneksi kembali.
- Masuk dengan email atau Google.

## Download

Versi Android yang sudah dirilis tersedia di halaman
[Releases](https://github.com/USERNAME/REPOSITORY/releases). Pilih versi terbaru,
lalu download file APK untuk memasangnya di perangkat Android.

> Tautan di atas akan aktif setelah repository ini dibuat di GitHub.

## Cara mulai

1. Install APK dari halaman Releases.
2. Buat akun atau masuk dengan akun yang sudah ada.
3. Tambahkan rekening/dompet yang ingin dipakai.
4. Scan struk atau tambahkan transaksi secara manual.
5. Periksa ringkasan keuanganmu dari halaman dashboard.

## Versi dan catatan rilis

Setiap versi aplikasi dibuat sebagai GitHub Release, misalnya `v1.0.0` atau
`v1.1.0`. Catatan rilis menjelaskan perubahan yang terlihat atau dirasakan oleh
pengguna. File APK untuk versi tersebut tersedia di halaman release yang sama.

## Untuk developer

<details>
<summary>Buka panduan setup project</summary>

### Persyaratan

- Flutter 3.32+ / Dart 3.8+
- Android Studio untuk Android atau Xcode untuk iOS
- Project Supabase

### Setup Supabase

Buat project Supabase, lalu jalankan [`supabase/schema.sql`](supabase/schema.sql)
di Supabase SQL Editor. Script ini menyiapkan database dan aturan akses data.

### Menjalankan project

Salin `.env.example` menjadi `.env`, lalu isi nilai konfigurasi lokal. File
`.env` tidak boleh di-commit.

```bash
flutter pub get
flutter run --dart-define-from-file=.env
```

Untuk memeriksa project:

```bash
flutter analyze
flutter test
```

### Release Android

Workflow [release.yml](.github/workflows/release.yml) membuat APK dan GitHub
Release saat tag versi seperti `v1.0.0` dipush. Repository Secrets yang
diperlukan: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, dan `GOOGLE_WEB_CLIENT_ID`
(optional).

</details>