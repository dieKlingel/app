import 'package:dieklingel_app/components/notifyable_value.dart';
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
  final MediaRessource mediaRessource;
  final RTCVideoRenderer rtcVideoRenderer;
  final void Function(RtcConnectionState state)? onCallStateChanged;
  final bool autoStartCall;

  CallView({
    Key? key,
    this.onCallStateChanged,
    MediaRessource? mediaRessource,
    RTCVideoRenderer? rtcVideoRenderer,
    this.autoStartCall = false,
  })  : rtcVideoRenderer = rtcVideoRenderer ?? RTCVideoRenderer(),
        mediaRessource = mediaRessource ?? MediaRessource(),
        super(key: key);

  @override
  State<CallView> createState() => _CallView();
}

class _CallView extends State<CallView> {
  bool _micIsEnabled = false;

  @override
  void initState() {
    super.initState();
    widget.rtcVideoRenderer.initialize();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.autoStartCall) {
        _onCallButtonPressed();
      }
    });
  }

  ConnectionConfiguration getDefaultConnectionConfiguration() {
    return context.read<AppSettings>().connectionConfigurations.firstWhere(
          (element) => element.isDefault,
          orElse: () =>
              context.read<AppSettings>().connectionConfigurations.first,
        );
  }

  void _onCallButtonPressed() async {
    if (context.read<NotifyableValue<RtcClient?>>().value != null) {
      context.read<NotifyableValue<RtcClient?>>().value?.hangup();
      widget.rtcVideoRenderer.srcObject = null;
      context.read<NotifyableValue<RtcClient?>>().value = null;
      return;
    }
    await widget.mediaRessource.open(true, false);
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
      widget.mediaRessource,
      ice,
      onMediatrackReceived: (mediaStream) {
        setState(
          () {
            widget.rtcVideoRenderer.srcObject = mediaStream;
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

    if (!mounted) return;
    context.read<NotifyableValue<RtcClient?>>().value = client;
    setState(() {
      widget.mediaRessource.stream?.getAudioTracks()[0].enabled =
          _micIsEnabled = false;
    });
  }

  void _onMicButtonPressed() {
    widget.mediaRessource.stream?.getAudioTracks()[0].enabled = !_micIsEnabled;
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
            child: RTCVideoView(widget.rtcVideoRenderer),
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
                    context.watch<NotifyableValue<RtcClient?>>().value == null
                        ? CupertinoIcons.phone
                        : CupertinoIcons.phone_arrow_down_left,
                    size: 40,
                  ),
                ),
                CupertinoButton(
                  onPressed:
                      context.watch<NotifyableValue<RtcClient?>>().value == null
                          ? null
                          : _onMicButtonPressed,
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
    widget.rtcVideoRenderer.dispose();
    super.dispose();
  }
}
