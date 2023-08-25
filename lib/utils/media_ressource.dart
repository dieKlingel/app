import 'package:flutter_webrtc/flutter_webrtc.dart';

class MediaRessource {
  MediaStream? _stream;

  MediaStream? get stream {
    return _stream;
  }

  Future<MediaStream?> open(bool audio, bool video) async {
    if (null != _stream) return _stream;
    Map<String, bool> constraints = {
      'audio': audio,
      'video': video,
    };
    try {
      _stream = await navigator.mediaDevices.getUserMedia(constraints);
    } catch (e) {
      // TODO: noting stream is empty
    }
    return _stream;
  }

  void close() {
    _stream?.getTracks().forEach((track) {
      track.stop();
    });
    _stream?.dispose();
    _stream = null;
  }
}
