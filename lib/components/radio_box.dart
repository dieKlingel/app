import 'package:flutter/cupertino.dart';

class RadioBox extends StatelessWidget {
  final bool value;
  final void Function(bool)? onChanged;

  /*const RadioBox({
    Key? key,
    required RadioBoxGroup group,
    required this.value,
    required this.onChanged,
  });*/

  const RadioBox({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: (onChanged == null)
          ? null
          : () {
              onChanged?.call(!value);
            },
      child: Icon(
        value ? CupertinoIcons.check_mark_circled : CupertinoIcons.circle,
      ),
    );
  }
}
