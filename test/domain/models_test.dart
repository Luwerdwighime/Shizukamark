import 'package:flutter_test/flutter_test.dart';
import 'package:shizukamark/domain/models/key_info.dart';
import 'package:shizukamark/domain/models/message_entity.dart';
import 'package:shizukamark/domain/models/progress_state.dart';

void main() {
  group('Domain Models tests', () {
    test('KeyInfo equality and toString', () {
      const KeyInfo k1 = KeyInfo(name: 'Key A', keyPath: 'keys/1.key');
      const KeyInfo k2 = KeyInfo(name: 'Key A', keyPath: 'keys/1.key');
      const KeyInfo k3 = KeyInfo(name: 'Key B', keyPath: 'keys/2.key');

      expect(k1, equals(k2));
      expect(k1.hashCode, equals(k2.hashCode));
      expect(k1 == k3, isFalse);
      expect(k1.toString(), contains('Key A'));
    });

    test('MessageEntity toMap and fromMap serialization', () {
      final MessageEntity entity = MessageEntity(
        id: 1,
        msg: 'Secret note',
        hash: '0123456789abcdef0123456789abcdef',
        ts: 1700000000000,
      );

      final Map<String, dynamic> map = entity.toMap();
      expect(map['id'], 1);
      expect(map['msg'], 'Secret note');
      expect(map['hash'], '0123456789abcdef0123456789abcdef');
      expect(map['ts'], 1700000000000);

      final MessageEntity restored = MessageEntity.fromMap(map);
      expect(restored.id, entity.id);
      expect(restored.msg, entity.msg);
      expect(restored.hash, entity.hash);
      expect(restored.ts, entity.ts);
    });

    test('OperationStep and ProgressDialogState copyWith', () {
      const OperationStep step =
          OperationStep(title: 'Decoding', isRunning: true);
      final OperationStep completed =
          step.copyWith(isRunning: false, isCompleted: true);
      expect(completed.title, 'Decoding');
      expect(completed.isRunning, isFalse);
      expect(completed.isCompleted, isTrue);

      final ProgressDialogState state = ProgressDialogState(
        steps: [step],
        progress: 0.1,
        currentOperation: 'Decoding',
      );
      final ProgressDialogState updated =
          state.copyWith(progress: 0.5, currentOperation: 'Stego');
      expect(updated.progress, 0.5);
      expect(updated.currentOperation, 'Stego');
    });
  });
}
