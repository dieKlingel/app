import 'package:audio_session/audio_session.dart';
import 'package:dismissible_page/dismissible_page.dart';
import '../messaging/mclient_topic_message.dart';
import '../rtc/rtc_connection_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../components/app_settings.dart';
import '../components/connection_configuration.dart';
import '../components/notifyable_value.dart';
import '../components/simple_alert_dialog.dart';
import '../media/media_ressource.dart';
import '../messaging/mclient.dart';
import '../rtc/rtc_client.dart';
import '../signaling/signaling_client.dart';
import '../touch_scroll_behavior.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'call_view_page.dart';

class PreviewView extends StatefulWidget {
  const PreviewView({Key? key}) : super(key: key);

  @override
  State<PreviewView> createState() => _PreviewView();
}

class _PreviewView extends State<PreviewView> {
  final MediaRessource _mediaRessource = MediaRessource();
  final RTCVideoRenderer _rtcVideoRenderer = RTCVideoRenderer();
  final TextEditingController _bodyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _sendButtonIsEnabled = false;
  Image? _image;
  double? aspectRatio;

  ConnectionConfiguration getDefaultConnectionConfiguration() {
    return context.read<AppSettings>().connectionConfigurations.firstWhere(
          (element) => element.isDefault,
          orElse: () =>
              context.read<AppSettings>().connectionConfigurations.first,
        );
  }

  @override
  void initState() {
    super.initState();
    _rtcVideoRenderer.initialize();
    _rtcVideoRenderer.onResize = () {
      setState(() {
        aspectRatio = _rtcVideoRenderer.videoWidth.toDouble() /
            _rtcVideoRenderer.videoWidth.toDouble();
      });
    };
    _bodyController.addListener(() {
      setState(() {
        _sendButtonIsEnabled = _bodyController.text.isNotEmpty;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => initialize());
    _scrollController.addListener(() {
      if (_scrollController.offset == 0) {
        FocusScope.of(context).requestFocus(FocusNode());
      }
    });
  }

  void initialize() async {
    /* TODO: Hotfix: AudioSession
    Do this, so the mic starts the first time we use navigator.mediaDevices
    caues by this issue: https://github.com/flutter-webrtc/flutter-webrtc/issues/1094
    */
    AudioSession.instance.then((session) {
      session.configure(const AudioSessionConfiguration.speech());
    });

    // TODO: implement camera
    /* context.read<MessagingClient>().messageController.stream.listen((event) {
      switch (event.topic) {
        case "io/camera/snapshot":
          if (event.message.isEmpty) {
            context.read<MessagingClient>().send("io/camera/trigger", "now");
            break;
          }
          String base64 = event.message.startsWith("data:")
              ? event.message.split(";").last
              : event.message;
          Uint8List bytes = base64Decode(base64);
          setState(() {
            _image = Image.memory(bytes);
          });
          break;
      }
    }); */
  }

  Future<void> _onRefresh() async {
    /* if (!context.read<MessagingClient>().isConnected()) return;
    context.read<MessagingClient>().send("io/camera/trigger", "latest"); */
  }

  void _onUserNotificationSendPressed() {
    context.read<MClient>().publish(
          MClientTopicMessage(
            topic: "io/user/notification",
            message: _bodyController.text,
          ),
        );
    _bodyController.clear();
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _onCallButtonPressed() async {
    if (context.read<NotifyableValue<RtcClient?>>().value != null) {
      context.read<NotifyableValue<RtcClient?>>().value?.hangup();
      _rtcVideoRenderer.srcObject = null;
      setState(() {
        aspectRatio = null;
      });
      context.read<NotifyableValue<RtcClient?>>().value = null;
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
            _rtcVideoRenderer.srcObject = mediaStream;
          },
        );
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
      _mediaRessource.stream?.getAudioTracks()[0].enabled = false;
    });
  }

  Widget smallTextFieldIcon({
    required IconData icon,
    void Function()? onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, right: 2),
      child: SizedBox(
        width: 34,
        height: 34,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onPressed,
          child: Icon(
            icon,
            size: 35,
          ),
        ),
      ),
    );
  }

  Widget _scrollView(BuildContext context) {
    return CustomScrollView(
      scrollBehavior: TouchScrollBehavior(),
      physics: const AlwaysScrollableScrollPhysics(),
      controller: _scrollController,
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: _onRefresh,
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            [
              aspectRatio == null
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.all(10),
                      child: Hero(
                        tag: const Key("call_view_page"),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: GestureDetector(
                            onTap: () async {
                              context.pushTransparentRoute(CallViewPage(
                                mediaRessource: _mediaRessource,
                                rtcVideoRenderer: _rtcVideoRenderer,
                              ));
                            },
                            child: Stack(
                              children: [
                                AspectRatio(
                                  aspectRatio: _rtcVideoRenderer.videoWidth
                                          .toDouble() /
                                      _rtcVideoRenderer.videoHeight.toDouble(),
                                  child: RTCVideoView(
                                    _rtcVideoRenderer,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    margin: const EdgeInsets.all(10),
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
              _image == null
                  ? Padding(
                      padding: const EdgeInsets.all(35.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "swipe down to refresh",
                            style: TextStyle(color: Colors.grey),
                          ),
                          Icon(
                            CupertinoIcons.down_arrow,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    )
                  : CupertinoContextMenu(
                      actions: const [
                        CupertinoContextMenuAction(child: Text("Copy"))
                      ],
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: _image!,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  bool get _callIsConnected {
    return context
            .read<NotifyableValue<RtcClient?>>()
            .value
            ?.rtcConnectionState ==
        RtcConnectionState.connected;
  }

  Widget _bottomMessageBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 5.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          smallTextFieldIcon(
            icon: context.watch<NotifyableValue<RtcClient?>>().value == null
                ? CupertinoIcons.phone_circle
                : CupertinoIcons.phone_down_circle,
            onPressed: context.watch<MClient>().connectionState ==
                    MqttConnectionState.connected
                ? _onCallButtonPressed
                : null,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 2, right: 2),
              child: CupertinoTextField(
                placeholder: "Message",
                controller: _bodyController,
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 7),
                decoration: BoxDecoration(
                  color: const CupertinoDynamicColor.withBrightness(
                    color: Colors.white,
                    darkColor: Colors.black,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: CupertinoDynamicColor.withBrightness(
                      color: Colors.grey.shade300,
                      darkColor: Colors.grey.shade800,
                    ),
                  ),
                ),
                minLines: 1,
                maxLines: 5,
              ),
            ),
          ),
          smallTextFieldIcon(
            icon: CupertinoIcons.arrow_up_circle,
            onPressed: context.watch<MClient>().connectionState ==
                        MqttConnectionState.connected &&
                    _sendButtonIsEnabled
                ? _onUserNotificationSendPressed
                : null,
          ),
          smallTextFieldIcon(
            icon: CupertinoIcons.lock_circle,
            onPressed: null,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _scrollView(context),
        Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _bottomMessageBar(context),
          ],
        ),
        //scrollView(context),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _rtcVideoRenderer.dispose();
  }
}
