import 'package:dieklingel_app/blocs/call_view_bloc.dart';
import 'package:dieklingel_app/components/icon_builder.dart';
import 'package:dieklingel_app/components/map_builder.dart';
import 'package:dieklingel_app/states/call_state.dart';
import 'package:dieklingel_app/ui/view_models/call_view_model.dart';
import 'package:dieklingel_app/utils/microphone_state.dart';
import 'package:dieklingel_app/utils/speaker_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CallView extends StatelessWidget {
  const CallView({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _Video(),
        SafeArea(
          child: Stack(
            children: [
              _Toolbar(),
            ],
          ),
        ),
      ],
    );
  }
}

class _Toolbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isInCall = context.select<CallViewModel, bool>(
      (value) => value.isInCall,
    );

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
                  size: 30,
                ),
                color: isInCall ? Colors.red : Colors.green,
                onPressed: () {
                  if (isInCall) {
                    context.read<CallViewModel>().hangup();
                  } else {
                    context.read<CallViewModel>().dial();
                  }
                },
              ),
              _ToolbarButton(
                icon: IconBuilder<MicrophoneState, Icon>(
                  values: {
                    MicrophoneState.muted:
                        const Icon(CupertinoIcons.mic_slash_fill),
                    MicrophoneState.unmuted: const Icon(CupertinoIcons.mic_fill)
                  },
                  fallback: const Icon(CupertinoIcons.mic_slash_fill),
                  id: state is CallActiveState ? state.microphoneState : null,
                ).build(
                  color: Colors.white,
                  size: 30,
                ),
                color: MapBuilder<MicrophoneState, Color>(
                  values: {
                    MicrophoneState.muted: Colors.green,
                    MicrophoneState.unmuted: Colors.red,
                  },
                  fallback: Colors.green,
                  id: state is CallActiveState ? state.microphoneState : null,
                ).build(),
                onPressed: state is CallActiveState
                    ? () {
                        context
                            .read<CallViewBloc>()
                            .add(CallToogleMicrophone());
                      }
                    : null,
              ),
              _ToolbarButton(
                icon: IconBuilder<SpeakerState, Icon>(
                  values: {
                    SpeakerState.muted:
                        const Icon(CupertinoIcons.speaker_slash_fill),
                    SpeakerState.headphone:
                        const Icon(CupertinoIcons.speaker_1_fill),
                    SpeakerState.speaker:
                        const Icon(CupertinoIcons.speaker_3_fill),
                  },
                  fallback: const Icon(CupertinoIcons.speaker_slash_fill),
                  id: state is CallActiveState ? state.speakerState : null,
                ).build(
                  color: Colors.white,
                  size: 30,
                ),
                color: MapBuilder<SpeakerState, Color>(
                  values: {
                    SpeakerState.muted: Colors.green,
                    SpeakerState.headphone: Colors.orange,
                    SpeakerState.speaker: Colors.red,
                  },
                  fallback: Colors.green,
                  id: state is CallActiveState ? state.speakerState : null,
                ).build(),
                onPressed: state is CallActiveState
                    ? () {
                        context.read<CallViewBloc>().add(CallToogleSpeaker());
                      }
                    : null,
              ),
              _ToolbarButton(
                icon: const Icon(
                  CupertinoIcons.lock_fill,
                  color: Colors.white,
                  size: 30,
                ),
                color: Colors.amber,
                onPressed: () {
                  //TODO: context.read<HomeViewModel>().add(HomeUnlock());
                  showCupertinoDialog(
                    context: context,
                    builder: (BuildContext context) {
                      Future.delayed(const Duration(milliseconds: 600), () {
                        Navigator.of(context).pop();
                      });

                      return Center(
                        child: Icon(
                          CupertinoIcons.lock_open_fill,
                          size: 150,
                          color: Colors.green.shade400,
                        ),
                      );
                    },
                  );
                },
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
        padding: const EdgeInsets.all(15.0),
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
    final renderer = context.select<CallViewModel, RTCVideoRenderer?>(
      (value) => value.renderer,
    );

    if (renderer == null) {
      return Container();
    }

    final videoAvailable = context.select<CallViewModel, bool>(
      (value) => !value.isConnecting,
    );

    if (!videoAvailable) {
      return const Center(
        child: CupertinoActivityIndicator(),
      );
    }

    return ValueListenableBuilder(
      valueListenable: renderer,
      builder: (c, v, w) => InteractiveViewer(
        child: RTCVideoView(
          renderer,
        ),
      ),
    );
  }
}
