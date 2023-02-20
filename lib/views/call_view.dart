import 'dart:async';
import 'dart:convert';

import 'package:dieklingel_app/blocs/home_view_bloc.dart';
import 'package:dieklingel_app/models/hive_ice_server.dart';
import 'package:dieklingel_app/utils/mqtt_channel.dart';
import 'package:dieklingel_app/utils/rtc_client_wrapper.dart';
import 'package:dieklingel_app/utils/rtc_transceiver.dart';
import 'package:dieklingel_core_shared/flutter_shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/home.dart';
import '../signaling/signaling_message.dart';
import '../signaling/signaling_message_type.dart';
import 'message_view.dart';

class CallView extends StatefulWidget {
  const CallView({super.key});

  @override
  State<StatefulWidget> createState() => _CallView();
}

class _CallView extends State<CallView> {
  RtcClientWrapper? wrapper;

  void _onMessagePressed(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const MessageView(),
      ),
    );
  }

  Future<void> _onCallPressed(BuildContext context) async {
    HomeViewBloc homebloc = context.bloc<HomeViewBloc>();
    MqttClientBloc mqtt = context.bloc<MqttClientBloc>();
    Box<HiveIceServer> box = Hive.box<HiveIceServer>((IceServer).toString());
    print(box.values);
    RtcClientWrapper client = await RtcClientWrapper.create(
      iceServers: box.values.toList(),
      transceivers: [
        RtcTransceiver(
          kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
          direction: TransceiverDirection.SendRecv,
        ),
        RtcTransceiver(
          kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
          direction: TransceiverDirection.RecvOnly,
        )
      ],
    );
    setState(() {
      wrapper = client;
    });
    String uuid = const Uuid().v4();
    MqttChannel channel = MqttChannel("rtc/$uuid");
    String invite = channel.append("invite").toString();
    String answer = channel.append("answer").toString();

    StreamSubscription subscription = mqtt.watch(answer).listen(
      (event) {
        SignalingMessage message = SignalingMessage.fromJson(
          jsonDecode(event.value),
        );

        client.addMessage(message);
      },
    );

    client.onMessage(
      (SignalingMessage message) {
        if (message.type == SignalingMessageType.leave ||
            message.type == SignalingMessageType.error) {
          subscription.cancel();
          client.dispose();
        }

        mqtt.message.add(
          ChannelMessage(
            invite,
            jsonEncode(message.toJson()),
          ),
        );
      },
    );

    client.renderer.onFirstFrameRendered = () {
      // emit setState as soon,as the first frame is renderd, to update the ui
      setState(() {});
    };

    await client.ressource.open(true, false);
    Home home = await homebloc.home.stream.first;
    MqttChannel rtcChannel = MqttChannel(
      home.uri.channel,
    ).append(channel.toString());

    MqttUri rtcUri = home.uri.copyWith(channel: rtcChannel.toString());

    String? result = await mqtt.request(
      "request/rtc/${const Uuid().v4()}",
      jsonEncode(rtcUri.toMap()),
    );

    if (result != "OK") {
      client.close();
      setState(() {
        wrapper = null;
      });
      return;
    }

    await client.open();
  }

  Future<void> _onHangupPressed(BuildContext context) async {
    await wrapper?.close();
    setState(() {
      wrapper = null;
    });
  }

  Widget _video(BuildContext context) {
    RTCVideoRenderer? renderer = wrapper?.renderer;
    if (renderer == null) {
      return Container();
    }

    return ValueListenableBuilder(
      valueListenable: wrapper!.state,
      builder: (
        BuildContext context,
        RTCPeerConnectionState state,
        Widget? child,
      ) {
        if (wrapper?.connection.connectionState !=
            RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        }
        return InteractiveViewer(
          child: RTCVideoView(renderer),
        );
      },
    );
  }

  Widget _callButton(BuildContext context) {
    return StreamBuilder(
      stream: context.bloc<MqttClientBloc>().state,
      builder: (
        BuildContext context,
        AsyncSnapshot<MqttClientState> snapshot,
      ) {
        if (snapshot.data != MqttClientState.connected) {
          return const CupertinoButton(
            onPressed: null,
            child: Icon(CupertinoIcons.phone),
          );
        }

        return CupertinoButton(
          onPressed: wrapper == null
              ? () => _onCallPressed(context)
              : () => _onHangupPressed(context),
          child: Icon(
            wrapper == null
                ? CupertinoIcons.phone
                : CupertinoIcons.phone_arrow_down_left,
            size: 35,
          ),
        );
      },
    );
  }

  Widget _micButton(BuildContext context) {
    if (wrapper == null) {
      return const CupertinoButton(
        onPressed: null,
        child: Icon(
          CupertinoIcons.mic_off,
          size: 35,
        ),
      );
    }

    return CupertinoButton(
      onPressed: () {
        // TODO: toogle mic
      },
      child: const Icon(
        CupertinoIcons.mic_off,
        size: 35,
      ),
    );
  }

  Widget _toolbar(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _callButton(context),
              _micButton(context),
              const CupertinoButton(
                onPressed: null,
                child: Icon(
                  CupertinoIcons.speaker_2,
                  size: 35,
                ),
              ),
              const CupertinoButton(
                onPressed: null,
                child: Icon(
                  CupertinoIcons.lock_open,
                  size: 35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _taskbar(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: StreamBuilder(
            stream: context.bloc<MqttClientBloc>().state,
            builder: (BuildContext context,
                AsyncSnapshot<MqttClientState> snapshot) {
              if (snapshot.hasData &&
                  snapshot.data == MqttClientState.connected) {
                return const Icon(CupertinoIcons.check_mark_circled);
              }
              return const Icon(CupertinoIcons.clear_circled);
            },
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: StreamBuilder(
          stream: context.bloc<HomeViewBloc>().home.stream,
          builder: (BuildContext context, AsyncSnapshot<Home> snapshot) {
            if (!snapshot.hasData) {
              return const Text("loading...");
            }
            return Text(snapshot.data!.name);
          },
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _onMessagePressed(context),
          child: const Icon(
            CupertinoIcons.pencil_ellipsis_rectangle,
          ),
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            _video(context),
            _taskbar(context),
            _toolbar(context),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    wrapper?.close();
    super.dispose();
  }
}
