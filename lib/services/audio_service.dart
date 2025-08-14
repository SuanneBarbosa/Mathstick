import 'package:just_audio/just_audio.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playAudio(String assetPath, {double speed = 1.0}) async {
    try {
      await _audioPlayer.setAsset(assetPath);
      await _audioPlayer.play();
    } catch (e) {
      print("Erro ao tocar áudio: $e");
    }
  }

  Future<void> stopAudio() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print("Erro ao parar áudio: $e");
    }
  }

  void setSpeed(double speed) {
    _audioPlayer.setSpeed(speed);
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
