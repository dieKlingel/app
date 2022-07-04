import 'dart:convert';

import 'package:dieklingel_app/components/connection_configuration.dart';
import 'package:dieklingel_app/views/home_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/simple_alert_dialog.dart';

class ConnectionConfigurationView extends StatelessWidget {
  ConnectionConfigurationView({
    Key? key,
    this.configuration,
  }) : super(key: key) {
    //descriptionIsEditable = (null == configuration);
    descriptionController.text = configuration?.description ?? "";
    serverUrlController.text = configuration?.url ?? "";
    usernameController.text = configuration?.username ?? "";
    passwordController.text = configuration?.password ?? "";
    channelPrefixController.text = configuration?.channelPrefix ?? "";
  }

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController serverUrlController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController channelPrefixController = TextEditingController();
  ConnectionConfiguration? configuration;

  void addConfiguration(BuildContext context) async {
    if (descriptionController.text.isEmpty) {
      await displaySimpleAlertDialog(
        context,
        const Text("Error"),
        const Text("Please enter a description"),
      );
      return;
    }
    if (serverUrlController.text.isEmpty) {
      await displaySimpleAlertDialog(
        context,
        const Text("Error"),
        const Text("Please enter a server url"),
      );
      return;
    }
    configuration ??= ConnectionConfiguration();
    configuration!.description = descriptionController.text;
    configuration!.url = serverUrlController.text;
    configuration!.channelPrefix = channelPrefixController.text.isEmpty
        ? null
        : channelPrefixController.text;
    configuration!.username =
        usernameController.text.isEmpty ? null : usernameController.text;
    configuration!.password =
        passwordController.text.isEmpty ? null : passwordController.text;

    List<ConnectionConfiguration> configurations = await getConfigurations();
    if (configurations.contains(configuration)) {
      int index = configurations.indexOf(configuration!);
      configurations.remove(configuration!);
      configurations.insert(index, configuration!);
    } else {
      configurations.add(configuration!);
    }
    await setConfigurations(configurations);

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(
          builder: (context) => const HomeView(),
        ),
      );
    }
  }

  Future<List<ConnectionConfiguration>> getConfigurations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> rawConnectionConfig = prefs.getStringList("configuration") ??
        List<String>.empty(growable: true);
    List<ConnectionConfiguration> connectionConfig = rawConnectionConfig
        .map((config) => ConnectionConfiguration.fromJson(jsonDecode(config)))
        .toList(growable: true);
    return connectionConfig;
  }

  Future<void> setConfigurations(
    List<ConnectionConfiguration> configuration,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> rawConnectionConfig =
        configuration.map((config) => config.toString()).toList();
    prefs.setStringList("configuration", rawConnectionConfig);
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
                  placeholder: "Description",
                  controller: descriptionController,
                ),
              ],
            ),
            CupertinoFormSection.insetGrouped(
              header: const Text("Server"),
              children: [
                CupertinoTextFormFieldRow(
                  prefix: const Text("Server Url"),
                  placeholder: "mqtt://dieklingel.com/",
                  controller: serverUrlController,
                ),
                CupertinoTextFormFieldRow(
                  prefix: const Text("Username"),
                  placeholder: "Max",
                  controller: usernameController,
                ),
                CupertinoTextFormFieldRow(
                  prefix: const Text("Password"),
                  obscureText: true,
                  controller: passwordController,
                ),
              ],
            ),
            CupertinoFormSection.insetGrouped(
              header: const Text("Channel"),
              children: [
                CupertinoTextFormFieldRow(
                  prefix: const Text("Channel Prefix"),
                  placeholder: "com.dieklingel/main-entry/",
                  controller: channelPrefixController,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: CupertinoButton.filled(
                child: const Text("Speichern"),
                onPressed: () {
                  addConfiguration(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
