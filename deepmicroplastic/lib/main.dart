import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'screens/login_screen.dart';
import 'services/locale_service.dart';

final localeService = LocaleService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await localeService.load();
  runApp(const RaviApp());
}

class RaviApp extends StatelessWidget {
  const RaviApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: localeService,
      builder: (context, _) => MaterialApp(
        title: 'RAVI System',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF0A0E21),
          primaryColor: Colors.cyanAccent,
          colorScheme: const ColorScheme.dark(
            primary: Colors.cyanAccent,
            secondary: Colors.blueAccent,
          ),
        ),
        locale: localeService.locale,
        supportedLocales: LocaleService.supported,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const LoginScreen(),
      ),
    );
  }
}
