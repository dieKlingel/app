import 'dart:ffi';

import 'package:dieklingel_app/ui/views/video_renderer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_liblinphone/flutter_liblinphone.dart';
import 'package:flutter_liblinphone/flutter_liblinphone_wrapper.dart';

class AccountView extends StatefulWidget {
  AccountView({
    super.key,
    required this.core,
  });

  final Core core;

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _server = TextEditingController();

  final _renderer = VideoRendererController();
  bool state = false;

  void _onSave() {
    /*final address = Factory.instance.createAddress(
      "sip:${_username.text}@${_server.text}",
    );
    final authInfo = Factory.instance.createAuthInfo(
      username: _username.text,
      password: _password.text,
      domain: _server.text,
    );
    core.addAuthInfo(authInfo);

    final params = core.createAccountParams();
    params.setIdentityAddress(address);
    final account = core.createAccount(params);
    core.addAccount(account);*/

    print("account: ${widget.core.getGlobalState()}");
    flutterLinphoneWrapper.linphone_core_enable_video_preview(
        widget.core.cPtr, 1);
    /*flutterLinphoneWrapper.linphone_core_use_preview_window(
        widget.core.cPtr, 1);*/
    //flutterLinphoneWrapper.linphone_core_show_video(core.cPtr, 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SIP Account"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: "Username",
            ),
            controller: _username,
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: "Password",
            ),
            controller: _password,
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: "Server",
            ),
            controller: _server,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _onSave(),
            child: const Text("Save"),
          ),
          VideoRenderer(
            controller: _renderer,
            onNativeId: (id) {
              flutterLinphoneWrapper.linphone_core_set_native_preview_window_id(
                widget.core.cPtr,
                Pointer.fromAddress(id),
              );
            },
          ),
        ],
      ),
    );
  }
}
