import 'package:flutter/cupertino.dart';

class CupertinoFormRowPrefix extends StatelessWidget {
  const CupertinoFormRowPrefix({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    this.iconColor = CupertinoColors.white,
  });

  final IconData icon;
  final String title;
  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Icon(icon, color: iconColor),
        ),
        const SizedBox(width: 15),
        Text(title)
      ],
    );
  }
}
