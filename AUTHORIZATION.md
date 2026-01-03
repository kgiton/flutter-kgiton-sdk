# 🔐 Authorization Guide

Panduan untuk mendapatkan otorisasi penggunaan KGiTON Flutter SDK.

---

## ⚠️ Proprietary Software

**KGiTON Flutter SDK adalah perangkat lunak komersial milik PT KGiTON.**

Penggunaan SDK ini memerlukan:
1. License key yang valid
2. Otorisasi resmi dari PT KGiTON
3. Persetujuan terhadap Terms of Service

---

## 📋 Cara Mendapatkan Otorisasi

### 1. Pembelian License Key

License key dapat diperoleh melalui:

| Channel | Kontak |
|---------|--------|
| Website | https://www.kgiton.com |
| Email | support@kgiton.com |
| WhatsApp | +62 858-1191-2633 |


### 2. Tipe License

| Tipe | Deskripsi | Durasi |
|------|-----------|--------|
| **Buy** | Pembelian putus | Selamanya |
| **Rent** | Sewa bulanan | Sesuai periode |

### 3. Proses Registrasi

1. **Beli license key** dari channel resmi
2. **Download SDK** dari repository
3. **Register akun** dengan license key:
   ```dart
   await api.auth.register(
     email: 'your@email.com',
     password: 'password',
     confirmPassword: 'password',
     licenseKey: 'YOUR-LICENSE-KEY',
   );
   ```
4. **Mulai gunakan** SDK

---

## 🎫 License Key

### Format

```
XXXX-XXXX-XXXX-XXXX
```

### Karakteristik

- **Unik** - Setiap license key hanya bisa digunakan sekali
- **1 License = 1 Device** - Setiap license terhubung ke 1 perangkat timbangan

---

## 💰 Sistem Token

### Penggunaan Token

- **1 Token = 1 Sesi Penimbangan**
- Token harus dibeli (top-up) sebelum menggunakan timbangan
- Saldo token tersimpan per license key

### Top-up Token

Beli token melalui aplikasi dengan metode:
- Virtual Account (BRI, BNI, BCA, Mandiri, dll)
- QRIS
- Checkout Page

---

## 📜 Terms of Service

Dengan menggunakan SDK ini, Anda menyetujui:

1. **Tidak mendistribusikan** SDK tanpa izin
2. **Tidak memodifikasi** kode untuk tujuan ilegal
3. **Tidak reverse-engineer** protokol komunikasi
4. **Menjaga kerahasiaan** license key
5. **Menggunakan sesuai** tujuan yang diizinkan

---

## ❓ FAQ

### Q: Apakah bisa trial dulu?

A: Hubungi support@kgiton.com untuk demo dan trial license.

### Q: Berapa harga license?

A: Hubungi support@kgiton.com untuk informasi harga terkini.

### Q: Token tidak bisa digunakan?

A: Pastikan license key aktif dan saldo mencukupi.

---

## 📞 Kontak

| Keperluan | Kontak |
|-----------|--------|
| Pembelian | support@kgiton.com |
| Support Teknis | support@kgiton.com |
| Partnership | support@kgiton.com |

---

<p align="center">
  <strong>PT KGiTON</strong> © 2026
</p>
