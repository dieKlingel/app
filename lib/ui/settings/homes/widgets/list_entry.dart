import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../models/home.dart';

class ListEntry extends StatelessWidget {
  final Home home;
  final void Function() onTap;
  final void Function() onDismiss;

  const ListEntry({
    super.key,
    required this.home,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        child: const Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: Icon(
            CupertinoIcons.trash,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => onDismiss(),
      child: CupertinoListTile(
        title: Text(home.name),
        onTap: () => onTap(),
        leading: const Icon(CupertinoIcons.home),
        trailing: const Icon(CupertinoIcons.chevron_forward),
      ),
    );
  }
}
