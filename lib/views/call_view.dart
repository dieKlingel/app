import 'package:dieklingel_app/blocs/call_view_bloc.dart';
import 'package:dieklingel_app/states/call_state.dart';
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
        )),
      ],
    );
  }
}

class _Toolbar extends StatelessWidget {
  List<Widget> buttons(BuildContext context, CallState state) => [
        _ToolbarButton(
          icon: const Icon(
            CupertinoIcons.phone_fill,
            color: Colors.white,
            size: 35,
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
            size: 35,
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
            size: 35,
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
            size: 35,
          ),
          color: Colors.amber,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: BlocBuilder<CallViewBloc, CallState>(
        builder: (context, state) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: buttons(context, state),
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
          return ValueListenableBuilder(
            valueListenable: state.renderer,
            builder: (c, v, w) => InteractiveViewer(
              child: RTCVideoView(
                state.renderer,
              ),
            ),
          );
        }

        return Container();
      },
    );
  }
}
