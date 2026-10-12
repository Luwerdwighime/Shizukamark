enum AudioCodec {
  aac('AAC (рекомендуется)', '.m4a', 'audio/mp4', ['-c:a', 'aac', '-b:a', '192k']),
  opus('Opus', '.opus', 'audio/ogg', ['-c:a', 'libopus', '-b:a', '128k']),
  mp3('MP3', '.mp3', 'audio/mpeg', ['-c:a', 'libmp3lame', '-b:a', '192k']),
  flac('FLAC', '.flac', 'audio/flac', ['-c:a', 'flac']),
  wav('WAV (PCM 16-bit)', '.wav', 'audio/wav', ['-c:a', 'pcm_s16le']),
  alac('ALAC', '.m4a', 'audio/mp4', ['-c:a', 'alac']);

  final String displayName;
  final String extension;
  final String mimeType;
  final List<String> ffmpegArgs;

  const AudioCodec(this.displayName, this.extension, this.mimeType, this.ffmpegArgs);
}
