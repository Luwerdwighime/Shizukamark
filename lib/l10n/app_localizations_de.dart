import 'app_localizations.dart';

// ignore_for_file: type=lint

class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Shizukamark (しずかマーク)';

  @override
  String get homeApplyMark => 'Wasserzeichen anbringen';

  @override
  String get homeReadMark => 'Wasserzeichen lesen';

  @override
  String get homeKeys => 'Bekannte Schlüssel';

  @override
  String get homeImport => 'Daten importieren';

  @override
  String get homeExport => 'Daten exportieren';

  @override
  String get applyMarkTitle => 'Wasserzeichen anbringen';

  @override
  String get applyMarkSecretHint => 'Geheime Nachricht eingeben';

  @override
  String applyMarkCharCount(int count) {
    return 'Zeichen: $count';
  }

  @override
  String get applyMarkFileHint => 'Audiodatei auswählen';

  @override
  String get applyMarkKeyHint => 'Schlüssel auswählen';

  @override
  String get applyMarkOr => 'oder';

  @override
  String get applyMarkCreateKey => 'Neuen Schlüssel erstellen';

  @override
  String get applyMarkExportFolder =>
      'Exportordner: Music/Shizukamark (MediaStore)';

  @override
  String get applyMarkUseMediaStore =>
      'Systemordner Music/Shizukamark (MediaStore)';

  @override
  String get applyMarkUseCustomSave =>
      'Benutzerdefiniertes Speichern (Speicherdialog)';

  @override
  String applyMarkCustomFolder(String path) {
    return 'Speichern unter: $path';
  }

  @override
  String get applyMarkButton => 'Wasserzeichen anwenden';

  @override
  String get applyMarkErrorNoMessage => 'Geben Sie eine geheime Nachricht ein';

  @override
  String get applyMarkErrorNoFile => 'Wählen Sie eine Audiodatei aus';

  @override
  String get applyMarkErrorNoKey => 'Erstellen oder wählen Sie einen Schlüssel';

  @override
  String applyMarkSuccessSaved(String path) {
    return 'Datei erfolgreich gespeichert: $path';
  }

  @override
  String get readMarkTitle => 'Wasserzeichen lesen';

  @override
  String get readMarkFileHint => 'Audiodatei mit Wasserzeichen auswählen';

  @override
  String get readMarkImportHint =>
      'Vergessen Sie nicht, zuvor Daten des Wasserzeichen-Erstellers zu importieren, um es lesen zu können.';

  @override
  String get readMarkOutputHint => 'Hier erscheint die geheime Nachricht';

  @override
  String get readMarkPatientCheckbox => 'Geduldiges Lesen verwenden';

  @override
  String get readMarkPatientSubtitle =>
      'Erkennt geringfügige Geschwindigkeitsänderungen, dauert jedoch länger.';

  @override
  String get readMarkButton => 'Wasserzeichen lesen';

  @override
  String get readMarkErrorNoFile =>
      'Wählen Sie eine Audiodatei mit Wasserzeichen aus';

  @override
  String get readMarkSuccess => 'Wasserzeichen erfolgreich gelesen!';

  @override
  String get readMarkCopyButton => 'In Zwischenablage kopieren';

  @override
  String get readMarkCopied => 'Nachricht in die Zwischenablage kopiert';

  @override
  String get keysTitle => 'Schlüssel';

  @override
  String get keysEmpty => 'Noch keine Schlüssel vorhanden.';

  @override
  String keysUnnamed(String fileName) {
    return '(Unbenannt) · $fileName';
  }

  @override
  String get keysCreateButton => 'Neuen Schlüssel erstellen';

  @override
  String keysDeleteConfirm(String keyName) {
    return 'Möchten Sie den gespeicherten Schlüssel "$keyName" wirklich löschen?';
  }

  @override
  String get keysDeleteTitle => 'Schlüssel löschen';

  @override
  String get keysDeleted => 'Schlüssel gelöscht';

  @override
  String get createKeyTitle => 'Neuen Schlüssel erstellen';

  @override
  String get createKeyHint => 'Schlüsselname eingeben';

  @override
  String get createKeyErrorEmpty => 'Schlüsselname darf nicht leer sein';

  @override
  String get createKeyErrorMaxLength => 'Maximal 128 Zeichen';

  @override
  String get createKeyErrorInvalidChars =>
      'Ungültige Zeichen im Schlüsselnamen';

  @override
  String get createKeyErrorGeneral =>
      'Geben Sie einen gültigen Schlüsselnamen ein (1–128 Zeichen)';

  @override
  String get selectKeyTitle => 'Schlüssel auswählen';

  @override
  String get codecDialogTitle => 'Ausgabe-Audioformat';

  @override
  String get codecLossyHeader => 'Verlustbehaftete Kompression (Lossy):';

  @override
  String get codecLosslessHeader => 'Verlustfrei (Lossless):';

  @override
  String get codecSelectButton => 'Auswählen';

  @override
  String get codecAacRecommended => 'AAC (empfohlen)';

  @override
  String get progressDecoding => 'Audio wird dekodiert';

  @override
  String get progressApplyingWatermark => 'Wasserzeichen wird angewendet';

  @override
  String get progressEncoding => 'Audio wird kodiert';

  @override
  String get progressReadingWatermark => 'Wasserzeichen wird gelesen';

  @override
  String get progressPreparing => 'Vorbereitung...';

  @override
  String get progressDone => 'Abgeschlossen';

  @override
  String progressRunning(String operation) {
    return 'Wird ausgeführt: $operation';
  }

  @override
  String get cancelButton => 'Abbrechen';

  @override
  String get okButton => 'OK';

  @override
  String get importSuccess => 'Daten erfolgreich importiert.';

  @override
  String get importErrorBadZip => 'Ungültiger Inhalt des ZIP-Archivs';

  @override
  String importErrorGeneral(String error) {
    return 'Importfehler: $error';
  }

  @override
  String get exportSuccess => 'Daten erfolgreich exportiert.';

  @override
  String exportErrorGeneral(String error) {
    return 'Exportfehler: $error';
  }

  @override
  String get exportDialogTitle => 'Datenexport speichern';

  @override
  String get errorDecoding => 'Dekodierungsfehler';

  @override
  String get errorApplyingWatermark =>
      'Fehler beim Anwenden des Wasserzeichens';

  @override
  String get errorEncoding => 'Codec-Komprimierungsfehler';

  @override
  String get errorSaving => 'Speicherfehler';

  @override
  String get errorStegoExtraction => 'Steganographie-Extraktionsfehler';

  @override
  String get errorWatermarkNotFound =>
      'Wasserzeichen nicht gefunden oder passender Schlüssel fehlt.';

  @override
  String get errorNoKeysAvailable =>
      'Keine Schlüssel in der Bibliothek verfügbar. Erstellen oder importieren Sie zuerst einen Schlüssel.';

  @override
  String get errorNativeLibraryNotFound =>
      'audiowmark-Bibliothek nicht gefunden';

  @override
  String get errorOutputFileNotCreated => 'Ausgabedatei wurde nicht erstellt';

  @override
  String get errorDeleteKey => 'Fehler beim Löschen des Schlüssels';

  @override
  String get errorCreateKey => 'Fehler beim Erstellen des Schlüssels';

  @override
  String get errorExportData => 'Fehler beim Datenexport';

  @override
  String get errorOperationCancelled => 'Vorgang abgebrochen';

  @override
  String get errorAudioTooShort =>
      'Audio ist zu kurz für ein Wasserzeichen (mindestens 5 Sekunden)';

  @override
  String get errorStereoOnly =>
      'Nur Mono- oder Stereo-Audio unterstützt (bis zu 2 Kanäle)';

  @override
  String errorAudioNotFound(String path) {
    return 'Eingabe-Audiodatei nicht gefunden: $path';
  }

  @override
  String get permissionRequired =>
      'Für den Betrieb der App ist Zugriff auf Audiodateien erforderlich';

  @override
  String get menuLanguage => 'Language 🎌';
}
