import 'dart:math' as math;
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central Audio & Haptic manager with zero-dependency synthesized WAV audio
/// and responsive device haptics.
class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  static const String _soundKey = 'hc_sound_enabled';
  static const String _hapticKey = 'hc_haptic_enabled';

  bool _soundEnabled = true;
  bool _hapticEnabled = true;
  bool _initialized = false;

  bool get soundEnabled => _soundEnabled;
  bool get hapticEnabled => _hapticEnabled;

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final Map<String, Uint8List> _audioCache = {};

  Future<void> init() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _soundEnabled = prefs.getBool(_soundKey) ?? true;
      _hapticEnabled = prefs.getBool(_hapticKey) ?? true;

      // Pre-synthesize core game audio bytes
      _audioCache['tap'] = _generateBeepWav(freq: 700, durationMs: 40, volume: 0.25);
      _audioCache['bat_hit'] = _generateBatCrackWav();
      _audioCache['coin'] = _generateCoinClinkWav();
      _audioCache['boundary'] = _generateFanfareWav();
      _audioCache['wicket'] = _generateWicketWav();
      _audioCache['cheer'] = _generateCheerWav();

      _initialized = true;
    } catch (e) {
      debugPrint('AudioService init error: $e');
    }
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, enabled);
  }

  Future<void> setHapticEnabled(bool enabled) async {
    _hapticEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticKey, enabled);
  }

  // ============================================================
  // HAPTIC FEEDBACK
  // ============================================================

  void lightTap() {
    if (!_hapticEnabled) return;
    HapticFeedback.lightImpact();
  }

  void mediumTap() {
    if (!_hapticEnabled) return;
    HapticFeedback.mediumImpact();
  }

  void heavyImpact() {
    if (!_hapticEnabled) return;
    HapticFeedback.heavyImpact();
  }

  void selectionClick() {
    if (!_hapticEnabled) return;
    HapticFeedback.selectionClick();
  }

  void wicketVibration() {
    if (!_hapticEnabled) return;
    HapticFeedback.vibrate();
  }

  // ============================================================
  // SOUND EFFECTS
  // ============================================================

  Future<void> playTap() async {
    lightTap();
    if (!_soundEnabled) return;
    await _playCachedSound('tap');
  }

  Future<void> playCoinFlip() async {
    mediumTap();
    if (!_soundEnabled) return;
    await _playCachedSound('coin');
  }

  Future<void> playBatHit({bool isBoundary = false}) async {
    if (isBoundary) {
      heavyImpact();
    } else {
      mediumTap();
    }
    if (!_soundEnabled) return;
    if (isBoundary) {
      await _playCachedSound('boundary');
    } else {
      await _playCachedSound('bat_hit');
    }
  }

  Future<void> playWicket() async {
    wicketVibration();
    if (!_soundEnabled) return;
    await _playCachedSound('wicket');
  }

  Future<void> playVictory() async {
    heavyImpact();
    if (!_soundEnabled) return;
    await _playCachedSound('cheer');
  }

  Future<void> _playCachedSound(String key) async {
    final bytes = _audioCache[key];
    if (bytes == null) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(BytesSource(bytes));
    } catch (_) {
      // Audio playback fails gracefully on platforms without audio output
    }
  }

  // ============================================================
  // WAV PCM AUDIO SYNTHESIS (Zero Assets Needed)
  // ============================================================

  static Uint8List _generateBeepWav({
    required double freq,
    required int durationMs,
    double volume = 0.5,
    int sampleRate = 22050,
  }) {
    final totalSamples = (sampleRate * durationMs / 1000).toInt();
    final pcm = Int16List(totalSamples);

    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final envelope = (1.0 - (i / totalSamples)); // Linear decay
      final sample = math.sin(2 * math.pi * freq * t) * envelope * volume;
      pcm[i] = (sample * 32767).clamp(-32768, 32767).toInt();
    }
    return _buildWavHeader(pcm, sampleRate: sampleRate);
  }

  static Uint8List _generateBatCrackWav() {
    const sampleRate = 22050;
    const durationMs = 120;
    final totalSamples = (sampleRate * durationMs / 1000).toInt();
    final pcm = Int16List(totalSamples);
    final random = math.Random(42);

    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final envelope = math.exp(-t * 45); // Sharp wood crack decay
      final tone1 = math.sin(2 * math.pi * 320 * t);
      final tone2 = math.sin(2 * math.pi * 640 * t) * 0.5;
      final noise = (random.nextDouble() * 2 - 1) * 0.35;
      final sample = (tone1 + tone2 + noise) * envelope * 0.7;
      pcm[i] = (sample * 32767).clamp(-32768, 32767).toInt();
    }
    return _buildWavHeader(pcm, sampleRate: sampleRate);
  }

  static Uint8List _generateCoinClinkWav() {
    const sampleRate = 22050;
    const durationMs = 180;
    final totalSamples = (sampleRate * durationMs / 1000).toInt();
    final pcm = Int16List(totalSamples);

    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final envelope = math.exp(-t * 22);
      final bell1 = math.sin(2 * math.pi * 1850 * t);
      final bell2 = math.sin(2 * math.pi * 3200 * t) * 0.4;
      final sample = (bell1 + bell2) * envelope * 0.5;
      pcm[i] = (sample * 32767).clamp(-32768, 32767).toInt();
    }
    return _buildWavHeader(pcm, sampleRate: sampleRate);
  }

  static Uint8List _generateFanfareWav() {
    const sampleRate = 22050;
    const durationMs = 380;
    final totalSamples = (sampleRate * durationMs / 1000).toInt();
    final pcm = Int16List(totalSamples);

    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final noteIndex = (t * 12).toInt().clamp(0, 3);
      final freqs = [523.25, 659.25, 783.99, 1046.50];
      final freq = freqs[noteIndex];
      final envelope = math.sin((i / totalSamples) * math.pi);
      final sample = math.sin(2 * math.pi * freq * t) * envelope * 0.6;
      pcm[i] = (sample * 32767).clamp(-32768, 32767).toInt();
    }
    return _buildWavHeader(pcm, sampleRate: sampleRate);
  }

  static Uint8List _generateWicketWav() {
    const sampleRate = 22050;
    const durationMs = 280;
    final totalSamples = (sampleRate * durationMs / 1000).toInt();
    final pcm = Int16List(totalSamples);
    final random = math.Random(99);

    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final envelope = math.exp(-t * 18);
      final thud = math.sin(2 * math.pi * 140 * t) * 0.7;
      final rattle = (random.nextDouble() * 2 - 1) * 0.5;
      final sample = (thud + rattle) * envelope * 0.7;
      pcm[i] = (sample * 32767).clamp(-32768, 32767).toInt();
    }
    return _buildWavHeader(pcm, sampleRate: sampleRate);
  }

  static Uint8List _generateCheerWav() {
    const sampleRate = 22050;
    const durationMs = 450;
    final totalSamples = (sampleRate * durationMs / 1000).toInt();
    final pcm = Int16List(totalSamples);

    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final envelope = math.sin(math.min(1.0, (i / totalSamples) * 3) * math.pi * 0.5) * (1.0 - i / totalSamples);
      final cMajor = math.sin(2 * math.pi * 523.25 * t) +
          math.sin(2 * math.pi * 659.25 * t) * 0.7 +
          math.sin(2 * math.pi * 783.99 * t) * 0.7;
      final sample = (cMajor / 2.4) * envelope * 0.65;
      pcm[i] = (sample * 32767).clamp(-32768, 32767).toInt();
    }
    return _buildWavHeader(pcm, sampleRate: sampleRate);
  }

  static Uint8List _buildWavHeader(Int16List pcmData, {required int sampleRate}) {
    final byteData = ByteData(44 + pcmData.lengthInBytes);

    // RIFF header
    byteData.setUint8(0, 0x52); // 'R'
    byteData.setUint8(1, 0x49); // 'I'
    byteData.setUint8(2, 0x46); // 'F'
    byteData.setUint8(3, 0x46); // 'F'
    byteData.setUint32(4, 36 + pcmData.lengthInBytes, Endian.little);
    byteData.setUint8(8, 0x57);  // 'W'
    byteData.setUint8(9, 0x41);  // 'A'
    byteData.setUint8(10, 0x56); // 'V'
    byteData.setUint8(11, 0x45); // 'E'

    // fmt subchunk
    byteData.setUint8(12, 0x66); // 'f'
    byteData.setUint8(13, 0x6D); // 'm'
    byteData.setUint8(14, 0x74); // 't'
    byteData.setUint8(15, 0x20); // ' '
    byteData.setUint32(16, 16, Endian.little); // Subchunk1Size
    byteData.setUint16(20, 1, Endian.little);  // AudioFormat (1 = PCM)
    byteData.setUint16(22, 1, Endian.little);  // NumChannels (1 = Mono)
    byteData.setUint32(24, sampleRate, Endian.little); // SampleRate
    byteData.setUint32(28, sampleRate * 2, Endian.little); // ByteRate
    byteData.setUint16(32, 2, Endian.little);  // BlockAlign
    byteData.setUint16(34, 16, Endian.little); // BitsPerSample

    // data subchunk
    byteData.setUint8(36, 0x64); // 'd'
    byteData.setUint8(37, 0x61); // 'a'
    byteData.setUint8(38, 0x74); // 't'
    byteData.setUint8(39, 0x61); // 'a'
    byteData.setUint32(40, pcmData.lengthInBytes, Endian.little);

    final buffer = byteData.buffer.asUint8List();
    buffer.setRange(44, 44 + pcmData.lengthInBytes, pcmData.buffer.asUint8List());

    return buffer;
  }
}
