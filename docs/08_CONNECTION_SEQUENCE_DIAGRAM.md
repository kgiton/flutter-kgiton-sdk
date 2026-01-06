# 📊 Flow Koneksi ke Timbangan KGiTON

Dokumentasi visual untuk alur koneksi ke timbangan KGiTON via Bluetooth Low Energy.

---

## 🎯 Overview - Alur Lengkap

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        FLOW KONEKSI TIMBANGAN KGiTON                        │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌──────────┐      ┌──────────┐      ┌──────────┐      ┌──────────┐
    │  START   │ ──▶  │   SCAN   │ ──▶  │ CONNECT  │ ──▶  │  READY   │
    └──────────┘      └──────────┘      └──────────┘      └──────────┘
         │                 │                 │                 │
         │                 │                 │                 │
         ▼                 ▼                 ▼                 ▼
    ┌──────────┐      ┌──────────┐      ┌──────────┐      ┌──────────┐
    │  Check   │      │  Find    │      │  Auth    │      │  Stream  │
    │Permission│      │ Devices  │      │ License  │      │  Weight  │
    └──────────┘      └──────────┘      └──────────┘      └──────────┘
```

---

## 📱 Komponen Sistem

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              ARSITEKTUR SISTEM                              │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│                 │    │                 │    │                 │
│   FLUTTER APP   │◀──▶│   KGiTON SDK    │◀──▶│   TIMBANGAN     │
│                 │    │                 │    │   (ESP32)       │
│  ┌───────────┐  │    │  ┌───────────┐  │    │                 │
│  │    UI     │  │    │  │  Scale    │  │    │  ┌───────────┐  │
│  │  Widget   │  │    │  │  Service  │  │    │  │ Load Cell │  │
│  └───────────┘  │    │  └───────────┘  │    │  └───────────┘  │
│       ▲         │    │       ▲         │    │       │         │
│       │         │    │       │         │    │       ▼         │
│       ▼         │    │       ▼         │    │  ┌───────────┐  │
│  ┌───────────┐  │    │  ┌───────────┐  │    │  │  Buzzer   │  │
│  │  State    │  │    │  │    BLE    │◀─┼────┼─▶│  Control  │  │
│  │ Manager   │  │    │  │   SDK     │  │    │  └───────────┘  │
│  └───────────┘  │    │  └───────────┘  │    │                 │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
        │                      │
        │                      ▼
        │              ┌─────────────────┐
        │              │                 │
        └─────────────▶│   KGiTON API    │
                       │   (Optional)    │
                       │                 │
                       └─────────────────┘
```

---

## 🔍 STEP 1: Scanning Perangkat

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           FLOW SCANNING PERANGKAT                           │
└─────────────────────────────────────────────────────────────────────────────┘

     FLUTTER APP                    SDK                         TIMBANGAN
          │                          │                              │
          │  1️⃣ scanForDevices()     │                              │
          │─────────────────────────▶│                              │
          │                          │                              │
          │                    ┌─────┴─────┐                        │
          │                    │  CHECK    │                        │
          │                    │PERMISSION │                        │
          │                    └─────┬─────┘                        │
          │                          │                              │
          │                    ┌─────┴─────┐                        │
          │                    │   START   │                        │
          │                    │   SCAN    │                        │
          │                    └─────┬─────┘                        │
          │                          │                              │
          │                          │  2️⃣ BLE Scan                 │
          │                          │─────────────────────────────▶│
          │                          │                              │
          │                          │      📡 Advertisement        │
          │                          │◀─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─│
          │                          │      (name: "KGiTON-XXX")    │
          │                          │                              │
          │                    ┌─────┴─────┐                        │
          │                    │  FILTER   │                        │
          │                    │  DEVICES  │                        │
          │                    └─────┬─────┘                        │
          │                          │                              │
          │  3️⃣ devicesStream        │                              │
          │◀─────────────────────────│                              │
          │  [ScaleDevice, ...]      │                              │
          │                          │                              │
     ┌────┴────┐                     │                              │
     │ DISPLAY │                     │                              │
     │ DEVICES │                     │                              │
     └────┬────┘                     │                              │
          │                          │                              │
          ▼                          ▼                              ▼


    ┌─────────────────────────────────────────────────────────────────────┐
    │                        📋 DATA YANG DITERIMA                        │
    ├─────────────────────────────────────────────────────────────────────┤
    │                                                                     │
    │   ScaleDevice {                                                     │
    │     name: "KGiTON-A1B2C3"     ← Nama perangkat                      │
    │     id: "AA:BB:CC:DD:EE:FF"   ← MAC Address                         │
    │     rssi: -45                 ← Kekuatan sinyal (dBm)               │
    │     licenseKey: "XXXX-..."   ← License key (jika pernah connect)    │
    │   }                                                                 │
    │                                                                     │
    └─────────────────────────────────────────────────────────────────────┘
```

---

## 🔗 STEP 2: Koneksi dengan License Key

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        FLOW KONEKSI & AUTENTIKASI                           │
└─────────────────────────────────────────────────────────────────────────────┘

     FLUTTER APP                    SDK                         TIMBANGAN
          │                          │                              │
          │  1️⃣ connectWithLicenseKey│                              │
          │     (deviceId, license)  │                              │
          │─────────────────────────▶│                              │
          │                          │                              │
          │                    ┌─────┴─────┐                        │
          │                    │  VERIFY   │                        │
          │                    │ OWNERSHIP │ ─────▶ API (optional)  │
          │                    └─────┬─────┘                        │
          │                          │                              │
          │      State: CONNECTING   │                              │
          │◀ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ │                              │
          │                          │                              │
          │                          │  2️⃣ BLE Connect              │
          │                          │─────────────────────────────▶│
          │                          │                              │
          │                          │         ✅ Connected          │
          │                          │◀─────────────────────────────│
          │                          │                              │
          │       State: CONNECTED   │                              │
          │◀ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ │                              │
          │                          │                              │
          │                          │  3️⃣ Discover Services        │
          │                          │─────────────────────────────▶│
          │                          │                              │
          │                          │    📦 Services & Chars       │
          │                          │◀─────────────────────────────│
          │                          │                              │
          │                          │  4️⃣ CONNECT:license_key      │
          │                          │─────────────────────────────▶│
          │                          │                              │
          │                          │                        ┌─────┴─────┐
          │                          │                        │ VALIDATE  │
          │                          │                        │  LICENSE  │
          │                          │                        └─────┬─────┘
          │                          │                              │
          │                          │    ✅ "CONNECTED"            │
          │                          │◀─────────────────────────────│
          │                          │                              │
          │   State: AUTHENTICATED   │         🔊 BUZZ!             │
          │◀ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ │─────────────────────────────▶│
          │                          │                              │
          │  5️⃣ ControlResponse      │                              │
          │     (success: true)      │                              │
          │◀─────────────────────────│                              │
          │                          │                              │
          ▼                          ▼                              ▼


    ┌─────────────────────────────────────────────────────────────────────┐
    │                      🔐 RESPONSE AUTENTIKASI                        │
    ├───────────────────┬─────────────────────────────────────────────────┤
    │ Response          │ Keterangan                                      │
    ├───────────────────┼─────────────────────────────────────────────────┤
    │ "CONNECTED"       │ ✅ License valid, koneksi berhasil              │
    │ "ALREADY_CONNECTED│ ✅ Sudah terkoneksi dengan license yang sama    │
    │ "INVALID_LICENSE" │ ❌ License key tidak valid                      │
    │ "LICENSE_IN_USE"  │ ❌ License sedang digunakan device lain         │
    └───────────────────┴─────────────────────────────────────────────────┘
```

---

## 📡 STEP 3: Streaming Data Berat

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        FLOW STREAMING DATA BERAT                            │
└─────────────────────────────────────────────────────────────────────────────┘

     FLUTTER APP                    SDK                         TIMBANGAN
          │                          │                              │
          │  1️⃣ weightStream.listen()│                              │
          │─────────────────────────▶│                              │
          │                          │                              │
          │                          │                        ┌─────┴─────┐
          │                          │                        │   READ    │
          │                          │                        │ LOAD CELL │
          │                          │                        └─────┬─────┘
          │                          │                              │
          │                          │       "1.234"                │
          │                          │◀ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─│
          │                          │                              │
          │  2️⃣ WeightData           │                              │
          │     (weight: 1.234)      │                              │
          │◀─────────────────────────│                              │
          │                          │                              │
     ┌────┴────┐                     │                        ┌─────┴─────┐
     │ UPDATE  │                     │                        │   READ    │
     │   UI    │                     │                        │ LOAD CELL │
     └────┬────┘                     │                        └─────┬─────┘
          │                          │                              │
          │                          │       "1.567"                │
          │                          │◀ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─│
          │                          │                              │
          │  WeightData              │                              │
          │  (weight: 1.567)         │                              │
          │◀─────────────────────────│                              │
          │                          │                              │
     ┌────┴────┐                     │                              │
     │ UPDATE  │        ...          │         ... @ 10Hz           │
     │   UI    │     (repeat)        │          (repeat)            │
     └─────────┘                     │                              │
          │                          │                              │
          ▼                          ▼                              ▼


    ┌─────────────────────────────────────────────────────────────────────┐
    │                        📊 WEIGHT DATA FORMAT                        │
    ├─────────────────────────────────────────────────────────────────────┤
    │                                                                     │
    │   WeightData {                                                      │
    │     weight: 1.234        ← Berat dalam kg (double)                  │
    │     timestamp: DateTime  ← Waktu pembacaan                          │
    │     isStable: true       ← Indikator kestabilan                     │
    │   }                                                                 │
    │                                                                     │
    │   📍 Update Rate: 10Hz (100ms interval)                             │
    │                                                                     │
    └─────────────────────────────────────────────────────────────────────┘
```

---

## 🔔 STEP 4: Kontrol Buzzer

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           FLOW KONTROL BUZZER                               │
└─────────────────────────────────────────────────────────────────────────────┘

     FLUTTER APP                    SDK                         TIMBANGAN
          │                          │                              │
          │  triggerBuzzer("BEEP")   │                              │
          │─────────────────────────▶│                              │
          │                          │                              │
          │                    ┌─────┴─────┐                        │
          │                    │   CHECK   │                        │
          │                    │   AUTH    │                        │
          │                    └─────┬─────┘                        │
          │                          │                              │
          │                          │        "BEEP"                │
          │                          │─────────────────────────────▶│
          │                          │                              │
          │                          │                         🔊 BEEP!
          │                          │                              │
          ▼                          ▼                              ▼


    ┌─────────────────────────────────────────────────────────────────────┐
    │                        🔊 BUZZER COMMANDS                           │
    ├─────────────┬───────────────────────────────────────────────────────┤
    │ Command     │ Deskripsi                                             │
    ├─────────────┼───────────────────────────────────────────────────────┤
    │ "BEEP"      │ 🔊      Bunyi pendek sekali                           │
    │ "BUZZ"      │ 🔊🔊    Bunyi pendek dua kali                         │
    │ "LONG"      │ 🔊───   Bunyi panjang                                 │
    │ "ON"        │ 🔊━━━   Buzzer menyala terus                          │
    │ "OFF"       │ 🔇      Matikan buzzer                                │
    └─────────────┴───────────────────────────────────────────────────────┘
```

---

## 🔌 STEP 5: Disconnect

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            FLOW DISCONNECT                                  │
└─────────────────────────────────────────────────────────────────────────────┘

     FLUTTER APP                    SDK                         TIMBANGAN
          │                          │                              │
          │                          │                              │
    ╔═════╧═════════════════════════╧══════════════════════════════╧═════╗
    ║                    OPSI 1: DISCONNECT DENGAN LICENSE               ║
    ╚═════╤═════════════════════════╤══════════════════════════════╤═════╝
          │                          │                              │
          │  disconnectWithLicenseKey│                              │
          │─────────────────────────▶│                              │
          │                          │                              │
          │                          │   "DISCONNECT:license"       │
          │                          │─────────────────────────────▶│
          │                          │                              │
          │                          │                        ┌─────┴─────┐
          │                          │                        │  RELEASE  │
          │                          │                        │  LICENSE  │
          │                          │                        └─────┬─────┘
          │                          │                              │
          │                          │     "DISCONNECTED"           │
          │                          │◀─────────────────────────────│
          │                          │                              │
          │                          │                              │
    ╔═════╧═════════════════════════╧══════════════════════════════╧═════╗
    ║                    OPSI 2: FORCE DISCONNECT                        ║
    ╚═════╤═════════════════════════╤══════════════════════════════╤═════╝
          │                          │                              │
          │  disconnect()            │                              │
          │─────────────────────────▶│                              │
          │                          │                              │
          │                          │      BLE Disconnect          │
          │                          │─────────────────────────────▶│
          │                          │                              │
          │                          │                              │
    ╔═════╧══════════════════════════╧══════════════════════════════╧════╗
    ║                           CLEANUP                                  ║
    ╚═════╤══════════════════════════╤══════════════════════════════╤════╝
          │                          │                              │
          │                    ┌─────┴─────┐                        │
          │                    │  CLEAR    │                        │
          │                    │  STATE    │                        │
          │                    └─────┬─────┘                        │
          │                          │                              │
          │  State: DISCONNECTED     │                              │
          │◀ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ │                              │
          │                          │                              │
          ▼                          ▼                              ▼
```

---

## 📋 State Machine

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           STATE MACHINE DIAGRAM                             │
└─────────────────────────────────────────────────────────────────────────────┘


                              ┌───────────────┐
                              │               │
                    ┌────────▶│  DISCONNECTED │◀────────┐
                    │         │               │         │
                    │         └───────┬───────┘         │
                    │                 │                 │
              timeout/stop    scanForDevices()    disconnect()
              Permission ❌           │           License ❌
                    │                 ▼                 │
                    │         ┌───────────────┐         │
                    │         │               │         │
                    └─────────│   SCANNING    │         │
                              │               │         │
                              └───────┬───────┘         │
                                      │                 │
                          connectWithLicenseKey()       │
                                      │                 │
                                      ▼                 │
                              ┌───────────────┐         │
                              │               │         │
                         ┌────│  CONNECTING   │────┐    │
                         │    │               │    │    │
                         │    └───────┬───────┘    │    │
                         │            │            │    │
                      Error ❌   BLE Connected   Cancel  │
                         │            │            │    │
                         ▼            ▼            │    │
                  ┌───────────┐ ┌───────────────┐  │    │
                  │           │ │               │  │    │
                  │   ERROR   │ │   CONNECTED   │──┼────┘
                  │           │ │               │  │
                  └─────┬─────┘ └───────┬───────┘  │
                        │               │          │
                      Reset       License Valid ✅  │
                        │               │          │
                        │               ▼          │
                        │       ┌───────────────┐  │
                        │       │               │  │
                        └──────▶│ AUTHENTICATED │──┘
                                │               │
                                │   ✅ READY!   │
                                └───────────────┘
                                        │
                                        │
                              ┌─────────┴─────────┐
                              │                   │
                              ▼                   ▼
                        ┌──────────┐        ┌──────────┐
                        │  Weight  │        │  Buzzer  │
                        │ Streaming│        │ Control  │
                        └──────────┘        └──────────┘
```

---

## 📊 Tabel State

| State | Icon | Deskripsi |
|-------|------|-----------|
| `disconnected` | ⚪ | Tidak terhubung ke device apapun |
| `scanning` | 🔍 | Sedang mencari perangkat KGiTON |
| `connecting` | 🔄 | Sedang mencoba terhubung ke device |
| `connected` | 🔵 | Terhubung via BLE, belum terautentikasi |
| `authenticated` | 🟢 | Terautentikasi, siap streaming data |
| `error` | 🔴 | Terjadi error |

---

## ⏱️ Timing & Timeout

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           TIMING CONFIGURATION                              │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────┬────────────────┬─────────────────────────────────┐
│ Operation               │ Timeout        │ Notes                           │
├─────────────────────────┼────────────────┼─────────────────────────────────┤
│ 🔍 Scan                 │ 10 detik       │ Configurable via parameter      │
│ 🔗 BLE Connection       │ 5 detik        │ Auto retry 1x                   │
│ 📦 Service Discovery    │ 5 detik        │ -                               │
│ 🔐 Control Command      │ 800ms          │ Auto retry 2x                   │
│ ⚡ Debounce Processing  │ 300ms          │ Untuk stabilkan hasil scan       │
│ 📡 Weight Update        │ 100ms          │ 10Hz refresh rate               │
└─────────────────────────┴────────────────┴─────────────────────────────────┘
```

---

## 🔑 BLE Characteristics

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          BLE SERVICE & CHARACTERISTICS                      │
└─────────────────────────────────────────────────────────────────────────────┘

                    ┌─────────────────────────────────────┐
                    │         KGiTON BLE SERVICE          │
                    │   UUID: 6e400001-b5a3-f393-...      │
                    └──────────────────┬──────────────────┘
                                       │
           ┌───────────────────────────┼───────────────────────────┐
           │                           │                           │
           ▼                           ▼                           ▼
┌─────────────────────┐  ┌──────────────────────┐  ┌──────────────────────┐
│   TX Characteristic │  │Control Characteristic│  │ Buzzer Characteristic│
│   (Weight Data)     │  │  (Commands)          │  │  (Sound)             │
├─────────────────────┤  ├──────────────────────┤  ├──────────────────────┤
│ UUID: 6e400002-...  │  │ UUID: 6e400003-...   │  │ UUID: 6e400004-...   │
│ Type: NOTIFY        │  │ Type: WRITE/NOTIFY   │  │ Type: WRITE          │
│ Data: Weight (kg)   │  │ Data: Commands       │  │ Data: Buzzer cmd     │
└─────────────────────┘  └──────────────────────┘  └──────────────────────┘
         │                         │                         │
         ▼                         ▼                         ▼
    ┌─────────┐              ┌──────────┐              ┌─────────┐
    │ "1.234" │              │CONNECT:  │              │  BEEP   │
    │ "1.567" │              │ license  │              │  BUZZ   │
    │  ...    │              │DISCONNECT│              │  LONG   │
    └─────────┘              └──────────┘              └─────────┘
```

---

## 📝 Catatan Penting

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            📝 CATATAN PENTING                               │
└─────────────────────────────────────────────────────────────────────────────┘

  ✅ BEST PRACTICES
  ─────────────────────────────────────────────────────────────────────────────
  
  1️⃣  Permission Check
      └── Selalu cek permission Bluetooth & Location sebelum scan
  
  2️⃣  License Verification  
      └── Jika API service tersedia, ownership diverifikasi sebelum koneksi
  
  3️⃣  State Management
      └── Gunakan connectionStateStream untuk monitor state changes
  
  4️⃣  Error Handling
      └── Semua error di-wrap dalam custom exceptions:
          • BLEConnectionException
          • DeviceNotFoundException
          • LicenseKeyException
  
  5️⃣  Auto-Disconnect
      └── Jika license invalid, SDK otomatis disconnect dari device


  ⚠️  PERHATIAN
  ─────────────────────────────────────────────────────────────────────────────
  
  • Pastikan Bluetooth & Location aktif sebelum scan
  • Satu license key hanya bisa digunakan satu device dalam satu waktu
  • Jangan lupa disconnect saat selesai menggunakan timbangan
  • Handle reconnection saat koneksi terputus secara tiba-tiba
```
