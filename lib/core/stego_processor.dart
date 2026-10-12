import '../data/db/database_helper.dart';
import '../data/keys/keys_storage.dart';
import '../domain/models/key_info.dart';
import 'audiowmark_service.dart';
import 'result.dart';

abstract class StegoProcessor {
  Future<Result<void>> add(
    String inPath,
    String outPath,
    String hash, {
    required String keyPath,
  });
  Future<Result<String>> get(String inPath, bool patient);
  void cancel();
}

class AudiowmarkStegoProcessor implements StegoProcessor {
  final AudiowmarkService _audiowmarkService;
  final KeysStorage _keysStorage;
  final DatabaseHelper _databaseHelper;

  AudiowmarkStegoProcessor({
    AudiowmarkService? audiowmarkService,
    KeysStorage? keysStorage,
    DatabaseHelper? databaseHelper,
  })  : _audiowmarkService = audiowmarkService ?? AudiowmarkService(),
        _keysStorage = keysStorage ?? KeysStorage(),
        _databaseHelper = databaseHelper ?? DatabaseHelper();

  @override
  void cancel() {
    _audiowmarkService.cancelCurrent();
  }

  @override
  Future<Result<void>> add(
    String inPath,
    String outPath,
    String hash, {
    required String keyPath,
  }) async {
    return _audiowmarkService.add(
      inWav: inPath,
      outWav: outPath,
      keyPath: keyPath,
      hash32: hash,
    );
  }

  @override
  Future<Result<String>> get(String inPath, bool patient) async {
    // 1. Load all available keys
    final Result<List<KeyInfo>> keysRes = await _keysStorage.listKeys();
    if (keysRes.isError) {
      return failure(keysRes.error!);
    }
    final List<KeyInfo> keys = keysRes.value ?? [];
    if (keys.isEmpty) {
      return failure('В библиотеке нет ключей. Сначала создайте или импортируйте ключ.');
    }

    final List<String> keyPaths = keys.map((k) => k.keyPath).toList();

    // 2. Run audiowmark get
    final Result<List<String>> scanRes = await _audiowmarkService.get(
      inWav: inPath,
      keyPaths: keyPaths,
      patient: patient,
    );

    if (scanRes.isError) {
      return failure(scanRes.error!);
    }

    final List<String> foundHashes = scanRes.value ?? [];
    if (foundHashes.isEmpty) {
      return failure('Водяной знак не обнаружен, или у вас нет к нему ключа.');
    }

    // 3. Search database for the first matching hash
    for (final String hash in foundHashes) {
      final Result<String?> msgRes = await _databaseHelper.findMessageByHash(hash);
      if (msgRes.isSuccess && msgRes.value != null && msgRes.value!.isNotEmpty) {
        return success(msgRes.value!);
      }
    }

    return failure('Водяной знак не обнаружен, или у вас нет к нему ключа.');
  }
}
