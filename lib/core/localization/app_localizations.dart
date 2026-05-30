import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final LocaleProvider localeProvider = LocaleProvider();

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('ar');
  Locale get locale => _locale;

  void setLocale(Locale l) {
    _locale = l;
    notifyListeners();
  }
}

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  late Map<String, dynamic> _strings;

  Future<void> load() async {
    final code = locale.languageCode;
    final json = await rootBundle.loadString('lib/core/localization/$code.json');
    _strings = jsonDecode(json) as Map<String, dynamic>;
  }

  String t(String key) => _strings[key] as String? ?? key;

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ar'),
    Locale('es'),
    Locale('fr'),
    Locale('zh'),
  ];
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'ar', 'es', 'fr', 'zh'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
