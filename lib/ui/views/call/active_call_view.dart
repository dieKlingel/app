import 'package:flutter/material.dart';
import 'package:flutter_liblinphone/flutter_liblinphone.dart';
import 'package:flutter_liblinphone/widgets.dart';

class ActiveCallView extends StatefulWidget {
  final Core core;
  final Call call;

  const ActiveCallView({super.key, required this.core, required this.call});

  @override
  State<ActiveCallView> createState() => _ActiveCallViewState();
}

class _ActiveCallViewState extends State<ActiveCallView> {
  late final renderer = VideoController(widget.core);
  late final cbs = Factory.instance.createCallCbs()
    ..onCallStateChanged = onCallStateChanged;
  int videoWidth = 0;
  int videoHeight = 0;
  late bool isMicMuted = widget.call.getMicrophoneMuted();
  late AudioDevice audioOutputDevice = widget.call.getOutputAudioDevice();

  @override
  void initState() {
    widget.call.addCallbacks(cbs);
    VideoDefintion defintion = widget.core.getPreferredVideoDefinition();
    setState(() {
      videoWidth = defintion.getWidth();
      videoHeight = defintion.getHeight();
    });
    setState(() {
      isMicMuted = true;
    });
    widget.call.setMicrophoneMuted(true);
    super.initState();
  }

  void onCallStateChanged(
    Call call,
    CallState state,
  ) {
    switch (state) {
      case CallState.end:
      case CallState.error:
        Navigator.of(context).pop();
        break;
      default:
        break;
    }
  }

  void _onAudioOutputSelected(AudioDevice device) {
    setState(() {
      audioOutputDevice = device;
    });
    widget.core.setOutputAudioDevice(device);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          InteractiveViewer(
            child: Center(
              child: AspectRatio(
                aspectRatio: videoWidth / videoHeight,
                child: VideoView(controller: renderer),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: AlignmentDirectional.bottomCenter,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton.filled(
                    iconSize: 26,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.red),
                    ),
                    onPressed: () {
                      widget.call.terminate();
                    },
                    icon: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.call_end),
                    ),
                  ),
                  PopupMenuButton<AudioDevice>(
                    initialValue: audioOutputDevice,
                    itemBuilder: (context) {
                      final devices = widget.core.getAudioDevices();
                      return [
                        for (final device in devices)
                          PopupMenuItem(
                            value: device,
                            child: Text(
                              _withOutputIosFix(device.getDeviceName()),
                            ),
                          ),
                      ];
                    },
                    onSelected: _onAudioOutputSelected,
                    iconSize: 26,
                    icon: Container(
                      decoration: const BoxDecoration(
                        color: Colors.lightBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Icon(
                          Icons.volume_up,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  IconButton.filled(
                    onPressed: () {
                      setState(() {
                        isMicMuted = !isMicMuted;
                      });
                      widget.call.setMicrophoneMuted(isMicMuted);
                    },
                    icon: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(isMicMuted ? Icons.mic_off : Icons.mic),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.call.removeCallbacks(cbs);
    renderer.dispose();
    super.dispose();
  }
}

String _withOutputIosFix(String deviceName) {
  if (deviceName == "iPhone Microphone") {
    return "Earphone";
  }

  return deviceName;
}
