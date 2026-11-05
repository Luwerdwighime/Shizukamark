import 'app_localizations.dart';

// ignore_for_file: type=lint

class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'Shizukamark (しずかマーク)';

  @override
  String get homeApplyMark => 'Нанести знак';

  @override
  String get homeReadMark => 'Прочитати знак';

  @override
  String get homeKeys => 'Відомі ключі';

  @override
  String get homeImport => 'Імпорт даних';

  @override
  String get homeExport => 'Експорт даних';

  @override
  String get applyMarkTitle => 'Нанести знак';

  @override
  String get applyMarkSecretHint => 'Введіть секретне повідомлення';

  @override
  String applyMarkCharCount(int count) {
    return 'Символів: $count';
  }

  @override
  String get applyMarkFileHint => 'Виберіть аудіофайл';

  @override
  String get applyMarkKeyHint => 'Виберіть ключ';

  @override
  String get applyMarkOr => 'або';

  @override
  String get applyMarkCreateKey => 'Створити новий ключ';

  @override
  String get applyMarkExportFolder => 'Папка експорту';

  @override
  String get applyMarkUseMediaStore =>
      'Системна папка Music/Shizukamark (MediaStore)';

  @override
  String get applyMarkUseCustomSave => 'Власне збереження (діалог збереження)';

  @override
  String applyMarkCustomFolder(String path) {
    return 'Зберегти як: $path';
  }

  @override
  String get applyMarkButton => 'Накласти водяний знак';

  @override
  String get applyMarkErrorNoMessage => 'Введіть секретне повідомлення';

  @override
  String get applyMarkErrorNoFile => 'Виберіть аудіофайл';

  @override
  String get applyMarkErrorNoKey => 'Створіть або виберіть ключ';

  @override
  String applyMarkSuccessSaved(String path) {
    return 'Файл успішно збережено: $path';
  }

  @override
  String get readMarkTitle => 'Прочитати знак';

  @override
  String get readMarkFileHint => 'Виберіть аудіо з водяним знаком';

  @override
  String get readMarkImportHint =>
      'Не забудьте заздалегідь імпортувати дані від творця водяного знака, щоб мати змогу прочитати його.';

  @override
  String get readMarkOutputHint => 'Тут з\'явиться секретне повідомлення';

  @override
  String get readMarkPatientCheckbox => 'Використовувати ретельне читання';

  @override
  String get readMarkPatientSubtitle =>
      'Виявляє незначні зміни швидкості, але потребує більше часу.';

  @override
  String get readMarkButton => 'Прочитати водяний знак';

  @override
  String get readMarkErrorNoFile => 'Виберіть аудіофайл з водяним знаком';

  @override
  String get readMarkSuccess => 'Водяний знак успішно прочитано!';

  @override
  String get readMarkCopyButton => 'Скопіювати в буфер обміну';

  @override
  String get readMarkCopied => 'Повідомлення скопійовано в буфер обміну';

  @override
  String get keysTitle => 'Ключі';

  @override
  String get keysEmpty => 'Ключів поки немає.';

  @override
  String keysUnnamed(String fileName) {
    return '(Без назви) · $fileName';
  }

  @override
  String get keysCreateButton => 'Створити новий ключ';

  @override
  String keysDeleteConfirm(String keyName) {
    return 'Ви дійсно бажаєте видалити збережений ключ "$keyName"?';
  }

  @override
  String get keysDeleteTitle => 'Видалення ключа';

  @override
  String get keysDeleted => 'Ключ видалено';

  @override
  String get createKeyTitle => 'Створити новий ключ';

  @override
  String get createKeyHint => 'Введіть ім\'я ключа';

  @override
  String get createKeyErrorEmpty => 'Ім\'я ключа не може бути порожнім';

  @override
  String get createKeyErrorMaxLength => 'Максимум 128 символів';

  @override
  String get createKeyErrorInvalidChars => 'Неприпустимі символи в імені ключа';

  @override
  String get createKeyErrorGeneral =>
      'Введіть коректне ім\'я ключа (1–128 символів)';

  @override
  String get createKeyErrorDuplicateName => 'Ключ з такою назвою вже існує';

  @override
  String get selectKeyTitle => 'Виберіть ключ';

  @override
  String get codecDialogTitle => 'Формат вихідного аудіо';

  @override
  String get codecLossyHeader => 'Стиснення з втратами (Lossy):';

  @override
  String get codecLosslessHeader => 'Без втрат (Lossless):';

  @override
  String get codecSelectButton => 'Вибрати';

  @override
  String get codecAacRecommended => 'AAC (рекомендовано)';

  @override
  String get progressDecoding => 'Декодування аудіо';

  @override
  String get progressApplyingWatermark => 'Накладання водяного знака';

  @override
  String get progressEncoding => 'Кодування аудіо';

  @override
  String get progressReadingWatermark => 'Читання водяного знака';

  @override
  String get progressPreparing => 'Підготовка...';

  @override
  String get progressDone => 'Завершено';

  @override
  String progressRunning(String operation) {
    return 'Виконується $operation';
  }

  @override
  String get cancelButton => 'Скасувати';

  @override
  String get okButton => 'ОК';

  @override
  String get importSuccess => 'Дані успішно імпортовано.';

  @override
  String get importErrorBadZip => 'zip архів з неправильним вмістом';

  @override
  String importErrorGeneral(String error) {
    return 'Помилка імпорту: $error';
  }

  @override
  String get exportSuccess => 'Дані успішно експортовано.';

  @override
  String exportErrorGeneral(String error) {
    return 'Помилка експорту: $error';
  }

  @override
  String get exportDialogTitle => 'Зберегти експорт даних';

  @override
  String get errorDecoding => 'Помилка декодування';

  @override
  String get errorApplyingWatermark => 'Помилка накладання водяного знака';

  @override
  String get errorEncoding => 'Помилка стиснення кодеком';

  @override
  String get errorSaving => 'Помилка збереження';

  @override
  String get errorStegoExtraction => 'Помилка вилучення стего';

  @override
  String get errorWatermarkNotFound =>
      'Водяний знак не знайдено, або у вас немає для нього ключа.';

  @override
  String get errorNoKeysAvailable =>
      'У бібліотеці немає ключів. Спочатку створіть або імпортуйте ключ.';

  @override
  String get errorNativeLibraryNotFound => 'Бібліотеку audiowmark не знайдено';

  @override
  String get errorOutputFileNotCreated => 'Вихідний файл не було створено';

  @override
  String get errorDeleteKey => 'Помилка видалення ключа';

  @override
  String get errorCreateKey => 'Помилка створення ключа';

  @override
  String get errorExportData => 'Помилка експорту даних';

  @override
  String get errorOperationCancelled => 'Операцію скасовано';

  @override
  String get errorAudioTooShort =>
      'Аудіо занадто коротке для водяного знака (мінімум 5 секунд)';

  @override
  String get errorStereoOnly =>
      'Підтримується лише моно або стерео аудіо (до 2 каналів)';

  @override
  String errorAudioNotFound(String path) {
    return 'Вхідний аудіофайл не знайдено: $path';
  }

  @override
  String get permissionRequired =>
      'Для роботи програми необхідний доступ до аудіофайлів';

  @override
  String get menuLanguage => 'Language 🎌';
}
