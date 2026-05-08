import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();
  static final AudioPlayer _bgmPlayer = AudioPlayer();

  // Jouer un petit effet sonore (succès, clic, etc.)
  static Future<void> playEffect(String fileName) async {
    try {
      await _player.play(AssetSource('sounds/$fileName'));
    } catch (e) {
      print("Erreur son effect: $e");
    }
  }

  // Jouer la musique d'ambiance en boucle
  static Future<void> playBackgroundMusic(String fileName) async {
    try {
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.play(AssetSource('sounds/$fileName'), volume: 0.4);
    } catch (e) {
      print("Erreur musique fond: $e");
    }
  }

  static Future<void> stopMusic() async {
    await _bgmPlayer.stop();
  }
}
