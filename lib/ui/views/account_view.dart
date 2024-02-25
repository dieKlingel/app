import 'package:flutter/material.dart';
import 'package:flutter_liblinphone/flutter_liblinphone.dart';

class AccountView extends StatefulWidget {
  const AccountView({
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

  void _onSave() {
    widget.core.clearAccounts();
    widget.core.clearAllAuthInfo();

    final address = Factory.instance.createAddress(
      "sip:${_username.text}@${_server.text}",
    );
    final authInfo = Factory.instance.createAuthInfo(
      username: _username.text,
      password: _password.text,
      domain: _server.text,
    );
    widget.core.addAuthInfo(authInfo);
    final params = widget.core.createAccountParams();
    params.setIdentityAddress(address);
    params.setServerAddress("sip:${_server.text}");
    params.setTransport(TransportType.tls);
    params.setRegisterEnabled(true);
    final account = widget.core.createAccount(params);
    widget.core.addAccount(account);
    widget.core.setDefaultAccount(account);

    Navigator.pop(context);
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
            obscureText: true,
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
        ],
      ),
    );
  }
}
