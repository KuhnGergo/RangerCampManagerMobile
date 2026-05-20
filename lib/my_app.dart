import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mastercs_mobile/l10n/app_localizations.dart';

import 'package:mastercs_mobile/presentation/navigation/app.dart';
import 'package:mastercs_mobile/presentation/camp_selection/screens/add_camp_screen.dart';
import 'package:mastercs_mobile/presentation/camp_selection/screens/choose_camp_screen.dart';
import 'package:mastercs_mobile/presentation/camp_selection/screens/create_camp_screen.dart';
import 'package:mastercs_mobile/presentation/camp_selection/screens/join_camp_qr_screen.dart';
import 'package:mastercs_mobile/presentation/camp_selection/screens/join_camp_screen.dart';

import 'package:mastercs_mobile/presentation/auth/screens/auth_screen.dart';
import 'package:mastercs_mobile/presentation/auth/screens/login_screen.dart';
import 'package:mastercs_mobile/presentation/auth/screens/signup_screen.dart';
import 'package:mastercs_mobile/presentation/settings/settings_screen.dart';

import 'package:mastercs_mobile/providers/data/camp_provider.dart';
import 'package:mastercs_mobile/providers/data/camps_list_provider.dart';
import 'package:mastercs_mobile/providers/auth/auth_provider.dart';
import 'package:mastercs_mobile/presentation/components/widgets/loading_screen.dart';
import 'package:mastercs_mobile/providers/localization_provider.dart';
import 'package:mastercs_mobile/providers/theme_provider.dart';
import 'package:mastercs_mobile/providers/actions/camp_actions_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final auth = ref.watch(authProvider);
    final selectedCamp = ref.watch(campProvider);
    final campsList = ref.watch(campsListProvider);
    final themeMode = ref.watch(themeProvider);

    Future<void> selectCamp(String campId) async {
      await ref.read(campActionsProvider.notifier).selectCamp(campId);
    }

    Future<void> deselectCamp() async {
      await ref.read(campActionsProvider.notifier).deselectCamp();
    }

    /// Authenticated user has any camps or not
    Widget decideCamp() {
      switch (campsList) {
        case AsyncLoading():
          return const LoadingScreen();
        // ignore: unused_local_variable
        case AsyncError(:final error, :final stackTrace):
          return const AddCampScreen();
        case AsyncData(:final value):
          if (value.isEmpty) {
            return const AddCampScreen();
          } else {
            return ChooseCampScreen(onSelectCamp: selectCamp);
          }
      }
    }

    // Note: the "camp selected?" decision is handled inline in `home`
    // so the callbacks remain owned by MyApp.

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: themeMode == ThemeMode.dark
            ? Brightness.dark
            : Brightness.light,
        statusBarIconBrightness: themeMode == ThemeMode.dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),

      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        // * lokalizációk *
        locale: locale,
        supportedLocales: const [Locale('en'), Locale('hu', 'HU')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // * téma *
        themeMode: themeMode,
        theme: ThemeData(
          colorScheme:
              ColorScheme.fromSeed(
                seedColor: const Color.fromARGB(255, 255, 200, 0),
                brightness: Brightness.light,
              ).copyWith(
                primary: const Color.fromARGB(255, 192, 150, 0),
                primaryContainer: const Color.fromARGB(255, 255, 216, 77),
                errorContainer: const Color.fromARGB(255, 191, 28, 28),
                onErrorContainer: const Color.fromARGB(255, 255, 213, 213),
              ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme:
              ColorScheme.fromSeed(
                seedColor: const Color.fromARGB(255, 255, 200, 0),
                dynamicSchemeVariant: DynamicSchemeVariant.rainbow,
                brightness: Brightness.dark,
              ).copyWith(
                primary: const Color.fromARGB(255, 190, 151, 10),
                error: const Color.fromARGB(255, 254, 46, 46),
                onError: const Color.fromARGB(255, 255, 255, 255),
                errorContainer: const Color.fromARGB(255, 163, 31, 31),
                onErrorContainer: const Color.fromARGB(255, 255, 255, 255),
              ),
          useMaterial3: true,
        ),
        // * kezdőképernyő *
        home: switch (auth) {
          AsyncData(:final value) =>
            value
                ? switch (selectedCamp) {
                    AsyncLoading() => const LoadingScreen(),
                    AsyncError() => decideCamp(),
                    AsyncData(:final value) =>
                      value != null
                          ? AppScreen(
                              onDeselectCamp: () {
                                deselectCamp();
                              },
                            )
                          : decideCamp(),
                  }
                : const AuthScreen(),
          AsyncLoading() => const LoadingScreen(),
          // ignore: unused_local_variable
          AsyncError(:final error, :final stackTrace) => AuthScreen(
            error: error,
          ),
        },
        // * útvonalak *
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/create-camp': (context) => const CreateCampScreen(),
          '/join-camp': (context) => const JoinCampScreen(),
          '/join-camp-qr': (context) => const JoinCampQrScreen(),
        },
      ),
    );
  }
}
