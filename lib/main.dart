import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:mastercs_mobile/firebase_options.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:mastercs_mobile/my_app.dart';
import 'package:mastercs_mobile/background_service/components/background_service_runtime.dart';
import 'package:mastercs_mobile/repositories/location_repository.dart';
import 'package:mastercs_mobile/providers/socket/socket_manager.dart';
import 'package:mastercs_mobile/providers/sync/sync_coordinator.dart';
import 'package:mastercs_mobile/providers/shared_preferences_provider.dart';
import 'package:mastercs_mobile/providers/auth/auth_provider.dart';
import 'package:mastercs_mobile/providers/notifications/firebase_notification_provider.dart';
import 'package:mastercs_mobile/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // If the background runtime fails to initialize, we log the error and continue.
    // The app can still function without background capabilities, albeit with limited features.
    debugPrint('Error initializing Firebase: $e');
  }

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    await dotenv.load(fileName: ".env.example");
  }

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top],
  );

  final prefs = await SharedPreferences.getInstance();

  // Create the notification channel before binding the background service
  // so Android can always post the foreground notification on restart.
  await initializeNotificationChannels();

  // Initialize background location service before running the app
  await initializeBackgroundLocationService();

  // Load saved theme mode
  final savedMode =
      ThemeMode.values[prefs.getInt("theme_key") ?? ThemeMode.system.index];

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        initialThemeModeProvider.overrideWithValue(savedMode),
        // authApiProvider.overrideWith((ref) => AuthMockApi()),
        // campApiProvider.overrideWith((ref) => CampMockApi()),
        // userApiProvider.overrideWith((ref) => UserMockApi()),
        // paymentApiProvider.overrideWith((ref) => PaymentMockApi()),
      ],
      child: const AppBootstrapper(),
    ),
  );
}

class AppBootstrapper extends ConsumerWidget {
  const AppBootstrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<bool>>(authProvider, (previous, next) {
      final wasLoggedIn = previous?.value ?? false;
      final isLoggedIn = next.value ?? false;

      if (!wasLoggedIn && isLoggedIn) {
        unawaited(ref.read(firebaseNotificationProvider.notifier).setToken());
      }

      if (wasLoggedIn && !isLoggedIn) {
        unawaited(
          ref
              .read(firebaseNotificationProvider.notifier)
              .stopTokenRefreshListener(),
        );
      }
    });

    ref.watch(syncCoordinatorProvider);
    // Initialize socket manager to handle connection lifecycle
    ref.watch(socketManagerProvider);
    // Eagerly initialize location repository so it can subscribe to
    // authenticated/location socket streams before early events are emitted.
    ref.watch(locationRepositoryProvider);

    return const MyApp();
  }
}
