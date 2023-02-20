/* import 'package:flutter/cupertino.dart';

import '../models/home.dart';
import '../models/mqtt_uri.dart';

class HomeAddView extends StatefulWidget {
  final Home? home;

  const HomeAddView({super.key, this.home});

  @override
  State<HomeAddView> createState() => _HomeConfigSheet();
}

class _HomeConfigSheet extends State<HomeAddView> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _url = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _channel = TextEditingController();

  bool _valid = false;

  @override
  void initState() {
    if (null != widget.home) {
      Uri uri = widget.home!.uri.toUri();
      _name.text = widget.home!.name;
      _url.text = "${uri.scheme}://${uri.authority}/";
      _username.text = widget.home!.username ?? "";
      _password.text = widget.home!.password ?? "";
      _channel.text = uri.path.substring(1);
    }
    super.initState();
  }

  void _save(BuildContext context) async {
    if (!_valid) {
      return;
    }

    Uri serverUrl = Uri.parse(_url.text);
    MqttUri uri = MqttUri.fromUri(
      Uri.parse(
        "${serverUrl.scheme}://${serverUrl.authority}/${_channel.text}",
      ),
    );

    Home home = widget.home ?? Home(name: _name.text, uri: uri);
    home.name = _name.text;
    home.uri = uri;
    home.username = _username.text;
    home.password = _password.text;
    home.save();

    Navigator.pop(context);
  }

  void _validate() {
    bool valid = _name.text.isNotEmpty;

    RegExp serverExp = RegExp(
      r'^(mqtt|mqtts|ws|wss):\/\/(?:[A-Za-z0-9]+\.)+[A-Za-z0-9]{2,3}:\d{1,5}(\/?)$',
    );
    valid = valid && serverExp.hasMatch(_url.text);

    RegExp channelExp = RegExp(
      r'^(([a-z]+)([a-z\.+])([a-z]+)\/)+$',
    );
    valid = valid && channelExp.hasMatch(_channel.text);

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
            largeTitle: const Text("Home"),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _valid
                  ? () {
                      _save(context);
                    }
                  : null,
              child: const Text("Save"),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                CupertinoFormSection.insetGrouped(
                  header: const Text("Configuration"),
                  children: [
                    CupertinoTextFormFieldRow(
                      prefix: const Text("Description"),
                      placeholder: "My Home",
                      controller: _name,
                      onChanged: (value) => _validate(),
                    ),
                  ],
                ),
                CupertinoFormSection.insetGrouped(
                  header: const Text("Server"),
                  children: [
                    CupertinoTextFormFieldRow(
                      prefix: const Text("Server Url"),
                      placeholder: "mqtt://dieklingel.com:1883/",
                      controller: _url,
                      onChanged: (value) => _validate(),
                    ),
                    CupertinoTextFormFieldRow(
                      prefix: const Text("Username"),
                      placeholder: "Max",
                      controller: _username,
                      onChanged: (value) => _validate(),
                    ),
                    CupertinoTextFormFieldRow(
                      prefix: const Text("Password"),
                      obscureText: true,
                      controller: _password,
                      onChanged: (value) => _validate(),
                    ),
                  ],
                ),
                CupertinoFormSection.insetGrouped(
                  header: const Text("Channel"),
                  children: [
                    CupertinoTextFormFieldRow(
                      prefix: const Text("Channel Prefix"),
                      placeholder: "com.dieklingel/name/main/",
                      controller: _channel,
                      onChanged: (value) => _validate(),
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
*/