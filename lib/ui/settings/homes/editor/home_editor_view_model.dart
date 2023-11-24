import 'package:dieklingel_app/models/home.dart';
import 'package:dieklingel_app/repositories/home_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

class HomeEditorViewModel extends ChangeNotifier {
  final HomeRepository homeRepository;
  late final String _id;
  String _name;
  String _server;
  String _username;
  String _password;
  String _channel;
  bool _isLoading = false;

  HomeEditorViewModel(this.homeRepository, {Home? home})
      : _id = home?.id ?? const Uuid().v4(),
        _name = home?.name ?? "",
        _server = home == null
            ? ""
            : "${home.uri.scheme}://${home.uri.host}:${home.uri.port}",
        _username = home?.username ?? "",
        _password = home?.password ?? "",
        _channel = home == null ? "" : normalize("./${home.uri.path}");

  bool get isLoading {
    return _isLoading;
  }

  set name(String value) {
    _name = value;
    notifyListeners();
  }

  String get name => _name;

  set server(String value) {
    _server = value;
    notifyListeners();
  }

  String get server => _server;

  set username(String value) {
    _username = value;
    notifyListeners();
  }

  String get username => _username;

  set password(String value) {
    _password = value;
    notifyListeners();
  }

  String get password => _password;

  set channel(String value) {
    _channel = value;
    notifyListeners();
  }

  String get channel => _channel;

  Future<void> save() async {
    _isLoading = true;
    notifyListeners();

    Uri url = Uri.parse(_server);
    Uri uri = Uri.parse("${url.scheme}://${url.authority}/$_channel");

    // TODO: check connection
    await homeRepository.add(
      Home(
        id: _id,
        name: name,
        uri: uri,
        username: _username,
        password: _password,
      ),
    );

    _isLoading = false;
    notifyListeners();
  }
}
