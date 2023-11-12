import 'package:dieklingel_app/ui/view_models/outgoing_call_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OutgoingCallView extends StatelessWidget {
  const OutgoingCallView({super.key});

  @override
  Widget build(BuildContext context) {
    final callee = context.select<OutgoingCallViewModel, String>(
      (value) => value.home.name,
    );

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.lightBackgroundGray,
      child: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(56),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text(
                    callee,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    "outgoing call...",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
              CupertinoButton(
                color: Colors.red,
                padding: EdgeInsets.zero,
                minSize: kMinInteractiveDimensionCupertino * 1.2,
                borderRadius: BorderRadius.circular(999),
                child: const Icon(
                  CupertinoIcons.xmark,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
