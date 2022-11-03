import 'package:dieklingel_app/views/wizard/icon_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InputView extends StatelessWidget {
  final String text;
  final String next;
  final bool? valid;
  final Widget child;

  const InputView({
    super.key,
    required this.text,
    this.next = "",
    this.valid,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 20),
          child,
          const SizedBox(height: 30),
          valid != false
              ? IconText(
                  icon: CupertinoIcons.arrow_left,
                  text: next,
                )
              : const Text(""),
        ],
      ),
    );
  }
}
