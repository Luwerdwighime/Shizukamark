import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LanguageItem {
  final String flag;
  final String name;
  final Locale locale;

  const LanguageItem({
    required this.flag,
    required this.name,
    required this.locale,
  });
}

const List<LanguageItem> supportedLanguages = [
  LanguageItem(flag: '🇬🇧', name: 'English', locale: Locale('en')),
  LanguageItem(flag: '🇫🇷', name: 'Français', locale: Locale('fr')),
  LanguageItem(flag: '🇩🇪', name: 'Deutsch', locale: Locale('de')),
  LanguageItem(flag: '🇯🇵', name: '日本語', locale: Locale('ja')),
  LanguageItem(flag: '🇷🇺', name: 'Русский', locale: Locale('ru')),
  LanguageItem(flag: '🇺🇦', name: 'Українська', locale: Locale('uk')),
];

class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(null);

  void setLocale(Locale locale) {
    state = locale;
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier();
});
