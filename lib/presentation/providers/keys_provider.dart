import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/result.dart';
import '../../data/keys/keys_storage.dart';
import '../../domain/models/key_info.dart';

final keysStorageProvider = Provider<KeysStorage>((ref) {
  return KeysStorage();
});

class KeysNotifier extends StateNotifier<AsyncValue<List<KeyInfo>>> {
  final KeysStorage _storage;

  KeysNotifier(this._storage) : super(const AsyncValue.loading()) {
    loadKeys();
  }

  Future<void> loadKeys() async {
    state = const AsyncValue.loading();
    final Result<List<KeyInfo>> res = await _storage.listKeys();
    if (res.isSuccess) {
      state = AsyncValue.data(res.value ?? []);
    } else {
      state = AsyncValue.error(
          res.error ?? 'Ошибка загрузки ключей', StackTrace.current);
    }
  }

  Future<Result<KeyInfo>> createKey(String name) async {
    final Result<KeyInfo> res = await _storage.createKey(name);
    if (res.isSuccess) {
      await loadKeys();
    }
    return res;
  }

  Future<Result<void>> deleteKey(String keyPath) async {
    final Result<void> res = await _storage.deleteKey(keyPath);
    if (res.isSuccess) {
      await loadKeys();
    }
    return res;
  }
}

final keysProvider =
    StateNotifierProvider<KeysNotifier, AsyncValue<List<KeyInfo>>>((ref) {
  final storage = ref.watch(keysStorageProvider);
  return KeysNotifier(storage);
});
