import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IconText extends StatelessWidget {
  final IconData icon;
  final String text;

  const IconText({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 16,
        ),
        children: [
          WidgetSpan(
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(
                icon,
                color: Colors.grey,
                size: 20,
              ),
            ),
          ),
          TextSpan(text: text),
        ],
      ),
    );
  }
}
