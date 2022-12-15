import 'package:flutter_webrtc/flutter_webrtc.dart';

abstract class MediaRessource {
  MediaStream? get stream;
  Future<MediaStream?> open(bool audio, bool video);
  void close();
}
