import 'app_localizations.dart';

// ignore_for_file: type=lint

class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Shizukamark (しずかマーク)';

  @override
  String get homeApplyMark => '電子透かしを埋め込む';

  @override
  String get homeReadMark => '電子透かしを読み取る';

  @override
  String get homeKeys => '既知のキー';

  @override
  String get homeImport => 'データをインポート';

  @override
  String get homeExport => 'データをエクスポート';

  @override
  String get applyMarkTitle => '電子透かしを埋め込む';

  @override
  String get applyMarkSecretHint => '秘密のメッセージを入力';

  @override
  String applyMarkCharCount(int count) {
    return '文字数: $count';
  }

  @override
  String get applyMarkFileHint => '音声ファイルを選択';

  @override
  String get applyMarkKeyHint => 'キーを選択';

  @override
  String get applyMarkOr => 'または';

  @override
  String get applyMarkCreateKey => '新しいキーを作成';

  @override
  String get applyMarkExportFolder => 'エクスポート先フォルダ';

  @override
  String get applyMarkUseMediaStore =>
      'システムフォルダ Music/Shizukamark (MediaStore)';

  @override
  String get applyMarkUseCustomSave => 'カスタム保存（保存先選択ダイアログ）';

  @override
  String applyMarkCustomFolder(String path) {
    return '保存先: $path';
  }

  @override
  String get applyMarkButton => '電子透かしを埋め込む';

  @override
  String get applyMarkErrorNoMessage => '秘密のメッセージを入力してください';

  @override
  String get applyMarkErrorNoFile => '音声ファイルを選択してください';

  @override
  String get applyMarkErrorNoKey => 'キーを作成または選択してください';

  @override
  String applyMarkSuccessSaved(String path) {
    return 'ファイルが正常に保存されました: $path';
  }

  @override
  String get readMarkTitle => '電子透かしを読み取る';

  @override
  String get readMarkFileHint => '透かし入りの音声ファイルを選択';

  @override
  String get readMarkImportHint => '読み取るには、事前に透かし作成者からのデータをインポートしてください。';

  @override
  String get readMarkOutputHint => 'ここに秘密のメッセージが表示されます';

  @override
  String get readMarkPatientCheckbox => '詳細読み取りを使用（低速）';

  @override
  String get readMarkPatientSubtitle => 'わずかな速度変化を検出しますが、より時間がかかります。';

  @override
  String get readMarkButton => '電子透かしを読み取る';

  @override
  String get readMarkErrorNoFile => '透かし入りの音声ファイルを選択してください';

  @override
  String get readMarkSuccess => '電子透かしの読み取りに成功しました！';

  @override
  String get readMarkCopyButton => 'クリップボードにコピー';

  @override
  String get readMarkCopied => 'メッセージをクリップボードにコピーしました';

  @override
  String get keysTitle => 'キー一覧';

  @override
  String get keysEmpty => 'キーがまだありません。';

  @override
  String keysUnnamed(String fileName) {
    return '(名前なし) · $fileName';
  }

  @override
  String get keysCreateButton => '新しいキーを作成';

  @override
  String keysDeleteConfirm(String keyName) {
    return '保存されたキー「$keyName」を削除してもよろしいですか？';
  }

  @override
  String get keysDeleteTitle => 'キーの削除';

  @override
  String get keysDeleted => 'キーを削除しました';

  @override
  String get createKeyTitle => '新しいキーを作成';

  @override
  String get createKeyHint => 'キー名を入力';

  @override
  String get createKeyErrorEmpty => 'キー名を空にすることはできません';

  @override
  String get createKeyErrorMaxLength => '最大128文字です';

  @override
  String get createKeyErrorInvalidChars => 'キー名に無効な文字が含まれています';

  @override
  String get createKeyErrorGeneral => '有効なキー名を入力してください (1〜128文字)';

  @override
  String get createKeyErrorDuplicateName => 'この名前のキーは既に存在します';

  @override
  String get selectKeyTitle => 'キーを選択';

  @override
  String get codecDialogTitle => '出力音声フォーマット';

  @override
  String get codecLossyHeader => '非可逆圧縮 (Lossy):';

  @override
  String get codecLosslessHeader => '可逆圧縮 (Lossless):';

  @override
  String get codecSelectButton => '選択';

  @override
  String get codecAacRecommended => 'AAC (推奨)';

  @override
  String get progressDecoding => '音声をデコード中';

  @override
  String get progressApplyingWatermark => '電子透かしを埋め込み中';

  @override
  String get progressEncoding => '音声をエンコード中';

  @override
  String get progressReadingWatermark => '電子透かしを読み取り中';

  @override
  String get progressPreparing => '準備中...';

  @override
  String get progressDone => '完了';

  @override
  String progressRunning(String operation) {
    return '処理中: $operation';
  }

  @override
  String get cancelButton => 'キャンセル';

  @override
  String get okButton => 'OK';

  @override
  String get importSuccess => 'データが正常にインポートされました。';

  @override
  String get importErrorBadZip => 'zipアーカイブの内容が無効です';

  @override
  String importErrorGeneral(String error) {
    return 'インポートエラー: $error';
  }

  @override
  String get exportSuccess => 'データが正常にエクスポートされました。';

  @override
  String exportErrorGeneral(String error) {
    return 'エクスポートエラー: $error';
  }

  @override
  String get exportDialogTitle => 'エクスポートデータの保存';

  @override
  String get errorDecoding => 'デコードエラー';

  @override
  String get errorApplyingWatermark => '透かし埋め込みエラー';

  @override
  String get errorEncoding => 'コーデック圧縮エラー';

  @override
  String get errorSaving => '保存エラー';

  @override
  String get errorStegoExtraction => 'ステガノグラフィ抽出エラー';

  @override
  String get errorWatermarkNotFound => '電子透かしが見つからないか、対応するキーがありません。';

  @override
  String get errorNoKeysAvailable => 'ライブラリにキーがありません。まずキーを作成またはインポートしてください。';

  @override
  String get errorNativeLibraryNotFound => 'audiowmarkライブラリが見つかりません';

  @override
  String get errorOutputFileNotCreated => '出力ファイルが作成されませんでした';

  @override
  String get errorDeleteKey => 'キー削除エラー';

  @override
  String get errorCreateKey => 'キー作成エラー';

  @override
  String get errorExportData => 'データエクスポートエラー';

  @override
  String get errorOperationCancelled => '操作がキャンセルされました';

  @override
  String get errorAudioTooShort => '音声が短すぎます（最低5秒必要です）';

  @override
  String get errorStereoOnly => 'モノラルまたはステレオ音声のみサポートされています（最大2チャンネル）';

  @override
  String errorAudioNotFound(String path) {
    return '入力音声ファイルが見つかりません: $path';
  }

  @override
  String get permissionRequired => 'アプリの動作には音声ファイルへのアクセス権限が必要です';

  @override
  String get menuLanguage => 'Language 🎌';
}
