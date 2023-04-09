import 'package:dieklingel_app/states/icer_server_add_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/ice_server_add_view_bloc.dart';
import '../models/hive_ice_server.dart';

class IceServerAddView extends StatefulWidget {
  final HiveIceServer? server;

  const IceServerAddView({
    super.key,
    this.server,
  });

  @override
  State<IceServerAddView> createState() => _IceServerAddView();
}

class _IceServerAddView extends State<IceServerAddView> {
  late final TextEditingController _urls = TextEditingController(
    text: widget.server?.urls,
  );
  late final TextEditingController _username = TextEditingController(
    text: widget.server?.username,
  );
  late final TextEditingController _credential = TextEditingController(
    text: widget.server?.credential,
  );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<IceServerAddViewBloc, IceServerAddState>(
      listener: (context, state) {
        if (state is IceServerAddSuccessfulState) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return CupertinoPageScaffold(
          backgroundColor: CupertinoColors.systemGroupedBackground,
          navigationBar: CupertinoNavigationBar(
              leading: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              middle: const Text("Stun/Turn Server"),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  context.read<IceServerAddViewBloc>().add(
                        IceServerAddSubmit(
                          server: widget.server,
                          urls: _urls.text,
                          username: _username.text,
                          credential: _credential.text,
                        ),
                      );
                },
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
                      validator: (value) => state is IceServerAddFormErrorState
                          ? state.urlsError
                          : null,
                      autovalidateMode: AutovalidateMode.always,
                    ),
                    CupertinoTextFormFieldRow(
                      prefix: const Text("Username"),
                      placeholder: "Max",
                      controller: _username,
                      validator: (value) => state is IceServerAddFormErrorState
                          ? state.usernameError
                          : null,
                      autovalidateMode: AutovalidateMode.always,
                    ),
                    CupertinoTextFormFieldRow(
                      prefix: const Text("Credential"),
                      controller: _credential,
                      validator: (value) => state is IceServerAddFormErrorState
                          ? state.credentialError
                          : null,
                      autovalidateMode: AutovalidateMode.always,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
