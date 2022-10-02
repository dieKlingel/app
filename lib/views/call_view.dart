import 'package:dieklingel_app/rtc/rtc_connection_state.dart';

import '../components/app_settings.dart';
import '../components/connection_configuration.dart';
import '../messaging/messaging_client.dart';
import '../rtc/rtc_client.dart';
import '../signaling/signaling_client.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';

import '../components/simple_alert_dialog.dart';
import '../media/media_ressource.dart';

class CallView extends StatefulWidget {
  final void Function(RtcConnectionState state)? onCallStateChanged;

  const CallView({Key? key, this.onCallStateChanged}) : super(key: key);

  @override
  State<CallView> createState() => _CallView();
}

class _CallView extends State<CallView> {
  final MediaRessource _mediaRessource = MediaRessource();
  final RTCVideoRenderer _remoteVideo = RTCVideoRenderer();
  RtcClient? _rtcClient;
  bool _micIsEnabled = false;

  @override
  void initState() {
    super.initState();
    _remoteVideo.initialize();
  }

  ConnectionConfiguration getDefaultConnectionConfiguration() {
    return context.read<AppSettings>().connectionConfigurations.firstWhere(
          (element) => element.isDefault,
          orElse: () =>
              context.read<AppSettings>().connectionConfigurations.first,
        );
  }

  void _onCallButtonPressed() async {
    if (_rtcClient != null) {
      _rtcClient?.hangup();
      _remoteVideo.srcObject = null;
      setState(() {
        _rtcClient = null;
      });
      return;
    }
    await _mediaRessource.open(true, false);
    String? name = getDefaultConnectionConfiguration().channelPrefix;
    if (null == name) {
      if (!mounted) return;
      await displaySimpleAlertDialog(
        context,
        const Text("here we go again"),
        Text(
          """please add a channel prefix to the configuration: ${getDefaultConnectionConfiguration().description}""",
        ),
      );
      return;
    }
    if (!mounted) return;
    // TODO: change uid to random string
    context.read<SignalingClient>().uid = "app";
    List<Map<String, dynamic>> iceServers = [];
    context.read<AppSettings>().iceConfigurations.forEach(((element) {
      Map<String, dynamic> b = element.toJson();
      b.remove("_key");
      if (b["username"] != null && b["username"]!.isEmpty) {
        b.remove("username");
      }
      if (b["credential"] != null && b["credential"]!.isEmpty) {
        b.remove("credential");
      }
      iceServers.add(b);
    }));
    Map<String, dynamic> ice = {
      "iceServers": iceServers,
      "sdpSemantics": "unified-plan" // important to work
    };

    RtcClient client = RtcClient(
      context.read<SignalingClient>(),
      _mediaRessource,
      ice,
      onMediatrackReceived: (mediaStream) {
        setState(
          () {
            _remoteVideo.srcObject = mediaStream;
          },
        );
      },
      onStateChanged: (state, client) {
        widget.onCallStateChanged?.call(state);
      },
    );
    await client.invite(name, transceivers: [
      RtcTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
        direction: TransceiverDirection.SendRecv,
      ),
      RtcTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
        direction: TransceiverDirection.RecvOnly,
      ),
    ]);

    setState(() {
      _rtcClient = client;
      _mediaRessource.stream?.getAudioTracks()[0].enabled =
          _micIsEnabled = false;
    });
  }

  void _onMicButtonPressed() {
    _mediaRessource.stream?.getAudioTracks()[0].enabled = !_micIsEnabled;
    setState(() {
      _micIsEnabled = !_micIsEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: InteractiveViewer(
            child: RTCVideoView(_remoteVideo),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CupertinoButton(
                  onPressed: context.watch<MessagingClient>().isConnected()
                      ? _onCallButtonPressed
                      : null,
                  child: Icon(
                    _rtcClient == null
                        ? CupertinoIcons.phone
                        : CupertinoIcons.phone_arrow_down_left,
                    size: 40,
                  ),
                ),
                CupertinoButton(
                  onPressed: _rtcClient == null ? null : _onMicButtonPressed,
                  child: Icon(
                    _micIsEnabled
                        ? CupertinoIcons.mic
                        : CupertinoIcons.mic_slash,
                    size: 40,
                  ),
                ),
                const CupertinoButton(
                  onPressed: null,
                  child: Icon(
                    CupertinoIcons.speaker_1,
                    size: 40,
                  ),
                ),
                const CupertinoButton(
                  onPressed: null,
                  child: Icon(
                    CupertinoIcons.lock,
                    size: 40,
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _remoteVideo.dispose();
    super.dispose();
  }
}
