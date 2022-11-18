import 'package:flutter/cupertino.dart';

class IceServerConfigSheet extends StatefulWidget {
  const IceServerConfigSheet({super.key});

  @override
  State<IceServerConfigSheet> createState() => _IceServerConfigSheet();
}

class _IceServerConfigSheet extends State<IceServerConfigSheet> {
  final TextEditingController urls = TextEditingController();
  final TextEditingController username = TextEditingController();
  final TextEditingController credential = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              CupertinoButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              CupertinoButton(
                child: const Text("Save"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          ListView(
            shrinkWrap: true,
            children: [
              CupertinoFormSection.insetGrouped(
                header: const Text("Stun/Turn"),
                children: [
                  CupertinoTextFormFieldRow(
                    prefix: const Text("Url"),
                    placeholder: "stun:stun.dieklingel.com:3478",
                    controller: urls,
                    //onChanged: _validate,
                  ),
                  CupertinoTextFormFieldRow(
                    prefix: const Text("Username"),
                    placeholder: "Max",
                    controller: username,
                  ),
                  CupertinoTextFormFieldRow(
                    prefix: const Text("Credential"),
                    controller: credential,
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
