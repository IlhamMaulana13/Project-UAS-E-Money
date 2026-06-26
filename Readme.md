# Dompet Kampus Global — Aplikasi E-Money Mobile

> Tugas Akhir Semester 6 · Aplikasi Mobile Lanjutan

---

## Identitas Mahasiswa

|           |                             |
| --------- | --------------------------- |
| **Nama**  | MHAMMAD ILHAM MAULANA       |
| **NIM**   | 1123150141                  |
| **Kelas** | TI 23 SH SE                 |
| **Email** | mhmmad13ilhammlna@gmail.com |

---

## Deskripsi Aplikasi

**Dompet Kampus Global** adalah aplikasi e-money berbasis mobile yang dirancang khusus untuk ekosistem kampus. Aplikasi ini memungkinkan mahasiswa melakukan transaksi keuangan digital secara cepat, aman, dan efisien — mulai dari top up saldo, transfer antar pengguna, hingga pembayaran ke merchant menggunakan sistem deep link lintas aplikasi.

### Fitur Utama

| Fitur                   | Deskripsi                                                                          |
| ----------------------- | ---------------------------------------------------------------------------------- |
| **Autentikasi**         | Register, login, verifikasi email, dan 2FA (SMTP / TOTP / Notifikasi)              |
| **Top Up Saldo**        | Isi saldo dompet digital secara instan                                             |
| **Transfer**            | Kirim uang ke sesama pengguna Dompet Kampus                                        |
| **Pembayaran Merchant** | Bayar ke merchant via deep link (`dompetkampus://pay?...`) dari aplikasi eksternal |
| **Riwayat Transaksi**   | Lihat seluruh histori transaksi dengan detail lengkap                              |
| **PIN Keamanan**        | Setiap transaksi dikonfirmasi menggunakan PIN 6 digit yang tersimpan aman          |
| **Halaman Sukses**      | Bukti transaksi dengan detail lengkap dan callback otomatis ke merchant            |
| **Notifikasi Push**     | Firebase Cloud Messaging untuk notifikasi transaksi real-time                      |

---

## Arsitektur Aplikasi

Aplikasi ini menggunakan **Clean Architecture** dengan pemisahan tiga lapisan utama, ditambah backend REST API terpisah berbasis Go.

```
┌─────────────────────────────────────────────────────┐
│                   FLUTTER APP                       │
│                                                     │
│  ┌─────────────┐  ┌──────────────┐  ┌───────────┐  │
│  │Presentation │  │   Domain     │  │   Data    │  │
│  │             │  │              │  │           │  │
│  │ • Pages     │  │ • Entities   │  │ • Models  │  │
│  │ • BLoCs     │  │ • UseCases   │  │ • Repos   │  │
│  │ • Widgets   │  │ • Repos(IF)  │  │ • Remote  │  │
│  └─────────────┘  └──────────────┘  │ • Local   │  │
│                                     └───────────┘  │
└─────────────────────────────────────────────────────┘
                        │ HTTP/REST
                        ▼
┌─────────────────────────────────────────────────────┐
│               GO BACKEND (REST API)                 │
│                                                     │
│  handlers/ · middleware/ · models/ · services/      │
│  PostgreSQL · Firebase Admin SDK · JWT Auth         │
│  VPS: 202.155.95.224:8082                           │
└─────────────────────────────────────────────────────┘
```

### Layer Detail

**Presentation Layer**

- `BLoC` (Business Logic Component) sebagai state management — `AuthBloc`, `PaymentBloc`, `AccountBloc`, `OtpBloc`
- `GoRouter` untuk navigasi deklaratif dengan deep link support
- Halaman: splash, auth (login/register/2FA), home, transfer, topup, payment, merchant, history, akun, success

**Domain Layer**

- Use cases terpisah per fitur: `auth/`, `account/`, `payment/`
- Interface repository (abstraksi dari implementasi data)
- Entities sebagai model bisnis murni

**Data Layer**

- `RemoteDataSource` — komunikasi ke backend via `Dio` HTTP client
- `LocalDataSource` — penyimpanan aman via `FlutterSecureStorage` (JWT token, PIN, user data)
- Repository implementations yang menggabungkan remote + local

**Backend (Go)**

- REST API dengan struktur: `handlers/` → `services/` → `models/`
- JWT middleware untuk autentikasi
- Firebase Admin SDK untuk push notification
- Mendukung `otp_type: "pin"` untuk validasi PIN dari Flutter

---

## Cara Menjalankan Proyek

### Prasyarat

- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- Android SDK (min API 21)
- Go `>=1.21` (untuk backend)
- PostgreSQL (untuk database backend)

### 1. Clone Repository

```bash
git clone <url-repository>
cd E-MoneyUAS
```

### 2. Setup Flutter App

```bash
cd e-money

# Install dependencies
flutter pub get

# Pastikan device/emulator terhubung
flutter devices

# Jalankan aplikasi
flutter run
```

### 3. Build APK (Release)

```bash
cd e-money
flutter build apk --release
# APK tersedia di: build/app/outputs/flutter-apk/app-release.apk
```

### 4. Setup & Jalankan Backend (Opsional — sudah berjalan di VPS)

```bash
cd backend

# Copy environment variables
cp .env.example .env
# Edit .env: isi DB_URL, JWT_SECRET, Firebase credentials

# Dengan Docker
docker-compose up -d

# Atau manual
go mod tidy
go build -o app .
./app
```

> **Catatan:** Backend sudah berjalan di VPS `202.155.95.224:8082`. Untuk development lokal, ubah `baseUrl` di `e-money/lib/core/constants/app_constants.dart`.

---

## Daftar Dependensi Utama

### Flutter (Frontend)

| Package                  | Versi   | Fungsi                          |
| ------------------------ | ------- | ------------------------------- |
| `flutter_bloc`           | ^9.0.0  | State management (BLoC pattern) |
| `go_router`              | ^14.8.1 | Navigasi deklaratif & deep link |
| `dio`                    | ^5.7.0  | HTTP client untuk REST API      |
| `flutter_secure_storage` | ^9.2.2  | Penyimpanan aman (JWT, PIN)     |
| `firebase_messaging`     | ^15.2.4 | Push notification               |
| `firebase_auth`          | ^5.5.2  | Firebase authentication         |
| `google_sign_in`         | ^6.2.2  | Login dengan Google             |
| `mobile_scanner`         | ^7.0.0  | Scan QR code                    |
| `app_links`              | ^6.3.2  | Deep link handler               |
| `url_launcher`           | ^6.3.1  | Buka URL / callback ke merchant |
| `get_it`                 | ^8.0.2  | Dependency injection            |
| `equatable`              | ^2.0.5  | Perbandingan object BLoC states |
| `shared_preferences`     | ^2.3.4  | Preferensi lokal ringan         |
| `intl`                   | ^0.19.0 | Format angka & tanggal (Rupiah) |
| `shimmer`                | ^3.0.0  | Loading skeleton UI             |
| `cached_network_image`   | ^3.4.1  | Cache gambar dari network       |

### Backend (Go)

| Package             | Fungsi                       |
| ------------------- | ---------------------------- |
| `gin` / `net/http`  | HTTP router & server         |
| `golang-jwt/jwt`    | JWT authentication           |
| `lib/pq`            | PostgreSQL driver            |
| `firebase-admin-go` | Push notification & Firebase |

---

## Screenshot Aplikasi

> Screenshot diambil dari perangkat Android (OPPO CPH2217)

### Autentikasi & Onboarding

| Login          | Register       | Verifikasi 2FA |
| -------------- | -------------- | -------------- |
| _(screenshot)_ | _(screenshot)_ | _(screenshot)_ |

### Fitur Utama

| Home           | Transfer       | Top Up         |
| -------------- | -------------- | -------------- |
| _![Home](e-money/assets/screenshots/home.jpg)_ | _(screenshot)_ | _(screenshot)_ |

| PIN Keamanan   | Pembayaran Merchant | Halaman Sukses |
| -------------- | ------------------- | -------------- |
| _(screenshot)_ | _(screenshot)_      | _(screenshot)_ |

### Riwayat & Akun

| Riwayat Transaksi | Halaman Akun   | Ubah PIN       |
| ----------------- | -------------- | -------------- |
| _(screenshot)_    | _(screenshot)_ | _(screenshot)_ |

> **Cara menambah screenshot:** Ganti teks `*(screenshot)*` dengan sintaks `![nama](assets/screenshots/nama-file.png)` lalu taruh file PNG di folder `assets/screenshots/`.

---

## Link Video Presentasi

> **Video demo & presentasi aplikasi:**

🎬 **[Tonton di YouTube — (link akan diisi)](...)**

<!-- Ganti (...) dengan URL YouTube setelah video diunggah -->

---

## Catatan Teknis

- **Minimum Android:** API 21 (Android 5.0 Lollipop)
- **Target Android:** API 34 (Android 14)
- **Deep Link Scheme:** `dompetkampus://pay?amount=...&merchant_id=...`
- **Autentikasi:** JWT Bearer Token + 2FA opsional
- **PIN:** Disimpan lokal di `FlutterSecureStorage`, tidak dikirim ke server — backend menerima `otp_type: "pin"` selama JWT valid

---

_Institut Teknologi dan Bisnis Bina Sarana Global_
