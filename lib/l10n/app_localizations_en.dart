import 'app_localizations.dart';

// ignore_for_file: type=lint

class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Shizukamark';

  @override
  String get homeApplyMark => 'Apply mark';

  @override
  String get homeReadMark => 'Read mark';

  @override
  String get homeKeys => 'Known keys';

  @override
  String get homeImport => 'Import data';

  @override
  String get homeExport => 'Export data';

  @override
  String get applyMarkTitle => 'Apply mark';

  @override
  String get applyMarkSecretHint => 'Enter secret message';

  @override
  String get applyMarkFileHint => 'Select audio file';

  @override
  String get applyMarkKeyHint => 'Select key';

  @override
  String get applyMarkOr => 'or';

  @override
  String get applyMarkCreateKey => 'Create new key';

  @override
  String get applyMarkExportFolder => 'Export folder: Music/Shizukamark (MediaStore)';

  @override
  String get applyMarkUseMediaStore => 'System folder Music/Shizukamark (MediaStore)';

  @override
  String get applyMarkUseCustomSave => 'Custom save (save dialog)';

  @override
  String applyMarkCustomFolder(String path) {
    return 'Save as: $path';
  }

  @override
  String get applyMarkButton => 'Apply watermark';

  @override
  String get applyMarkErrorNoMessage => 'Enter secret message';

  @override
  String get applyMarkErrorNoFile => 'Select audio file';

  @override
  String get applyMarkErrorNoKey => 'Create or select a key';

  @override
  String applyMarkSuccessSaved(String path) {
    return 'File saved successfully: $path';
  }

  @override
  String get readMarkTitle => 'Read mark';

  @override
  String get readMarkFileHint => 'Select watermarked audio';

  @override
  String get readMarkImportHint => 'Don\'t forget to import data from the watermark creator beforehand to be able to read it.';

  @override
  String get readMarkOutputHint => 'Secret message will appear here';

  @override
  String get readMarkPatientCheckbox => 'Use patient reading';

  @override
  String get readMarkPatientSubtitle => 'Detects minor speed changes but takes longer.';

  @override
  String get readMarkButton => 'Read watermark';

  @override
  String get readMarkErrorNoFile => 'Select a watermarked audio file';

  @override
  String get readMarkSuccess => 'Watermark read successfully!';

  @override
  String get readMarkCopyButton => 'Copy to clipboard';

  @override
  String get readMarkCopied => 'Message copied to clipboard';

  @override
  String get keysTitle => 'Keys';

  @override
  String get keysEmpty => 'No keys yet.';

  @override
  String keysUnnamed(String fileName) {
    return '(Unnamed) · $fileName';
  }

  @override
  String get keysCreateButton => 'Create new key';

  @override
  String keysDeleteConfirm(String keyName) {
    return 'Are you sure you want to delete saved key "$keyName"?';
  }

  @override
  String get keysDeleteTitle => 'Delete key';

  @override
  String get keysDeleted => 'Key deleted';

  @override
  String get createKeyTitle => 'Create new key';

  @override
  String get createKeyHint => 'Enter key name';

  @override
  String get createKeyErrorEmpty => 'Key name cannot be empty';

  @override
  String get createKeyErrorMaxLength => 'Maximum 128 characters';

  @override
  String get createKeyErrorInvalidChars => 'Invalid characters in key name';

  @override
  String get createKeyErrorGeneral => 'Enter a valid key name (1–128 characters)';

  @override
  String get selectKeyTitle => 'Select key';

  @override
  String get codecDialogTitle => 'Output audio format';

  @override
  String get codecLossyHeader => 'Lossy compression:';

  @override
  String get codecLosslessHeader => 'Lossless:';

  @override
  String get codecSelectButton => 'Select';

  @override
  String get progressDecoding => 'Decoding audio';

  @override
  String get progressApplyingWatermark => 'Applying watermark';

  @override
  String get progressEncoding => 'Encoding audio';

  @override
  String get progressReadingWatermark => 'Reading watermark';

  @override
  String get progressPreparing => 'Preparing...';

  @override
  String get progressDone => 'Done';

  @override
  String progressRunning(String operation) {
    return 'Processing $operation';
  }

  @override
  String get cancelButton => 'Cancel';

  @override
  String get okButton => 'OK';

  @override
  String get importSuccess => 'Data imported successfully.';

  @override
  String get importErrorBadZip => 'Invalid zip archive contents';

  @override
  String importErrorGeneral(String error) {
    return 'Import error: $error';
  }

  @override
  String get exportSuccess => 'Data exported successfully.';

  @override
  String exportErrorGeneral(String error) {
    return 'Export error: $error';
  }

  @override
  String get exportDialogTitle => 'Save data export';

  @override
  String get errorDecoding => 'Decoding error';

  @override
  String get errorApplyingWatermark => 'Watermark application error';

  @override
  String get errorEncoding => 'Codec compression error';

  @override
  String get errorSaving => 'Save error';

  @override
  String get errorStegoExtraction => 'Stego extraction error';

  @override
  String get errorWatermarkNotFound => 'Watermark not found, or you don\'t have the key.';

  @override
  String get errorDeleteKey => 'Key deletion error';

  @override
  String get errorCreateKey => 'Key creation error';

  @override
  String get errorExportData => 'Data export error';

  @override
  String get errorOperationCancelled => 'Operation cancelled';

  @override
  String get errorAudioTooShort => 'Audio too short for watermark (minimum 5 seconds)';

  @override
  String get errorStereoOnly => 'Only mono or stereo audio supported (up to 2 channels)';

  @override
  String errorAudioNotFound(String path) {
    return 'Input audio file not found: $path';
  }

  @override
  String get permissionRequired => 'Audio file access is required for the app to work';
}
