import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'media_ressource.dart';

class MediaRessourceImpl implements MediaRessource {
  MediaStream? _stream;

  @override
  MediaStream? get stream {
    return _stream;
  }

  @override
  Future<MediaStream?> open(bool audio, bool video) async {
    if (null != _stream) return _stream;
    Map<String, bool> constraints = {
      'audio': audio,
      'video': video,
    };
    _stream = await navigator.mediaDevices.getUserMedia(constraints);
    return _stream;
  }

  @override
  void close() {
    _stream?.getTracks().forEach((track) {
      track.stop();
    });
    _stream?.dispose();
    _stream = null;
  }
}
