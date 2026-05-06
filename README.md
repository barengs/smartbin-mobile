# SmartBin Member Mobile 📱

Aplikasi mobile berbasis Flutter yang dirancang untuk member SmartBin agar dapat menabung sampah botol plastik, mengumpulkan poin, dan menukarkannya dengan saldo e-wallet.

## 🌟 Fitur Utama

- **Pendaftaran Member (NFC Support)**: Daftar menjadi pahlawan kebersihan dengan mudah. Mendukung pemindaian E-KTP via NFC untuk identitas yang lebih akurat.
- **Login Keamanan JWT**: Sistem autentikasi yang aman menggunakan JSON Web Token.
- **Dashboard Interaktif**: Pantau saldo poin Anda dan konversinya ke dalam Rupiah secara real-time.
- **Riwayat Aktivitas Terpilah**: Lihat riwayat setoran botol dan penukaran poin Anda dengan status transparan (Pending/Completed).
- **Tukar Poin (E-Wallet)**: Tukarkan poin Anda menjadi saldo GoPay, OVO, DANA, atau ShopeePay dengan sistem verifikasi admin.
- **Lokasi SmartBin Terdekat**: Temukan lokasi unit SmartBin di sekitar Anda melalui integrasi peta.
- **Profil & Keamanan**: Kelola data diri dan keamanan akun (PIN & Password).

## 🚀 Instalasi

1. **Prasyarat**:
   - Flutter SDK (Versi terbaru disarankan)
   - Android Studio / VS Code
   - Perangkat fisik Android (untuk pengujian NFC)

2. **Kloning Repositori**:
   ```bash
   git clone <repository-url>
   ```

3. **Instal Dependensi**:
   ```bash
   flutter pub get
   ```

4. **Konfigurasi API**:
   Buka `lib/core/config/app_config.dart` dan sesuaikan `baseUrl` dengan endpoint API Anda:
   ```dart
   static const String baseUrl = 'https://smartbin.umediatama.com/api/v1';
   ```

5. **Jalankan Aplikasi**:
   ```bash
   flutter run
   ```

## 🛠️ Tech Stack

- **Framework**: Flutter
- **State Management**: Provider
- **Networking**: Dio
- **Icons**: Lucide Icons
- **Fonts**: Google Fonts (Outfit)
- **Security**: JWT, SHA256

## 📖 Cara Penggunaan

1. **Pendaftaran**: Buka aplikasi, pilih "Daftar", tap E-KTP Anda ke sensor NFC smartphone (jika tersedia), isi data diri, dan buat PIN 6 digit.
2. **Menabung Sampah**: Datangi unit SmartBin terdekat, masukkan nomor HP/PIN atau scan QR di unit Kiosk.
3. **Melihat Riwayat**: Buka menu "Aktivitas" untuk melihat detail setoran botol Anda.
4. **Penukaran Poin**: Pilih menu "Tukar Poin" di dashboard, pilih e-wallet, masukkan nomor akun, dan tunggu persetujuan admin.

---
© 2024 SmartBin Team - Pamekasan Bersih
