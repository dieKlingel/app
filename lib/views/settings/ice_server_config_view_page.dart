import 'package:flutter/cupertino.dart';

import '../../components/ice_server.dart';

class IceServerConfigViewPage extends StatefulWidget {
  final IceServer? configuration;

  const IceServerConfigViewPage({
    super.key,
    this.configuration,
  });

  @override
  State<IceServerConfigViewPage> createState() => _IceServerConfigViewPage();
}

class _IceServerConfigViewPage extends State<IceServerConfigViewPage> {
  final TextEditingController urls = TextEditingController();
  final TextEditingController username = TextEditingController();
  final TextEditingController credential = TextEditingController();

  bool _valid = false;

  @override
  void initState() {
    super.initState();

    if (null != widget.configuration) {
      urls.text = widget.configuration!.urls;
      username.text = widget.configuration!.username;
      credential.text = widget.configuration!.credential;
    }
  }

  void _addConfiguration(BuildContext context) async {
    IceServer iceServer = IceServer(
      urls: urls.text,
      username: username.text,
      credential: credential.text,
    );

    Navigator.of(context).pop(iceServer);
  }

  void _validate(String value) {
    // match for stun:example.com:12345
    // or turn:example.com:12345
    RegExp exp = RegExp(
      r'(stun|turn):(?:[A-Za-z0-9-]+\.)+[A-Za-z0-9]{2,3}:\d{1,5}$',
    );
    bool valid = exp.hasMatch(value);

    setState(() {
      _valid = valid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text("dieKlingel"),
      ),
      child: SafeArea(
        bottom: false,
        child: ListView(
          children: [
            CupertinoFormSection.insetGrouped(
              header: const Text("Stun/Turn"),
              children: [
                CupertinoTextFormFieldRow(
                  prefix: const Text("Url"),
                  placeholder: "stun:stun.dieklingel.com:3478",
                  controller: urls,
                  onChanged: _validate,
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
            Padding(
              padding: const EdgeInsets.all(20),
              child: CupertinoButton.filled(
                child: const Text("Save"),
                onPressed: _valid
                    ? () {
                        _addConfiguration(context);
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
