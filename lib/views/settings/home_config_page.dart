import 'package:dieklingel_app/components/home.dart';
import 'package:dieklingel_app/rtc/mqtt_rtc_description.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class HomeConfigPage extends StatefulWidget {
  final Home? configuration;
  const HomeConfigPage({super.key, this.configuration});

  @override
  State<HomeConfigPage> createState() => _HomeConfigPage();
}

class _HomeConfigPage extends State<HomeConfigPage> {
  final TextEditingController description = TextEditingController();
  final TextEditingController url = TextEditingController();
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController channelPrefix = TextEditingController();

  bool _valid = false;

  @override
  void initState() {
    super.initState();

    if (null != widget.configuration) {
      Uri uri = widget.configuration!.description.toUri();
      description.text = widget.configuration!.name;
      url.text = "${uri.scheme}://${uri.authority}/";
      username.text = widget.configuration!.username ?? "";
      password.text = widget.configuration!.password ?? "";
      channelPrefix.text = uri.path.substring(1);
    }
  }

  void _addConfiguration(BuildContext context) {
    Uri serverUrl = Uri.parse(url.text);
    Uri uri = Uri.parse(
      "${serverUrl.scheme}://${serverUrl.authority}/${channelPrefix.text}",
    );

    MqttRtcDescription mqttRtcDescription = MqttRtcDescription.parse(uri);

    Home home = Home(
      name: description.text,
      description: mqttRtcDescription,
      username: username.text.isEmpty ? null : username.text,
      password: password.text.isEmpty ? null : password.text,
    );
    Navigator.of(context).pop(home);
  }

  void _validate() {
    bool valid = description.text.isNotEmpty;

    RegExp serverExp = RegExp(
      r'^(mqtt|mqtts|ws|wss):\/\/(?:[A-Za-z0-9]+\.)+[A-Za-z0-9]{2,3}:\d{1,5}(\/?)$',
    );
    valid = valid && serverExp.hasMatch(url.text);

    RegExp channelExp = RegExp(
      r'^(([a-z]+)([a-z\.+])([a-z]+)\/)+$',
    );
    valid = valid && channelExp.hasMatch(channelPrefix.text);

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
              header: const Text("Configuration"),
              children: [
                CupertinoTextFormFieldRow(
                  prefix: const Text("Description"),
                  placeholder: "My Home",
                  controller: description,
                  onChanged: (value) => _validate(),
                ),
              ],
            ),
            CupertinoFormSection.insetGrouped(
              header: const Text("Server"),
              children: [
                CupertinoTextFormFieldRow(
                  prefix: const Text("Server Url"),
                  placeholder: kIsWeb
                      ? "wss://dieklingel.com:9002/"
                      : "mqtt://dieklingel.com:1883/",
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
                  controller: channelPrefix,
                  onChanged: (value) => _validate(),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: CupertinoButton.filled(
                onPressed: _valid
                    ? () {
                        _addConfiguration(context);
                      }
                    : null,
                child: const Text("Save"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
