import 'package:dieklingel_app/components/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

import '../../rtc/mqtt_rtc_description.dart';

class HomeConfigSheet extends StatefulWidget {
  final Home? home;

  const HomeConfigSheet({super.key, this.home});

  @override
  State<HomeConfigSheet> createState() => _HomeConfigSheet();
}

class _HomeConfigSheet extends State<HomeConfigSheet> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController url = TextEditingController();
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController channel = TextEditingController();

  bool _valid = false;

  @override
  void initState() {
    if (null != widget.home) {
      Uri uri = widget.home!.description.toUri();
      _name.text = widget.home!.name;
      url.text = "${uri.scheme}://${uri.authority}/";
      username.text = widget.home!.username ?? "";
      password.text = widget.home!.password ?? "";
      channel.text = uri.path.substring(1);
    }
    super.initState();
  }

  void _onSaveBtnPressed() {
    Uri serverUrl = Uri.parse(url.text);
    Uri uri = Uri.parse(
      "${serverUrl.scheme}://${serverUrl.authority}/${channel.text}",
    );

    MqttRtcDescription mqttRtcDescription = MqttRtcDescription.parse(uri);

    Home home = Home(
      uuid: widget.home?.uuid ?? const Uuid().v4(),
      name: _name.text,
      description: mqttRtcDescription,
      username: username.text.isEmpty ? null : username.text,
      password: password.text.isEmpty ? null : password.text,
    );

    Navigator.of(context).pop(home);
  }

  void _validate() {
    bool valid = _name.text.isNotEmpty;

    RegExp serverExp = RegExp(
      r'^(mqtt|mqtts|ws|wss):\/\/(?:[A-Za-z0-9]+\.)+[A-Za-z0-9]{2,3}:\d{1,5}(\/?)$',
    );
    valid = valid && serverExp.hasMatch(url.text);

    RegExp channelExp = RegExp(
      r'^(([a-z]+)([a-z\.+])([a-z]+)\/)+$',
    );
    valid = valid && channelExp.hasMatch(channel.text);

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
              onPressed: _valid ? _onSaveBtnPressed : null,
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
                      controller: url,
                      onChanged: (value) => _validate(),
                    ),
                    CupertinoTextFormFieldRow(
                      prefix: const Text("Username"),
                      placeholder: "Max",
                      controller: username,
                      onChanged: (value) => _validate(),
                    ),
                    CupertinoTextFormFieldRow(
                      prefix: const Text("Password"),
                      obscureText: true,
                      controller: password,
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
                      controller: channel,
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
