import 'dart:async';
import 'package:confidants/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'frontend/theme/app_theme.dart';
import 'frontend/util/auth_guard_screen.dart';
import 'services/export_service.dart';
import 'services/preferences_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferencesService.instance.init();
  // Reconcile exported AI context chunks with the database in the background.
  unawaited(ExportService.instance.syncAll());
  runApp(const ConfidantsApp());
}

class ConfidantsApp extends StatelessWidget {
  const ConfidantsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: PreferencesService.instance.isDarkModeNotifier,
      builder: (context, isDarkMode, _) {
        return MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const AuthGuardScreen(),
        );
      },
    );
  }
}
