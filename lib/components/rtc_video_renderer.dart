import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class RtcVideoRenderer extends StatefulWidget {
  final RTCVideoRenderer renderer;

  const RtcVideoRenderer(this.renderer, {super.key});

  @override
  State<RtcVideoRenderer> createState() => _RtcViewRenderer();
}

class _RtcViewRenderer extends State<RtcVideoRenderer> {
  double _ratio = 1.0;
  bool _isRendering = false;

  @override
  void initState() {
    widget.renderer.addListener(_onRendererChanged);
    super.initState();
  }

  void _onRendererChanged() {
    setState(() {
      _isRendering = widget.renderer.renderVideo;
    });
    if (_isRendering) {
      setState(() {
        _ratio = widget.renderer.videoWidth / widget.renderer.videoHeight;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isRendering
        ? AspectRatio(
            aspectRatio: _ratio,
            child: RTCVideoView(widget.renderer),
          )
        : Container(
            width: 100,
            height: 100,
            color: Colors.red,
          );
  }

  @override
  void dispose() {
    widget.renderer.removeListener(_onRendererChanged);
    super.dispose();
  }
}
