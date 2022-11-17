import 'package:flutter/cupertino.dart';

class AddHomePage extends StatefulWidget {
  const AddHomePage({super.key});

  @override
  State<AddHomePage> createState() => _AddHomePage();
}

class _AddHomePage extends State<AddHomePage> {
  final TextEditingController description = TextEditingController();
  final TextEditingController url = TextEditingController();
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController channel = TextEditingController();

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
                header: const Text("Configuration"),
                children: [
                  CupertinoTextFormFieldRow(
                    prefix: const Text("Description"),
                    placeholder: "My Home",
                    controller: description,
                    //onChanged: (value) => _validate(),
                  ),
                ],
              ),
              CupertinoFormSection.insetGrouped(
                header: const Text("Server"),
                children: [
                  CupertinoTextFormFieldRow(
                    prefix: const Text("Server Url"),
                    placeholder: "mqtt://dieklingel.com:1883/",
                    controller: url,
                    //onChanged: (value) => _validate(),
                  ),
                  CupertinoTextFormFieldRow(
                    prefix: const Text("Username"),
                    placeholder: "Max",
                    controller: username,
                    //onChanged: (value) => _validate(),
                  ),
                  CupertinoTextFormFieldRow(
                    prefix: const Text("Password"),
                    obscureText: true,
                    controller: password,
                    //onChanged: (value) => _validate(),
                  ),
                ],
              ),
              CupertinoFormSection.insetGrouped(
                header: const Text("Channel"),
                children: [
                  CupertinoTextFormFieldRow(
                    prefix: const Text("Channel Prefix"),
                    placeholder: "com.dieklingel/name/main/",
                    controller: channel,
                    //onChanged: (value) => _validate(),
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
