import 'app_localizations.dart';

// ignore_for_file: type=lint

class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Shizukamark';

  @override
  String get homeApplyMark => 'Нанести знак';

  @override
  String get homeReadMark => 'Прочитать знак';

  @override
  String get homeKeys => 'Известные ключи';

  @override
  String get homeImport => 'Импорт данных';

  @override
  String get homeExport => 'Экспорт данных';

  @override
  String get applyMarkTitle => 'Нанести знак';

  @override
  String get applyMarkSecretHint => 'Введите секретное сообщение';

  @override
  String get applyMarkFileHint => 'Выберите музло';

  @override
  String get applyMarkKeyHint => 'Выберите ключ';

  @override
  String get applyMarkOr => 'или';

  @override
  String get applyMarkCreateKey => 'Создать новый ключ';

  @override
  String get applyMarkExportFolder => 'Папка экспорта: Music/Shizukamark (MediaStore)';

  @override
  String get applyMarkUseMediaStore => 'Системная папка Music/Shizukamark (MediaStore)';

  @override
  String get applyMarkUseCustomSave => 'Кастомное сохранение (диалог сохранения)';

  @override
  String applyMarkCustomFolder(String path) {
    return 'Сохранить как: $path';
  }

  @override
  String get applyMarkButton => 'Наложить водяной знак';

  @override
  String get applyMarkErrorNoMessage => 'Введите секретное сообщение';

  @override
  String get applyMarkErrorNoFile => 'Выберите музло';

  @override
  String get applyMarkErrorNoKey => 'Создайте или выберите ключ';

  @override
  String applyMarkSuccessSaved(String path) {
    return 'Файл успешно сохранён: $path';
  }

  @override
  String get readMarkTitle => 'Прочитать знак';

  @override
  String get readMarkFileHint => 'Выберите помеченное музло';

  @override
  String get readMarkImportHint => 'Не забудьте предварительно импортировать данные от создателя водяного знака, чтобы смочь прочитать его.';

  @override
  String get readMarkOutputHint => 'Здесь будет секретное сообщение';

  @override
  String get readMarkPatientCheckbox => 'Использовать усердное чтение';

  @override
  String get readMarkPatientSubtitle => 'Детектирует незначительные изменения скорости, но требует больше времени.';

  @override
  String get readMarkButton => 'Прочитать водяной знак';

  @override
  String get readMarkErrorNoFile => 'Выберите помеченное водяным знаком музло';

  @override
  String get readMarkSuccess => 'Водяной знак успешно прочитан!';

  @override
  String get readMarkCopyButton => 'Скопировать в буфер обмена';

  @override
  String get readMarkCopied => 'Сообщение скопировано в буфер обмена';

  @override
  String get keysTitle => 'Ключи';

  @override
  String get keysEmpty => 'Ключей пока нет.';

  @override
  String keysUnnamed(String fileName) {
    return '(Без имени) · $fileName';
  }

  @override
  String get keysCreateButton => 'Создать новый ключ';

  @override
  String keysDeleteConfirm(String keyName) {
    return 'Вы действительно хотите удалить сохранённый ключ "$keyName"?';
  }

  @override
  String get keysDeleteTitle => 'Удаление ключа';

  @override
  String get keysDeleted => 'Ключ удалён';

  @override
  String get createKeyTitle => 'Создать новый ключ';

  @override
  String get createKeyHint => 'Введите имя ключа';

  @override
  String get createKeyErrorEmpty => 'Имя ключа не может быть пустым';

  @override
  String get createKeyErrorMaxLength => 'Максимум 128 символов';

  @override
  String get createKeyErrorInvalidChars => 'Недопустимые символы в имени ключа';

  @override
  String get createKeyErrorGeneral => 'Введите корректное имя ключа (1–128 символов)';

  @override
  String get selectKeyTitle => 'Выберите ключ';

  @override
  String get codecDialogTitle => 'Формат выходного аудио';

  @override
  String get codecLossyHeader => 'Сжатие с потерями (Lossy):';

  @override
  String get codecLosslessHeader => 'Без потерь (Lossless):';

  @override
  String get codecSelectButton => 'Выбрать';

  @override
  String get progressDecoding => 'Декодирование аудио';

  @override
  String get progressApplyingWatermark => 'Наложение водяного знака';

  @override
  String get progressEncoding => 'Кодирование аудио';

  @override
  String get progressReadingWatermark => 'Чтение водяного знака';

  @override
  String get progressPreparing => 'Подготовка...';

  @override
  String get progressDone => 'Завершено';

  @override
  String progressRunning(String operation) {
    return 'Выполняется $operation';
  }

  @override
  String get cancelButton => 'Отмена';

  @override
  String get okButton => 'Ок';

  @override
  String get importSuccess => 'Данные успешно импортированы.';

  @override
  String get importErrorBadZip => 'zip архив с неправильным содержимым';

  @override
  String importErrorGeneral(String error) {
    return 'Ошибка импорта: $error';
  }

  @override
  String get exportSuccess => 'Данные успешно экспортированы.';

  @override
  String exportErrorGeneral(String error) {
    return 'Ошибка экспорта: $error';
  }

  @override
  String get exportDialogTitle => 'Сохранить экспорт данных';

  @override
  String get errorDecoding => 'Ошибка декодирования';

  @override
  String get errorApplyingWatermark => 'Ошибка наложения водяного знака';

  @override
  String get errorEncoding => 'Ошибка сжатия кодеком';

  @override
  String get errorSaving => 'Ошибка сохранения';

  @override
  String get errorStegoExtraction => 'Ошибка извлечения стего';

  @override
  String get errorWatermarkNotFound => 'Водяной знак не обнаружен, или у вас нет к нему ключа.';

  @override
  String get errorDeleteKey => 'Ошибка удаления ключа';

  @override
  String get errorCreateKey => 'Ошибка создания ключа';

  @override
  String get errorExportData => 'Ошибка экспорта данных';

  @override
  String get errorOperationCancelled => 'Операция отменена';

  @override
  String get errorAudioTooShort => 'Аудио слишком короткое для водяного знака (минимум 5 секунд)';

  @override
  String get errorStereoOnly => 'Поддерживается только моно или стерео аудио (до 2 каналов)';

  @override
  String errorAudioNotFound(String path) {
    return 'Входной аудиофайл не найден: $path';
  }

  @override
  String get permissionRequired => 'Для работы приложения необходим доступ к аудиофайлам';
}
