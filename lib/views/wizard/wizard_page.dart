import 'package:dieklingel_app/components/preferences.dart';
import 'package:dieklingel_app/database/objectdb_factory.dart';
import 'package:dieklingel_app/rtc/mqtt_rtc_description.dart';
import 'package:dieklingel_app/views/tabbar_page.dart';
import 'package:dieklingel_app/views/wizard/input_view.dart';
import 'package:dieklingel_app/views/wizard/validator.dart';
import 'package:dieklingel_app/views/wizard/welcome_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:objectdb/objectdb.dart';
import 'package:provider/provider.dart';

import '../../components/home.dart';

class WizardPage extends StatefulWidget {
  const WizardPage({super.key});

  @override
  State<WizardPage> createState() => _WizardPage();
}

class _WizardPage extends State<WizardPage> {
  final PageController _controller = PageController();
  final Validator<TextEditingController> _uri = Validator(
    value: TextEditingController(),
    validator: (value) {
      RegExp exp = RegExp(
        r'^(mqtt|mqtts|ws|wss):\/\/(?:[A-Za-z0-9]+\.)+[A-Za-z0-9]{2,3}:\d{1,5}(\/?)$',
      );
      return exp.hasMatch(value.text);
    },
  );

  final Validator<TextEditingController> _username = Validator(
    value: TextEditingController(),
    validator: (value) => value.text.isNotEmpty,
  );

  final Validator<TextEditingController> _password = Validator(
    value: TextEditingController(),
    validator: (value) => value.text.isNotEmpty,
  );

  final Validator<TextEditingController> _channel = Validator(
    value: TextEditingController(),
    validator: (value) {
      RegExp exp = RegExp(
        r'^(([a-z]+)([a-z\.+])([a-z]+)\/)+$',
      );
      return exp.hasMatch(value.text);
    },
  );

  @override
  void initState() {
    super.initState();
    _uri.value.addListener(() => setState(() {}));
    _username.value.addListener(() => setState(() {}));
    _password.value.addListener(() => setState(() {}));
    _channel.value.addListener(() => setState(() {}));
  }

  void _onFinishedBtnPressed() async {
    Preferences preferences = context.read<Preferences>();
    Uri serverUrl = Uri.parse(_uri.value.text);
    Uri uri = Uri.parse(
      "${serverUrl.scheme}://${serverUrl.authority}/${_channel.value.text}",
    );

    MqttRtcDescription mqttRtcDescription = MqttRtcDescription.parse(uri);

    Home home = Home(
      name: "Default",
      description: mqttRtcDescription,
      username: _username.value.text.isEmpty ? null : _username.value.text,
      password: _password.value.text.isEmpty ? null : _password.value.text,
    );

    ObjectDB database = await ObjectDBFactory.named("homes");
    //await database.remove({});
    ObjectId id = await database.insert(home.toMap());
    preferences.setString("default_home_id", id.hexString);
    database.cleanup();
    database.close();
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
        builder: ((context) => const TabbarPage()),
      ),
    );
  }

  int _length() {
    if (!_uri.isValid()) return 2;
    if (_username.isValid() && !_password.isValid()) return 4;
    if (!_channel.isValid()) return _pages().length - 1;
    return _pages().length;
  }

  Widget background({
    required Widget child,
  }) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            colors: [Colors.red, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
      ),
      child: child,
    );
  }

  Widget _textinput(
    Validator<TextEditingController> validator,
    String placeholder, {
    bool obsure = false,
  }) {
    return CupertinoTextField(
      controller: validator.value,
      placeholder: placeholder,
      style: const TextStyle(color: Colors.white),
      padding: const EdgeInsets.all(8.0),
      obscureText: obsure,
      suffix: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          CupertinoIcons.check_mark_circled,
          color: validator.isValid() ? Colors.green : Colors.black26,
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  List<Widget> _pages() {
    return [
      const WelcomeView(),
      InputView(
        text: "first we need the uri of your mqtt broker.",
        next: "swipe right, for credentials",
        valid: _uri.isValid(),
        child: _textinput(_uri, "mqtts://dieklingel.com:1883/"),
      ),
      InputView(
        text:
            "now we neeed your mqtt username. And yes you should configure yor broker to use authentication.",
        next: "swipe right, leave blank to skip",
        valid: true,
        child: _textinput(_username, "username"),
      ),
      _username.isValid()
          ? InputView(
              text: "now we need your mqtt password",
              next: "swipe rigth, to channel",
              valid: _password.isValid(),
              child: _textinput(_password, "password", obsure: true),
            )
          : null,
      InputView(
        text: "to connect we need your default mqtt channel.",
        next: "swipe right finish",
        valid: _channel.isValid(),
        child: _textinput(_channel, "com.dieklingel/mychannel/"),
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.all(30.0),
            child: Text(
              "you did it. Press finish, to set up the app!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          CupertinoButton(
            borderRadius: BorderRadius.circular(20),
            color: Colors.orange,
            onPressed: _onFinishedBtnPressed,
            child: const Text("finish"),
          ),
        ],
      )
    ].whereType<Widget>().toList();
  }

  @override
  Widget build(BuildContext context) {
    return background(
      child: CupertinoPageScaffold(
        backgroundColor: Colors.transparent,
        child: PageView(
          controller: _controller,
          children: _pages().sublist(0, _length()),
        ),
      ),
    );
  }
}
