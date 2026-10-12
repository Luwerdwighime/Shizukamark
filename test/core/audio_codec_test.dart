import 'package:flutter_test/flutter_test.dart';
import 'package:shizukamark/domain/models/audio_codec.dart';

void main() {
  group('AudioCodec enum tests', () {
    test('all 6 required codecs exist in AudioCodec enum', () {
      expect(AudioCodec.values.length, 6);
      expect(AudioCodec.values, contains(AudioCodec.aac));
      expect(AudioCodec.values, contains(AudioCodec.opus));
      expect(AudioCodec.values, contains(AudioCodec.mp3));
      expect(AudioCodec.values, contains(AudioCodec.flac));
      expect(AudioCodec.values, contains(AudioCodec.wav));
      expect(AudioCodec.values, contains(AudioCodec.alac));
    });

    test('AAC codec properties per specification', () {
      expect(AudioCodec.aac.extension, '.m4a');
      expect(AudioCodec.aac.mimeType, 'audio/mp4');
      expect(AudioCodec.aac.ffmpegArgs, containsAllInOrder(['-c:a', 'aac', '-b:a', '192k']));
    });

    test('Opus codec properties per specification', () {
      expect(AudioCodec.opus.extension, '.opus');
      expect(AudioCodec.opus.ffmpegArgs, containsAllInOrder(['-c:a', 'libopus', '-b:a', '128k']));
    });

    test('MP3 codec properties per specification', () {
      expect(AudioCodec.mp3.extension, '.mp3');
      expect(AudioCodec.mp3.ffmpegArgs, containsAllInOrder(['-c:a', 'libmp3lame', '-b:a', '192k']));
    });

    test('FLAC codec properties per specification', () {
      expect(AudioCodec.flac.extension, '.flac');
      expect(AudioCodec.flac.ffmpegArgs, containsAllInOrder(['-c:a', 'flac']));
    });

    test('WAV codec properties per specification', () {
      expect(AudioCodec.wav.extension, '.wav');
      expect(AudioCodec.wav.ffmpegArgs, containsAllInOrder(['-c:a', 'pcm_s16le']));
    });

    test('ALAC codec properties per specification', () {
      expect(AudioCodec.alac.extension, '.m4a');
      expect(AudioCodec.alac.ffmpegArgs, containsAllInOrder(['-c:a', 'alac']));
    });
  });
}
