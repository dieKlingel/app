import 'package:flutter/material.dart';

class SubHeadline extends StatelessWidget {
  final EdgeInsets padding;
  final Widget child;

  const SubHeadline({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.only(
      left: 14,
      top: 8.0,
    ),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
        const Divider(
          color: Colors.black,
        )
      ],
    );
  }
}
