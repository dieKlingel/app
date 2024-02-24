import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VideoRendererController {
  MethodChannel? _channel;

  VideoRendererController();

  void sedId(int id) {
    _channel = MethodChannel("NativeVideoRenderer/$id");
  }

  Future<int> getId() async {
    final int result = await _channel?.invokeMethod('getNativeTextureId');
    return result;
  }
}

class VideoRenderer extends StatelessWidget {
  static const StandardMessageCodec _decoder = StandardMessageCodec();
  final VideoRendererController controller;
  final void Function(int id)? onNativeId;

  const VideoRenderer({super.key, required this.controller, this.onNativeId});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 640,
      height: 480,
      child: UiKitView(
        viewType: "NativeVideoRenderer",
        creationParamsCodec: _decoder,
        onPlatformViewCreated: (id) async {
          controller.sedId(id);
          int textureId = await controller.getId();
          onNativeId?.call(textureId);
        },
      ),
    );
  }
}
