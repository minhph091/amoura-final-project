import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Low-latency SFX player for swipe/match sounds using audioplayers
class SoundService {
	AudioPlayer? _likePlayer;
	AudioPlayer? _passPlayer;
	AudioPlayer? _matchPlayer;
	bool _initialized = false;

	bool get isInitialized => _initialized;

	Future<void> initialize() async {
		try {
			_likePlayer = AudioPlayer(playerId: 'sfx_like');
			_passPlayer = AudioPlayer(playerId: 'sfx_pass');
			_matchPlayer = AudioPlayer(playerId: 'sfx_match');

			await _likePlayer!.setReleaseMode(ReleaseMode.stop);
			await _passPlayer!.setReleaseMode(ReleaseMode.stop);
			await _matchPlayer!.setReleaseMode(ReleaseMode.stop);

			// Preload sources (best-effort)
			await _likePlayer!.setSource(AssetSource('sounds/swipe_like.mp3')).catchError((_) {});
			await _passPlayer!.setSource(AssetSource('sounds/swipe_pass.mp3')).catchError((_) {});
			await _matchPlayer!.setSource(AssetSource('sounds/match_success.mp3')).catchError((_) {});

			_initialized = true;
		} catch (e) {
			debugPrint('SoundService: initialize error: $e');
		}
	}

	Future<void> playSwipeLike() async {
		await _play(_likePlayer, 'sounds/swipe_like.mp3', volume: 0.8);
	}

	Future<void> playSwipePass() async {
		await _play(_passPlayer, 'sounds/swipe_pass.mp3', volume: 0.7);
	}

	Future<void> playMatchSuccess() async {
		await _play(_matchPlayer, 'sounds/match_success.mp3', volume: 1.0);
	}

	Future<void> _play(AudioPlayer? player, String assetPath, {double volume = 1.0}) async {
		if (player == null) return;
		try {
			await player.stop();
			await player.setVolume(volume);
			await player.play(AssetSource(assetPath));
		} catch (e) {
			debugPrint('SoundService: play error: $e');
		}
	}
}


