import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'features/notifications/local_notification_service.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/locale_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/widget/widget_bridge.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize local notifications for FCM fallback display.
  await LocalNotificationService.initialize();

  // Pre-load SharedPreferences so theme is available synchronously
  final prefs = await SharedPreferences.getInstance();
  final widgetBridge = WidgetBridge();
  await widgetBridge.initialize();
  await widgetBridge.syncLocale(
    Locale(prefs.getString('app_locale') == 'fil' ? 'fil' : 'en'),
  );
  await widgetBridge.syncAuthenticated(false);

  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
        widgetBridgeProvider.overrideWithValue(widgetBridge),
      ],
      child: const MyApp(),
    ),
  );
}

/// Handle background messages. This must be a top-level or static function.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await LocalNotificationService.showFromRemoteMessage(message);
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(appLocaleProvider);
    ref.listen(appLocaleProvider, (_, next) {
      unawaited(ref.read(widgetBridgeProvider).syncLocale(next));
    });
    return MaterialApp(
      title: 'BayanTrack',
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: appSupportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const SplashScreen(),
    );
  }
}

// Navigator and messenger keys used for push navigation and snackbars
final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
