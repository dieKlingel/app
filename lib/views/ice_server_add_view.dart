import 'package:dieklingel_core_shared/flutter_shared.dart';
import 'package:flutter/cupertino.dart';

class IceServerAddView extends StatefulWidget {
  final IceServer? server;

  const IceServerAddView({
    super.key,
    this.server,
  });

  @override
  State<IceServerAddView> createState() => _IceServerAddView();
}

class _IceServerAddView extends State<IceServerAddView> {
  final TextEditingController _urls = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _credential = TextEditingController();

  bool _valid = false;

  @override
  void initState() {
    super.initState();

    if (null != widget.server) {
      _urls.text = widget.server!.urls;
      _username.text = widget.server!.username;
      _credential.text = widget.server!.credential;
    }
  }

  void _save(BuildContext context) async {
    if (!_valid) {
      return;
    }
    IceServer iceServer = widget.server ?? IceServer(urls: _urls.text);
    iceServer.urls = _urls.text;
    iceServer.username = _username.text;
    iceServer.credential = _credential.text;
    // iceServer.save();

    Navigator.pop(context);
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
      navigationBar: CupertinoNavigationBar(
          middle: const Text("Stun/Turn Server"),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _valid
                ? () {
                    _save(context);
                  }
                : null,
            child: const Text("Save"),
          )),
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
                  controller: _urls,
                  onChanged: _validate,
                ),
                CupertinoTextFormFieldRow(
                  prefix: const Text("Username"),
                  placeholder: "Max",
                  controller: _username,
                ),
                CupertinoTextFormFieldRow(
                  prefix: const Text("Credential"),
                  controller: _credential,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
