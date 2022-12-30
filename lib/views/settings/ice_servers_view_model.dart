import 'package:dieklingel_app/models/ice_server.dart';
import 'package:flutter/material.dart';

class IceServersViewModel extends ChangeNotifier {
  List<IceServer> _servers = [];

  List<IceServer> get servers => List.unmodifiable(_servers);

  void insert(IceServer server) async {
    /* if (_db == null) return;

    _servers.remove(server);
    _servers.add(server);

    int result = await _db!.update(
      {
        "uuid": server.uuid,
      },
      server.toMap(),
    );
    if (result < 1) {
      await _db!.insert(server.toMap());
    }
    notifyListeners(); */
  }

  void delete(IceServer server) async {
    /* if (_db == null) return;
    if (server.uuid == null) return;

    _servers.remove(server);
    await _db!.remove(
      {
        "uuid": server.uuid,
      },
    );

    notifyListeners(); */
  }
}
