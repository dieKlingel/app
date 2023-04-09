import 'dart:async';
import 'dart:convert';

import 'package:dieklingel_app/blocs/call_view_bloc.dart';
import 'package:dieklingel_app/blocs/home_view_bloc.dart';
import 'package:dieklingel_app/models/hive_ice_server.dart';
import 'package:dieklingel_app/states/call_state.dart';
import 'package:dieklingel_app/utils/mqtt_channel.dart';
import 'package:dieklingel_app/utils/rtc_client_wrapper.dart';
import 'package:dieklingel_app/utils/rtc_transceiver.dart';
import 'package:dieklingel_core_shared/flutter_shared.dart';
import 'package:dieklingel_core_shared/mqtt/mqtt_response.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_it/get_it.dart';
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
  RtcClientWrapper? _wrapper;
  bool _muted = true;
  bool _speaker = true;

  void _onMessagePressed(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const MessageView(),
      ),
    );
  }

  Future<void> _onCallPressed(BuildContext context) async {
    /* HomeViewBloc homebloc = context.bloc<HomeViewBloc>();
    MqttClientBloc mqtt = GetIt.I<MqttClientBloc>();
    Box<HiveIceServer> box = Hive.box<HiveIceServer>((IceServer).toString());
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
      _wrapper = client;
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

    await client.ressource.open(true, false);
    Home home = await homebloc.home.stream.first;
    MqttChannel rtcChannel = MqttChannel(
      home.uri.channel,
    ).append(channel.toString());

    MqttUri rtcUri = home.uri.copyWith(channel: rtcChannel.toString());

    MqttResponse result = await mqtt.request(
      "request/rtc/connect/${const Uuid().v4()}",
      jsonEncode(rtcUri.toMap()),
    );

    if (result.status != 200) {
      client.close();
      setState(() {
        _wrapper = null;
      });
      return;
    }

    await client.open();*/
  }

  Future<void> _onHangupPressed(BuildContext context) async {
    await _wrapper?.close();
    setState(() {
      _wrapper = null;
    });
  }

  Widget _video(BuildContext context) {
    RTCVideoRenderer? renderer = _wrapper?.renderer;
    if (renderer == null) {
      return Container();
    }

    return ValueListenableBuilder(
      valueListenable: _wrapper!.state,
      builder: (
        BuildContext context,
        RTCPeerConnectionState state,
        Widget? child,
      ) {
        if (_wrapper?.connection.connectionState !=
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
      stream: GetIt.I<MqttClientBloc>().state,
      builder: (
        BuildContext context,
        AsyncSnapshot<MqttClientState> snapshot,
      ) {
        if (snapshot.data != MqttClientState.connected) {
          return const CupertinoButton(
            onPressed: null,
            child: Icon(
              CupertinoIcons.phone,
              size: 35,
            ),
          );
        }

        return CupertinoButton(
          onPressed: _wrapper == null
              ? () => _onCallPressed(context)
              : () => _onHangupPressed(context),
          child: Icon(
            _wrapper == null
                ? CupertinoIcons.phone
                : CupertinoIcons.phone_arrow_down_left,
            size: 35,
          ),
        );
      },
    );
  }

  Widget _micButton(BuildContext context) {
    if (_wrapper == null) {
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
        setState(() {
          _muted = !_muted;
        });
        _wrapper?.ressource.stream?.getAudioTracks().forEach((track) {
          Helper.setMicrophoneMute(_muted, track);
        });
      },
      child: Icon(
        _muted ? CupertinoIcons.mic_off : CupertinoIcons.mic,
        size: 35,
      ),
    );
  }

  Widget _speakerButton(BuildContext context) {
    if (_wrapper == null) {
      return const CupertinoButton(
        onPressed: null,
        child: Icon(
          CupertinoIcons.speaker_2,
          size: 35,
        ),
      );
    }

    return CupertinoButton(
      onPressed: () {
        setState(() {
          _speaker = !_speaker;
        });
        if (!kIsWeb) {
          _wrapper?.renderer.srcObject?.getAudioTracks().forEach((track) {
            track.enableSpeakerphone(_speaker);
          });
        }
      },
      child: Icon(
        _speaker ? CupertinoIcons.speaker_3 : CupertinoIcons.speaker_1,
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
              if (!kIsWeb) _speakerButton(context),
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
            stream: GetIt.I<MqttClientBloc>().state,
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
    return SafeArea(
        child: Stack(
      children: [
        _Video(),
        _Toolbar(),
      ],
    ));

    /* return CupertinoPageScaffold(
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
    );*/
  }

  @override
  void dispose() {
    _wrapper?.close();
    super.dispose();
  }
}

class _Toolbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: BlocBuilder<CallViewBloc, CallState>(
        builder: (context, state) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: [
              _ToolbarButton(
                icon: const Icon(
                  CupertinoIcons.phone_fill,
                  color: Colors.white,
                ),
                color: state is CallActiveState || state is CallInitatedState
                    ? Colors.red
                    : Colors.green,
                onPressed: () {
                  context.read<CallViewBloc>().add(
                        state is CallActiveState || state is CallInitatedState
                            ? CallHangup()
                            : CallStart(),
                      );
                },
              ),
              _ToolbarButton(
                icon: Icon(
                  state is CallActiveState && !state.isMuted
                      ? CupertinoIcons.mic_fill
                      : CupertinoIcons.mic_slash_fill,
                  color: Colors.white,
                ),
                color: state is CallActiveState && !state.isMuted
                    ? Colors.red
                    : Colors.green,
                onPressed: state is CallActiveState
                    ? () {
                        context
                            .read<CallViewBloc>()
                            .add(CallMute(isMuted: !state.isMuted));
                      }
                    : null,
              ),
              _ToolbarButton(
                icon: Icon(
                  state is CallActiveState && state.speakerIsEarphone
                      ? CupertinoIcons.speaker_1_fill
                      : CupertinoIcons.speaker_3_fill,
                  color: Colors.white,
                ),
                color: Colors.green,
                onPressed: state is CallActiveState
                    ? () {
                        context.read<CallViewBloc>().add(
                              CallSpeaker(
                                isEarphone: !state.speakerIsEarphone,
                              ),
                            );
                      }
                    : null,
              ),
              const _ToolbarButton(
                icon: Icon(
                  CupertinoIcons.lock_fill,
                  color: Colors.white,
                ),
                color: Colors.amber,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final Icon icon;
  final Color color;
  final void Function()? onPressed;

  const _ToolbarButton({
    required this.icon,
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: onPressed == null ? Colors.black26 : color,
        ),
        child: icon,
      ),
    );
  }
}

class _Video extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CallViewBloc, CallState>(
      builder: (context, state) {
        if (state is CallInitatedState) {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        }

        if (state is CallActiveState) {
          return InteractiveViewer(
            child: RTCVideoView(
              state.renderer,
            ),
          );
        }

        return Container();
      },
    );
  }
}
