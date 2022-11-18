import 'package:dieklingel_app/components/ice_server.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

class IceServerConfigSheet extends StatefulWidget {
  final IceServer? server;

  const IceServerConfigSheet({super.key, this.server});

  @override
  State<IceServerConfigSheet> createState() => _IceServerConfigSheet();
}

class _IceServerConfigSheet extends State<IceServerConfigSheet> {
  final TextEditingController urls = TextEditingController();
  final TextEditingController username = TextEditingController();
  final TextEditingController credential = TextEditingController();

  bool _valid = false;

  @override
  void initState() {
    if (widget.server != null) {
      urls.text = widget.server!.urls;
      username.text = widget.server!.username;
      credential.text = widget.server!.credential;
    }
    super.initState();
  }

  void _onSaveBtnPressed() {
    IceServer server = IceServer(
      uuid: widget.server?.uuid ?? const Uuid().v4(),
      urls: urls.text,
      username: username.text,
      credential: credential.text,
    );

    Navigator.of(context).pop(server);
  }

  void _validate(String _) {
    // match for stun:example.com:12345
    // or turn:example.com:12345
    RegExp exp = RegExp(
      r'(stun|turn):(?:[A-Za-z0-9-]+\.)+[A-Za-z0-9]{2,3}:\d{1,5}$',
    );
    bool valid = exp.hasMatch(urls.text);

    setState(() {
      _valid = valid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text("ICE"),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _valid ? _onSaveBtnPressed : null,
              child: const Text("Save"),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
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
                      onChanged: _validate,
                    ),
                    CupertinoTextFormFieldRow(
                      prefix: const Text("Credential"),
                      controller: credential,
                      obscureText: true,
                      onChanged: _validate,
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
