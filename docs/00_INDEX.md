# 📚 Dokumentasi KGiTON Flutter SDK (Client Edition)

Selamat datang di dokumentasi KGiTON Flutter SDK. Panduan ini akan membantu Anda mengintegrasikan SDK ke dalam aplikasi Flutter Anda.

---

## 📖 Daftar Isi

| # | Dokumen | Deskripsi |
|---|---------|-----------|
| 1 | [Getting Started](01_GETTING_STARTED.md) | Instalasi, konfigurasi, dan setup awal |
| 2 | [Authentication](02_AUTHENTICATION.md) | Login, register, session, password reset |
| 3 | [License & Token](03_LICENSE_TOKEN.md) | Validasi license, saldo token, penggunaan token |
| 4 | [Top-up & Payment](04_TOPUP_PAYMENT.md) | Top-up token, metode pembayaran, status transaksi |
| 5 | [BLE Integration](05_BLE_INTEGRATION.md) | Koneksi ke timbangan, streaming berat, buzzer |
| 6 | [API Reference](06_API_REFERENCE.md) | Referensi lengkap semua API |
| 7 | [Troubleshooting](07_TROUBLESHOOTING.md) | Masalah umum dan solusinya |
| 8 | [Connection Sequence Diagram](08_CONNECTION_SEQUENCE_DIAGRAM.md) | Diagram alur koneksi ke timbangan |
| 9 | [Partner Payment](09_PARTNER_PAYMENT.md) | Generate pembayaran QRIS/Checkout untuk partner |

---

## 🚀 Quick Links

### Untuk Pemula
1. Mulai dari [Getting Started](01_GETTING_STARTED.md)
2. Pelajari [Authentication](02_AUTHENTICATION.md)
3. Pahami [License & Token](03_LICENSE_TOKEN.md)

### Untuk Integrasi Pembayaran
1. Baca [Top-up & Payment](04_TOPUP_PAYMENT.md)
2. Lihat contoh kode lengkap

### Untuk Integrasi Timbangan
1. Baca [BLE Integration](05_BLE_INTEGRATION.md)
2. Pastikan izin Bluetooth sudah dikonfigurasi

---

## 🏗️ Arsitektur SDK

```
KGiTON SDK
├── API Integration
│   ├── KgitonApiService      (Main service facade)
│   ├── KgitonAuthService     (Authentication)
│   ├── KgitonUserService     (User & token operations)
│   ├── KgitonLicenseService  (License validation)
│   ├── KgitonTopupService    (Token top-up)
│   ├── KgitonLicenseTransactionService (Purchase/subscription)
│   └── KgitonPartnerPaymentService (Partner payment generation)
│
├── BLE Integration
│   ├── KgitonScaleService    (Scale connection & control)
│   └── PermissionHelper      (Permission management)
│
└── Helpers
    ├── KgitonAuthHelper      (Simplified auth with storage)
    ├── KgitonLicenseHelper   (Simplified license operations)
    └── KgitonTopupHelper     (Simplified top-up operations)
```

---

## 📱 Platform Support

| Platform | Minimum Version | Status |
|----------|-----------------|--------|
| Android | 5.0 (API 21) | ✅ Supported |
| iOS | 12.0 | ✅ Supported |

---

## 🔗 Resources

- [GitHub Repository](https://github.com/AkhmadFahr662/flutter-kgiton-sdk)
- [API Documentation](https://api.kgiton.com/docs)
- [Support](mailto:support@kgiton.com)

---

<p align="center">
  <strong>PT KGiTON</strong> © 2026
</p>
