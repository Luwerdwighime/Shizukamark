import 'app_localizations.dart';

// ignore_for_file: type=lint

class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Shizukamark (しずかマーク)';

  @override
  String get homeApplyMark => 'Appliquer la marque';

  @override
  String get homeReadMark => 'Lire la marque';

  @override
  String get homeKeys => 'Clés connues';

  @override
  String get homeImport => 'Importer des données';

  @override
  String get homeExport => 'Exporter des données';

  @override
  String get applyMarkTitle => 'Appliquer la marque';

  @override
  String get applyMarkSecretHint => 'Entrez le message secret';

  @override
  String applyMarkCharCount(int count) {
    return 'Caractères : $count';
  }

  @override
  String get applyMarkFileHint => 'Sélectionnez un fichier audio';

  @override
  String get applyMarkKeyHint => 'Sélectionnez une clé';

  @override
  String get applyMarkOr => 'ou';

  @override
  String get applyMarkCreateKey => 'Créer une nouvelle clé';

  @override
  String get applyMarkExportFolder =>
      'Dossier d\'exportation: Music/Shizukamark (MediaStore)';

  @override
  String get applyMarkUseMediaStore =>
      'Dossier système Music/Shizukamark (MediaStore)';

  @override
  String get applyMarkUseCustomSave =>
      'Enregistrement personnalisé (boîte de dialogue)';

  @override
  String applyMarkCustomFolder(String path) {
    return 'Enregistrer sous: $path';
  }

  @override
  String get applyMarkButton => 'Appliquer le filigrane';

  @override
  String get applyMarkErrorNoMessage => 'Entrez le message secret';

  @override
  String get applyMarkErrorNoFile => 'Sélectionnez un fichier audio';

  @override
  String get applyMarkErrorNoKey => 'Créez ou sélectionnez une clé';

  @override
  String applyMarkSuccessSaved(String path) {
    return 'Fichier enregistré avec succès: $path';
  }

  @override
  String get readMarkTitle => 'Lire la marque';

  @override
  String get readMarkFileHint => 'Sélectionnez l\'audio avec filigrane';

  @override
  String get readMarkImportHint =>
      'N\'oubliez pas d\'importer au préalable les données du créateur du filigrane pour pouvoir le lire.';

  @override
  String get readMarkOutputHint => 'Le message secret apparaîtra ici';

  @override
  String get readMarkPatientCheckbox => 'Utiliser la lecture approfondie';

  @override
  String get readMarkPatientSubtitle =>
      'Détecte les légers changements de vitesse mais prend plus de temps.';

  @override
  String get readMarkButton => 'Lire le filigrane';

  @override
  String get readMarkErrorNoFile =>
      'Sélectionnez un fichier audio avec filigrane';

  @override
  String get readMarkSuccess => 'Filigrane lu avec succès !';

  @override
  String get readMarkCopyButton => 'Copier dans le presse-papiers';

  @override
  String get readMarkCopied => 'Message copié dans le presse-papiers';

  @override
  String get keysTitle => 'Clés';

  @override
  String get keysEmpty => 'Aucune clé pour le moment.';

  @override
  String keysUnnamed(String fileName) {
    return '(Sans nom) · $fileName';
  }

  @override
  String get keysCreateButton => 'Créer une nouvelle clé';

  @override
  String keysDeleteConfirm(String keyName) {
    return 'Voulez-vous vraiment supprimer la clé enregistrée "$keyName" ?';
  }

  @override
  String get keysDeleteTitle => 'Supprimer la clé';

  @override
  String get keysDeleted => 'Clé supprimée';

  @override
  String get createKeyTitle => 'Créer une nouvelle clé';

  @override
  String get createKeyHint => 'Entrez le nom de la clé';

  @override
  String get createKeyErrorEmpty => 'Le nom de la clé ne peut pas être vide';

  @override
  String get createKeyErrorMaxLength => 'Maximum 128 caractères';

  @override
  String get createKeyErrorInvalidChars =>
      'Caractères non valides dans le nom de la clé';

  @override
  String get createKeyErrorGeneral =>
      'Entrez un nom de clé valide (1–128 caractères)';

  @override
  String get selectKeyTitle => 'Sélectionnez une clé';

  @override
  String get codecDialogTitle => 'Format audio de sortie';

  @override
  String get codecLossyHeader => 'Compression avec perte (Lossy):';

  @override
  String get codecLosslessHeader => 'Sans perte (Lossless):';

  @override
  String get codecSelectButton => 'Sélectionner';

  @override
  String get codecAacRecommended => 'AAC (recommandé)';

  @override
  String get progressDecoding => 'Décodage audio';

  @override
  String get progressApplyingWatermark => 'Application du filigrane';

  @override
  String get progressEncoding => 'Encodage audio';

  @override
  String get progressReadingWatermark => 'Lecture du filigrane';

  @override
  String get progressPreparing => 'Préparation...';

  @override
  String get progressDone => 'Terminé';

  @override
  String progressRunning(String operation) {
    return 'En cours : $operation';
  }

  @override
  String get cancelButton => 'Annuler';

  @override
  String get okButton => 'OK';

  @override
  String get importSuccess => 'Données importées avec succès.';

  @override
  String get importErrorBadZip => 'Contenu d\'archive zip non valide';

  @override
  String importErrorGeneral(String error) {
    return 'Erreur d\'importation: $error';
  }

  @override
  String get exportSuccess => 'Données exportées avec succès.';

  @override
  String exportErrorGeneral(String error) {
    return 'Erreur d\'exportation: $error';
  }

  @override
  String get exportDialogTitle => 'Enregistrer l\'exportation';

  @override
  String get errorDecoding => 'Erreur de décodage';

  @override
  String get errorApplyingWatermark =>
      'Erreur lors de l\'application du filigrane';

  @override
  String get errorEncoding => 'Erreur de compression du codec';

  @override
  String get errorSaving => 'Erreur d\'enregistrement';

  @override
  String get errorStegoExtraction => 'Erreur d\'extraction stéganographique';

  @override
  String get errorWatermarkNotFound =>
      'Filigrane introuvable ou clé manquante.';

  @override
  String get errorNoKeysAvailable =>
      'Aucune clé disponible dans la bibliothèque. Créez ou importez d\'abord une clé.';

  @override
  String get errorNativeLibraryNotFound =>
      'Bibliothèque audiowmark introuvable';

  @override
  String get errorOutputFileNotCreated =>
      'Le fichier de sortie n\'a pas été créé';

  @override
  String get errorDeleteKey => 'Erreur de suppression de la clé';

  @override
  String get errorCreateKey => 'Erreur de création de la clé';

  @override
  String get errorExportData => 'Erreur d\'exportation de données';

  @override
  String get errorOperationCancelled => 'Opération annulée';

  @override
  String get errorAudioTooShort =>
      'Audio trop court pour le filigrane (minimum 5 secondes)';

  @override
  String get errorStereoOnly =>
      'Seul l\'audio mono ou stéréo est pris en charge (jusqu\'à 2 canaux)';

  @override
  String errorAudioNotFound(String path) {
    return 'Fichier audio d\'entrée introuvable: $path';
  }

  @override
  String get permissionRequired =>
      'L\'accès aux fichiers audio est requis pour le fonctionnement de l\'application';

  @override
  String get menuLanguage => 'Language 🎌';
}
