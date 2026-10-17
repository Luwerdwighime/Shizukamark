import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('ru'),
    Locale('en')
  ];

  String get appTitle;
  String get homeApplyMark;
  String get homeReadMark;
  String get homeKeys;
  String get homeImport;
  String get homeExport;

  String get applyMarkTitle;
  String get applyMarkSecretHint;
  String get applyMarkFileHint;
  String get applyMarkKeyHint;
  String get applyMarkOr;
  String get applyMarkCreateKey;
  String get applyMarkExportFolder;
  String get applyMarkUseMediaStore;
  String get applyMarkUseCustomSave;
  String applyMarkCustomFolder(String path);
  String get applyMarkButton;
  String get applyMarkErrorNoMessage;
  String get applyMarkErrorNoFile;
  String get applyMarkErrorNoKey;
  String applyMarkSuccessSaved(String path);

  String get readMarkTitle;
  String get readMarkFileHint;
  String get readMarkImportHint;
  String get readMarkOutputHint;
  String get readMarkPatientCheckbox;
  String get readMarkPatientSubtitle;
  String get readMarkButton;
  String get readMarkErrorNoFile;
  String get readMarkSuccess;
  String get readMarkCopyButton;
  String get readMarkCopied;

  String get keysTitle;
  String get keysEmpty;
  String keysUnnamed(String fileName);
  String get keysCreateButton;
  String keysDeleteConfirm(String keyName);
  String get keysDeleteTitle;
  String get keysDeleted;

  String get createKeyTitle;
  String get createKeyHint;
  String get createKeyErrorEmpty;
  String get createKeyErrorMaxLength;
  String get createKeyErrorInvalidChars;
  String get createKeyErrorGeneral;

  String get selectKeyTitle;

  String get codecDialogTitle;
  String get codecLossyHeader;
  String get codecLosslessHeader;
  String get codecSelectButton;

  String get progressDecoding;
  String get progressApplyingWatermark;
  String get progressEncoding;
  String get progressReadingWatermark;
  String get progressPreparing;
  String get progressDone;
  String progressRunning(String operation);

  String get cancelButton;
  String get okButton;

  String get importSuccess;
  String get importErrorBadZip;
  String importErrorGeneral(String error);

  String get exportSuccess;
  String exportErrorGeneral(String error);
  String get exportDialogTitle;

  String get errorDecoding;
  String get errorApplyingWatermark;
  String get errorEncoding;
  String get errorSaving;
  String get errorStegoExtraction;
  String get errorWatermarkNotFound;
  String get errorDeleteKey;
  String get errorCreateKey;
  String get errorExportData;
  String get errorOperationCancelled;

  String get errorAudioTooShort;
  String get errorStereoOnly;
  String errorAudioNotFound(String path);

  String get permissionRequired;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  return AppLocalizationsRu();
}
