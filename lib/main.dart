import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'services/notification_service.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'providers/settings_provider.dart';
import 'package:intl/date_symbol_data_local.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class _CombinedTextScaler extends TextScaler {
  const _CombinedTextScaler(this.platformScaler, this.appScaleFactor);

  final TextScaler platformScaler;
  final double appScaleFactor;

  @override
  double scale(double fontSize) {
    return platformScaler.scale(fontSize * appScaleFactor);
  }

  @override
  double get textScaleFactor => platformScaler.scale(1) * appScaleFactor;

  @override
  bool operator ==(Object other) {
    return other is _CombinedTextScaler &&
        other.platformScaler == platformScaler &&
        other.appScaleFactor == appScaleFactor;
  }

  @override
  int get hashCode => Object.hash(platformScaler, appScaleFactor);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await Firebase.initializeApp(); // Descomenta esto después de configurar Firebase
  // await NotificationService().init();

  await initializeDateFormatting('es_ES', null);

  runApp(const ProviderScope(child: MedicalApp()));
}

class MedicalApp extends ConsumerWidget {
  const MedicalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Citas Médicas',
      navigatorKey: navigatorKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      home: const SplashScreen(),
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);

        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: _CombinedTextScaler(
              mediaQuery.textScaler,
              settings.textSize.scaleFactor,
            ),
          ),
          child: child!,
        );
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
