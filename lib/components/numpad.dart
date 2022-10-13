import 'package:flutter/cupertino.dart';

class Numpad extends StatelessWidget {
  const Numpad({Key? key, this.onInput}) : super(key: key);

  final Function(String input)? onInput;

  Widget _button(String text) {
    return SizedBox(
      width: 70,
      child: CupertinoButton(
        child: Text(text),
        onPressed: () {
          onInput?.call(text);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _button("1"),
            _button("2"),
            _button("3"),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _button("4"),
            _button("5"),
            _button("6"),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _button("7"),
            _button("8"),
            _button("9"),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const SizedBox(),
            _button("0"),
            const SizedBox(),
          ],
        )
      ],
    );
  }
}
