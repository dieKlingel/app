import 'dart:js';

import 'package:dieklingel_app/components/connection_configuration.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConnectionConfigurationView extends StatelessWidget {
  ConnectionConfigurationView({Key? key}) : super(key: key);
  final TextEditingController description_controller = TextEditingController();
  final TextEditingController server_url_controller = TextEditingController();
  final TextEditingController username_controller = TextEditingController();
  final TextEditingController password_controller = TextEditingController();
  final TextEditingController channel_prefix_controller =
      TextEditingController();
  late final BuildContext _buildContext;

  void addConfiguration() async {
    if (description_controller.text.isEmpty) {
      print("add description");
      return;
    }
    if (server_url_controller.text.isEmpty) {
      print("add url");
      return;
    }
    ConnectionConfiguration configuration = ConnectionConfiguration(
      description_controller.text,
      server_url_controller.text,
      channel_prefix_controller.text,
      username:
          username_controller.text.isEmpty ? null : username_controller.text,
      password:
          password_controller.text.isEmpty ? null : password_controller.text,
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("configuration", configuration.toString());
    Navigator.pop(_buildContext);
  }

  @override
  Widget build(BuildContext context) {
    _buildContext = context;
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text("dieKlingel"),
        automaticallyImplyLeading: true,
      ),
      child: SafeArea(
        bottom: false,
        child: Form(
          child: ListView(
            children: [
              CupertinoFormSection.insetGrouped(
                header: const Text("Configuration"),
                children: [
                  CupertinoTextFormFieldRow(
                    prefix: const Text("Description"),
                    placeholder: "Description",
                    controller: description_controller,
                  ),
                ],
              ),
              CupertinoFormSection.insetGrouped(
                header: const Text("Server"),
                children: [
                  CupertinoTextFormFieldRow(
                    prefix: const Text("Server Url"),
                    placeholder: "mqtt://dieklingel.com/",
                    controller: server_url_controller,
                  ),
                  CupertinoTextFormFieldRow(
                    prefix: const Text("Username"),
                    placeholder: "Max",
                    controller: username_controller,
                  ),
                  CupertinoTextFormFieldRow(
                    prefix: const Text("Password"),
                    obscureText: true,
                    controller: password_controller,
                  ),
                ],
              ),
              CupertinoFormSection.insetGrouped(
                header: const Text("Channel"),
                children: [
                  CupertinoTextFormFieldRow(
                    prefix: const Text("Channel Prefix"),
                    placeholder: "com.dieklingel/main-entry/",
                    controller: channel_prefix_controller,
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: CupertinoButton.filled(
                  child: const Text("add"),
                  onPressed: () {
                    addConfiguration();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
