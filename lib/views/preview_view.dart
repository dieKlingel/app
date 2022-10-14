import 'dart:collection';
import 'dart:convert';

import 'package:audio_session/audio_session.dart';
import 'package:dieklingel_app/event/system_event.dart';
import 'package:dieklingel_app/views/preview/camera_live_view.dart';
import 'package:dieklingel_app/views/preview/message_bar.dart';
import 'package:dieklingel_app/views/preview/system_event_list_tile.dart';
import '../extensions/get_mclient.dart';
import 'package:uuid/uuid.dart';
import '../messaging/mclient_topic_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

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

class PreviewView extends StatefulWidget {
  const PreviewView({Key? key}) : super(key: key);

  @override
  State<PreviewView> createState() => _PreviewView();
}

class _PreviewView extends State<PreviewView> {
  final MediaRessource _mediaRessource = MediaRessource();
  final RTCVideoRenderer _rtcVideoRenderer = RTCVideoRenderer();
  final TextEditingController _bodyController = TextEditingController();
  final Queue<SystemEvent> _events = Queue<SystemEvent>();
  bool _sendButtonIsEnabled = false;
  double? aspectRatio;

  final ScrollController _controller = ScrollController();

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
      if (_sendButtonIsEnabled == _bodyController.text.isNotEmpty) return;
      setState(() {
        _sendButtonIsEnabled = _bodyController.text.isNotEmpty;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => initialize());
    _controller.addListener(() {
      if (_controller.offset == 0) {
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
    MClient mClient = context.read<MClient>();
    mClient.subscribe("system/event", (message) {
      SystemEvent event = SystemEvent.fromJson(jsonDecode(message.message));
      setState(() {
        _events.addFirst(event);
      });
    });
  }

  Future<void> _onRefresh() async {
    MClient mClient = context.read<MClient>();
    String? response = await mClient.get("request/events", "events");

    if (null == response) return;

    Iterable iterable = jsonDecode(response);
    List<SystemEvent> events = List<SystemEvent>.from(
      iterable.map(
        (e) => SystemEvent.fromJson(e),
      ),
    );
    events.sort(((a, b) => b.timestamp.compareTo(a.timestamp)));
    setState(() {
      _events.clear();
      _events.addAll(events);
    });
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
    context.read<SignalingClient>().uid = const Uuid().v4();
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

  Widget _refreshIndicator(BuildContext context) {
    return Padding(
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
    );
  }

  Widget _scrollView(BuildContext context) {
    bool listIsVisible = _events.isNotEmpty || aspectRatio != null;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: CupertinoScrollbar(
        controller: _controller,
        child: CustomScrollView(
          scrollBehavior: TouchScrollBehavior(),
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _controller,
          slivers: [
            CupertinoSliverRefreshControl(
              onRefresh: _onRefresh,
            ),
            SliverList(
              delegate: listIsVisible
                  ? SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == 0) {
                          return aspectRatio == null
                              ? Container()
                              : CameraLiveView(
                                  mediaRessource: _mediaRessource,
                                  rtcVideoRenderer: _rtcVideoRenderer,
                                );
                        }
                        if (index < _events.length + 1) {
                          return SystemEventListTile(
                            event: _events.elementAt(index - 1),
                          );
                        }
                        return null;
                      },
                      childCount: (_events.length + 1),
                    )
                  : SliverChildListDelegate(
                      [
                        _refreshIndicator(context),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    MClient mClient = context.read<MClient>();
    return Stack(
      children: [
        _scrollView(context),
        Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MessageBar(
              controller: _bodyController,
              onCallPressed:
                  mClient.isConnected() ? _onCallButtonPressed : null,
              onSendPressed: mClient.isConnected() && _sendButtonIsEnabled
                  ? _onUserNotificationSendPressed
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _rtcVideoRenderer.dispose();
  }
}
