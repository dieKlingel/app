import 'package:flutter/material.dart';

class PasscodeDots extends StatelessWidget {
  const PasscodeDots({
    Key? key,
    required this.amount,
    required this.count,
    this.width = 10,
    this.color = Colors.grey,
  }) : super(key: key);

  final int amount;
  final int count;
  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(
        amount,
        (index) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: color,
              ),
              borderRadius: BorderRadius.all(Radius.circular(width / 2)),
              color: index < count ? color : null,
            ),
            width: width,
            height: width,
          );
        },
      ),
    );
  }
}
