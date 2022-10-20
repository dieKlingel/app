import 'dart:ui';

import 'package:dieklingel_app/components/notifyable_value.dart';
import 'package:dieklingel_app/rtc/rtc_client.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MessageBar extends StatelessWidget {
  final void Function()? onCallPressed;
  final void Function()? onSendPressed;
  final void Function()? onUnlockPressed;
  final TextEditingController? controller;

  const MessageBar({
    super.key,
    this.onCallPressed,
    this.onSendPressed,
    this.onUnlockPressed,
    this.controller,
  });

  Widget _icon(
    BuildContext context, {
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

  Widget _textfield(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 2, right: 2),
        child: CupertinoTextField(
          controller: controller,
          placeholder: "Message",
          // controller: _bodyController,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _icon(
                context,
                icon: true
                    ? CupertinoIcons.phone_circle
                    : CupertinoIcons.phone_down_circle,
                onPressed: onCallPressed,
              ),
              _textfield(context),
              _icon(
                context,
                icon: CupertinoIcons.arrow_up_circle,
                onPressed: onSendPressed,
              ),
              _icon(
                context,
                icon: CupertinoIcons.lock_circle,
                onPressed: onUnlockPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
