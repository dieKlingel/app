import 'package:dieklingel_app/components/radio_box_group.dart';
import 'package:flutter/cupertino.dart';

class RadioBox extends StatelessWidget {
  final bool value;
  final void Function(bool)? onChanged;
  late final RadioBoxGroup group;

  /*const RadioBox({
    Key? key,
    required RadioBoxGroup group,
    required this.value,
    required this.onChanged,
  });*/

  RadioBox({
    Key? key,
    required this.value,
    required this.onChanged,
    RadioBoxGroup? group,
  }) : super(key: key) {
    this.group = (null == group) ? RadioBoxGroup(maxSelection: 1) : group;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      child: Icon(
        value ? CupertinoIcons.check_mark_circled : CupertinoIcons.circle,
      ),
      onPressed: (onChanged == null)
          ? null
          : () {
              onChanged?.call(!value);
            },
    );
  }
}
