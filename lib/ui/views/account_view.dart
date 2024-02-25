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
  TransportType _transport = TransportType.tls;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    final account = widget.core.getDefaultAccount();
    if (account != null) {
      _username.text = account.getParams().getIdentityAddress().getUsername();
      _password.text = account.getParams().getIdentityAddress().getPassword();
      _server.text = account.getParams().getDomain();
      _transport = account.getParams().getTransport();
    }

    super.initState();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    widget.core.clearAccounts();
    widget.core.clearAllAuthInfo();

    final address = Factory.instance.createAddress(
      "sip:${_username.text}:${_password.text}@${_server.text}",
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
    params.setTransport(_transport);
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Username",
              ),
              validator: (text) {
                if (text?.isEmpty ?? false) {
                  return "Please enter a username";
                }
                return null;
              },
              controller: _username,
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Password",
              ),
              obscureText: true,
              validator: (text) {
                if (text?.isEmpty ?? false) {
                  return "Please enter a password";
                }
                return null;
              },
              controller: _password,
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Server",
              ),
              controller: _server,
              validator: (text) {
                if (text?.isEmpty ?? false) {
                  return "Please enter a server";
                }
                return null;
              },
            ),
            DropdownButtonFormField(
                value: _transport,
                items: const [
                  DropdownMenuItem(
                    value: TransportType.tls,
                    child: Text("TLS (recommended)"),
                  ),
                  DropdownMenuItem(
                    value: TransportType.tcp,
                    child: Text("TCP"),
                  ),
                  DropdownMenuItem(
                    value: TransportType.udp,
                    child: Text("UDP"),
                  ),
                  DropdownMenuItem(
                    value: TransportType.dtls,
                    child: Text("DTLS"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _transport = value!;
                  });
                }),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _onSave,
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _server.dispose();

    super.dispose();
  }
}
