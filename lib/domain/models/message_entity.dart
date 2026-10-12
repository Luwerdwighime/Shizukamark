class MessageEntity {
  final int? id;
  final String msg;
  final String hash;
  final int ts;

  const MessageEntity({
    this.id,
    required this.msg,
    required this.hash,
    required this.ts,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'msg': msg,
      'hash': hash,
      'ts': ts,
    };
  }

  factory MessageEntity.fromMap(Map<String, dynamic> map) {
    return MessageEntity(
      id: map['id'] as int?,
      msg: map['msg'] as String,
      hash: map['hash'] as String,
      ts: map['ts'] as int,
    );
  }

  @override
  String toString() => 'MessageEntity(id: $id, msg: $msg, hash: $hash, ts: $ts)';
}
