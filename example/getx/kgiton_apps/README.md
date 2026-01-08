# KGiTON Example App - GetX

Contoh aplikasi menggunakan KGiTON SDK dengan **GetX** state management.

## 📁 Struktur Folder

```
lib/
├── main.dart                    # Entry point dengan GetMaterialApp
└── src/
    ├── bindings/                # Dependency bindings
    │   ├── initial_binding.dart # App initialization
    │   ├── auth_binding.dart    # Auth page binding
    │   ├── home_binding.dart    # Home page binding
    │   └── device_binding.dart  # Device page binding
    │
    ├── config/                  # Configuration
    │   ├── routes.dart          # Named routes
    │   └── theme.dart           # KGiTON theme
    │
    ├── controllers/             # GetX Controllers
    │   ├── auth_controller.dart
    │   ├── home_controller.dart
    │   └── scale_controller.dart
    │
    └── views/                   # UI Views
        ├── splash_view.dart
        ├── auth/
        ├── home/
        ├── device/
        └── qr_scanner/
```

## 🎯 GetX Features

### 1. State Management

```dart
// Controller dengan reactive state
class AuthController extends GetxController {
  // Reactive variable dengan .obs
  final isLoading = false.obs;
  final isLoggedIn = false.obs;
  final Rx<User?> user = Rx<User?>(null);
  
  // Methods untuk update state
  Future<void> login(...) async {
    isLoading.value = true;  // Update value
    // ... do login
    isLoggedIn.value = true;
    isLoading.value = false;
  }
}

// Di View, gunakan Obx untuk reactive rebuild
Obx(() => Text('Loading: ${controller.isLoading.value}'))

// Atau GetBuilder untuk non-reactive
GetBuilder<AuthController>(
  builder: (controller) => Text('User: ${controller.user.value?.name}'),
)
```

### 2. Route Management

```dart
// Define routes
abstract class AppRoutes {
  static const home = '/home';
  static const auth = '/auth';
  
  static final routes = [
    GetPage(
      name: home,
      page: () => const HomeView(),
      binding: HomeBinding(),  // Lazy binding
    ),
  ];
}

// Navigation tanpa context
Get.toNamed(AppRoutes.home);
Get.offAllNamed(AppRoutes.auth);  // Replace semua
Get.back();  // Pop

// Dengan arguments
Get.toNamed(
  AppRoutes.device,
  arguments: {'licenseKey': 'xxx'},
);

// Akses arguments
final key = Get.arguments['licenseKey'];
```

### 3. Dependency Injection

```dart
// Register dependency
Get.put(AuthController());           // Langsung instantiate
Get.lazyPut(() => HomeController()); // Lazy instantiate

// Get dependency
final controller = Get.find<AuthController>();

// Dengan Binding
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
  }
}
```

### 4. Dialogs & Snackbars

```dart
// Snackbar
Get.snackbar(
  'Title',
  'Message',
  snackPosition: SnackPosition.BOTTOM,
  backgroundColor: Colors.green,
);

// Dialog
Get.dialog(
  AlertDialog(
    title: Text('Title'),
    actions: [
      TextButton(
        onPressed: () => Get.back(),
        child: Text('OK'),
      ),
    ],
  ),
);

// Bottom Sheet
Get.bottomSheet(
  Container(
    child: Text('Content'),
  ),
);
```

## 📦 Dependency Flow

```
                    ┌─────────────────┐
                    │  GetMaterialApp │
                    └────────┬────────┘
                             │
              ┌──────────────┴──────────────┐
              │       InitialBinding        │
              │  (Register global services) │
              └──────────────┬──────────────┘
                             │
    ┌────────────────────────┼────────────────────────┐
    │                        │                        │
┌───┴───┐              ┌─────┴─────┐            ┌─────┴─────┐
│ Auth  │              │   Home    │            │  Device   │
│ View  │              │   View    │            │   View    │
└───┬───┘              └─────┬─────┘            └─────┬─────┘
    │                        │                        │
┌───┴───────┐          ┌─────┴───────┐          ┌─────┴───────┐
│ AuthBinding│          │ HomeBinding │          │DeviceBinding│
└───┬───────┘          └─────┬───────┘          └─────┬───────┘
    │                        │                        │
┌───┴───────────┐      ┌─────┴───────────┐      ┌─────┴───────────┐
│AuthController │      │ HomeController  │      │ ScaleController │
│  (permanent)  │      │    (lazy)       │      │     (lazy)      │
└───────────────┘      └─────────────────┘      └─────────────────┘
```

## 🔥 Reactive Types

| Type | Description | Usage |
|------|-------------|-------|
| `.obs` | Make any type reactive | `final count = 0.obs;` |
| `Rx<T>` | Reactive wrapper | `final user = Rx<User?>(null);` |
| `RxList<T>` | Reactive list | `final items = <Item>[].obs;` |
| `RxMap<K,V>` | Reactive map | `final data = <String, int>{}.obs;` |

```dart
// Access value
print(count.value);

// Update value
count.value = 10;
count++;  // increment

// List operations
items.add(newItem);
items.assignAll([...]);
items.refresh();  // Force rebuild
```

## 🚀 Menjalankan Aplikasi

```bash
# Install dependencies
flutter pub get

# Run app
flutter run
```

## 📱 Fitur Aplikasi

1. **Authentication**
   - Login dengan email/password
   - Register akun baru
   - Logout

2. **License Management**
   - View assigned licenses
   - Scan QR code untuk license

3. **Device Connection**
   - Scan BLE devices
   - Connect dengan license key
   - Monitor weight realtime

## 🆚 Perbandingan dengan Patterns Lain

| Feature | GetX | Provider | BLoC |
|---------|------|----------|------|
| Boilerplate | Minimal | Medium | High |
| Navigation | Built-in | Need Navigator | Need Navigator |
| DI | Built-in | Perlu provider | Perlu package |
| Learning Curve | Easy | Easy | Medium |
| Testing | Easy | Easy | Easy |

## 📚 Referensi

- [GetX Documentation](https://github.com/jonataslaw/getx)
- [GetX Tutorial](https://chornthorn.github.io/getx-docs/)
- [GetStorage](https://pub.dev/packages/get_storage)

## 📄 License

MIT License - lihat LICENSE untuk detail.
