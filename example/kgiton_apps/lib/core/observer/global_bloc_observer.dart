import 'package:flutter_bloc/flutter_bloc.dart';
import '../error/failures.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

/// Global BLoC observer for handling errors across all BLoCs
class GlobalBlocObserver extends BlocObserver {
  final AuthBloc authBloc;
  bool _hasLoggedOut = false; // Prevent multiple logout triggers

  GlobalBlocObserver({required this.authBloc});

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);

    // Check if error is session expired
    if (_isSessionExpiredError(error)) {
      _handleSessionExpired();
    }
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);

    // Check state changes for session expired failures
    if (change.nextState != null && _containsSessionExpiredFailure(change.nextState)) {
      _handleSessionExpired();
    }
  }

  bool _isSessionExpiredError(Object error) {
    if (error is ServerFailure) {
      return error.isSessionExpired;
    }
    if (error is SessionExpiredFailure) {
      return true;
    }
    if (error is String) {
      final lowerError = error.toLowerCase();
      return lowerError.contains('no token provided') ||
          lowerError.contains('token expired') ||
          lowerError.contains('invalid token') ||
          lowerError.contains('unauthorized');
    }
    return false;
  }

  bool _containsSessionExpiredFailure(dynamic state) {
    // Check if state has a message property that indicates session expiry
    try {
      final stateString = state.toString().toLowerCase();
      return stateString.contains('no token provided') ||
          stateString.contains('token expired') ||
          stateString.contains('invalid token') ||
          stateString.contains('unauthorized');
    } catch (_) {
      return false;
    }
  }

  void _handleSessionExpired() {
    if (_hasLoggedOut) return; // Prevent multiple logout calls

    _hasLoggedOut = true;

    // Trigger logout using the correct event name
    authBloc.add(const LogoutRequested());

    // Reset flag after a delay to allow future logout if needed
    Future.delayed(const Duration(seconds: 2), () {
      _hasLoggedOut = false;
    });
  }
}
