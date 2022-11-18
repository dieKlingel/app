import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MessageSheet extends StatefulWidget {
  const MessageSheet({super.key});

  @override
  State<MessageSheet> createState() => _MessageSheet();
}

class _MessageSheet extends State<MessageSheet> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text("Message"),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Icon(CupertinoIcons.paperplane_fill),
            ),
          ),
          const SliverFillRemaining(
            fillOverscroll: true,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CupertinoTextField(
                clipBehavior: Clip.none,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: BoxDecoration(border: null),
              ),
            ),
          )
        ],
      ),
    );
  }
}
