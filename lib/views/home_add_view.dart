import 'dart:convert';

import 'package:dieklingel_app/blocs/home_add_view_bloc.dart';
import 'package:dieklingel_app/extensions/mqtt_uri.dart';
import 'package:dieklingel_app/states/home_add_state.dart';
import 'package:dieklingel_core_shared/flutter_shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/hive_home.dart';

class HomeAddView extends StatefulWidget {
  final HiveHome? home;

  const HomeAddView({super.key, this.home});

  @override
  State<StatefulWidget> createState() => _HomeAddView();
}

class _HomeAddView extends State<HomeAddView> {
  late final _name = TextEditingController(text: widget.home?.name);
  late final _server = TextEditingController(
    text: widget.home?.uri.toHostOnlyString(),
  );
  late final _username = TextEditingController(text: widget.home?.username);
  late final _password = TextEditingController(text: widget.home?.password);
  late final _channel = TextEditingController(text: widget.home?.uri.channel);
  late final _sign = TextEditingController(text: widget.home?.uri.section);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeAddViewBloc, HomeAddState>(
      listener: (context, state) {
        if (state is HomeAddSuccessfulState) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            leading: CupertinoButton(
                padding: EdgeInsets.zero,
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            middle: const Text("Home"),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                context.read<HomeAddViewBloc>().add(
                      HomeAddSubmit(
                        home: widget.home,
                        name: _name.text,
                        server: _server.text,
                        username: _username.text,
                        password: _password.text,
                        channel: _channel.text,
                        sign: _sign.text,
                      ),
                    );
              },
              child: const Text("Save"),
            ),
          ),
          backgroundColor: CupertinoColors.systemGroupedBackground,
          child: SafeArea(
            child: ListView(
              clipBehavior: Clip.none,
              children: [
                CupertinoFormSection.insetGrouped(
                  header: const Text("Configuration"),
                  children: [
                    CupertinoTextFormFieldRow(
                      prefix: const Text("Name"),
                      controller: _name,
                      validator: (value) => state is HomeAddFormErrorState
                          ? state.nameError
                          : null,
                      autovalidateMode: AutovalidateMode.always,
                    ),
                  ],
                ),
                CupertinoFormSection.insetGrouped(
                  header: const Text("Server"),
                  children: [
                    CupertinoTextFormFieldRow(
                      prefix: const Text("Server URL"),
                      controller: _server,
                      validator: (value) => state is HomeAddFormErrorState
                          ? state.serverError
                          : null,
                      autovalidateMode: AutovalidateMode.always,
                    ),
                    CupertinoTextFormFieldRow(
                      prefix: const Text("Username"),
                      controller: _username,
                    ),
                    CupertinoTextFormFieldRow(
                      prefix: const Text("Password"),
                      controller: _password,
                    ),
                  ],
                ),
                CupertinoFormSection.insetGrouped(
                  header: const Text("Channel"),
                  children: [
                    CupertinoTextFormFieldRow(
                      prefix: const Text("Channel Prefix"),
                      validator: (value) => state is HomeAddFormErrorState
                          ? state.channelError
                          : null,
                      autovalidateMode: AutovalidateMode.always,
                      controller: _channel,
                    ),
                    CupertinoTextFormFieldRow(
                      prefix: const Text("Sign"),
                      validator: (value) => state is HomeAddFormErrorState
                          ? state.signError
                          : null,
                      autovalidateMode: AutovalidateMode.always,
                      controller: _sign,
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

/* class HomeAddView extends StatefulWidget {
  final HiveHome? home;

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
  final TextEditingController _section = TextEditingController();

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
      _section.text = uri.fragment;
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
        "${serverUrl.scheme}://${serverUrl.authority}/${_channel.text}#${_section.text}",
      ),
    );

    HiveHome home = widget.home ?? HiveHome(name: _name.text, uri: uri);
    home.name = _name.text;
    home.uri = uri;
    home.username = _username.text;
    home.password = _password.text;
    home.save();

    Navigator.pop(context);

    Box settings = Hive.box("settings");
    String? token = settings.get("token", defaultValue: null);
    if (token == null) {
      return;
    }

    Map<String, dynamic> payload = {
      "token": token,
      "identifier": home.uri.section.isEmpty ? "default" : home.uri.section,
    };

    await GetIt.I<MqttClientBloc>().request(
      "request/apn/register/${const Uuid().v4()}",
      jsonEncode(payload),
      timeout: const Duration(seconds: 2),
    );
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

    RegExp sectionExp = RegExp(
      r'^([a-zA-Z]+)$',
    );
    valid = valid && sectionExp.hasMatch(_section.text);

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
                    CupertinoTextFormFieldRow(
                      prefix: const Text("Sign"),
                      placeholder: "default",
                      controller: _section,
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
}*/
