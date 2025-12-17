import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import '../routes/app_router.dart';

/// Service untuk menangani deep linking dari email reset password
class DeepLinkService {
  late AppLinks _appLinks;
  StreamSubscription? _sub;

  /// Initialize deep link listener
  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();

    // Handle deep link ketika app dalam keadaan terminated (app tidak berjalan)
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        debugPrint('=== DEEP LINK: Initial link detected: $initialLink ===');
        // Delay untuk memastikan router sudah siap
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleDeepLink(initialLink);
        });
      }
    } catch (e) {
      debugPrint('=== DEEP LINK ERROR: Failed to get initial link: $e ===');
    }

    // Handle deep link ketika app dalam keadaan background atau running
    _sub = _appLinks.uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          debugPrint('=== DEEP LINK: New link detected: $uri ===');
          _handleDeepLink(uri);
        }
      },
      onError: (err) {
        debugPrint('=== DEEP LINK ERROR: Stream error: $err ===');
      },
    );
  }

  /// Handle deep link berdasarkan URI
  void _handleDeepLink(Uri uri) {
    debugPrint('=== DEEP LINK: Handling URI - Scheme: ${uri.scheme}, Host: ${uri.host}, Path: ${uri.path}, Query: ${uri.queryParameters} ===');

    // Handle reset password deep link
    // Expected format: io.supabase.kgitonapp://reset-password?token=<TOKEN>
    if (uri.host == 'reset-password' || uri.path.contains('reset-password')) {
      final token = uri.queryParameters['token'];
      debugPrint('=== DEEP LINK: Reset password token: $token ===');

      if (token != null && token.isNotEmpty) {
        // Navigate to reset password page with token
        debugPrint('=== DEEP LINK: Navigating to /reset-password with token ===');
        AppRouter.router.go('/reset-password?token=$token');
      } else {
        debugPrint('=== DEEP LINK ERROR: Token is null or empty ===');
      }
    } else {
      debugPrint('=== DEEP LINK: Unhandled URI host: ${uri.host} ===');
    }

    // Tambahkan handler untuk deep link lainnya di sini jika diperlukan
  }

  /// Dispose deep link listener
  void dispose() {
    _sub?.cancel();
  }
}
