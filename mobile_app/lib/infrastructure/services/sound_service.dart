import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle; 
import 'package:soundpool/soundpool.dart';
import 'package:flutter/foundation.dart';

/// Low-latency SFX player for swipe/match sounds
class SoundService {
	Soundpool? _pool;
	int? _swipeLikeId;
	int? _swipePassId;
	int? _matchSuccessId;
	bool _initialized = false;

	bool get isInitialized => _initialized;

	Future<void> initialize() async {
		try {
			_pool ??= Soundpool.fromOptions(options: const SoundpoolOptions(streamType: StreamType.music));
			// Preload assets (ignore errors if files not present yet)
			_swipeLikeId = await _tryLoad('assets/sounds/swipe_like.mp3');
			_swipePassId = await _tryLoad('assets/sounds/swipe_pass.mp3');
			_matchSuccessId = await _tryLoad('assets/sounds/match_success.mp3');
			_initialized = true;
		} catch (e) {
			debugPrint('SoundService: initialize error: $e');
		}
	}

	Future<int?> _tryLoad(String assetPath) async {
		try {
			final ByteData data = await rootBundle.load(assetPath);
			return _pool?.load(data);
		} catch (e) {
			debugPrint('SoundService: missing or failed to load $assetPath - $e');
			return null;
		}
	}

	Future<void> playSwipeLike() async {
		await _play(_swipeLikeId);
	}

	Future<void> playSwipePass() async {
		await _play(_swipePassId);
	}

	Future<void> playMatchSuccess() async {
		await _play(_matchSuccessId, volume: 1.0);
	}

	Future<void> _play(int? soundId, {double volume = 0.8}) async {
		final pool = _pool;
		if (pool == null || soundId == null) return;
		try {
			await pool.play(soundId, volume: volume);
		} catch (e) {
			debugPrint('SoundService: play error: $e');
		}
	}
}


