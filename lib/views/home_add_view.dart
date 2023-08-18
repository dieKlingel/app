import 'package:dieklingel_app/blocs/home_add_view_bloc.dart';
import 'package:dieklingel_app/states/home_add_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;
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
    text: widget.home == null
        ? null
        : "${widget.home!.uri.scheme}://${widget.home!.uri.host}:${widget.home!.uri.port}",
  );
  late final _username = TextEditingController(text: widget.home?.username);
  late final _password = TextEditingController(text: widget.home?.password);
  late final _channel = TextEditingController(
    text: widget.home == null
        ? null
        : path.normalize("./${widget.home!.uri.path}"),
  );
  late final _sign = TextEditingController(text: widget.home?.uri.fragment);

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
                child: const Text("Cancel"),
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
                      obscureText: true,
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
