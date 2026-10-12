class KeyInfo {
  final String name;
  final String keyPath;

  const KeyInfo({
    required this.name,
    required this.keyPath,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KeyInfo &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          keyPath == other.keyPath;

  @override
  int get hashCode => name.hashCode ^ keyPath.hashCode;

  @override
  String toString() => 'KeyInfo(name: $name, keyPath: $keyPath)';
}
