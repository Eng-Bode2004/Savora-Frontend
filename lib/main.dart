import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/localization/app_localizations.dart';
import 'features/customer/auth/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.espresso,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const SavoraApp());
}

class SavoraApp extends StatefulWidget {
  const SavoraApp({super.key});

  @override
  State<SavoraApp> createState() => _SavoraAppState();
}

class _SavoraAppState extends State<SavoraApp> {
  @override
  void initState() {
    super.initState();
    localeProvider.addListener(_onLocaleChange);
  }

  @override
  void dispose() {
    localeProvider.removeListener(_onLocaleChange);
    super.dispose();
  }

  void _onLocaleChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Savora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      locale: localeProvider.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}
