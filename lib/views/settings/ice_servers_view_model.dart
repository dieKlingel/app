import 'package:dieklingel_app/models/ice_server.dart';
import 'package:flutter/material.dart';
import 'package:objectdb/objectdb.dart';

import '../../database/objectdb_factory.dart';

class IceServersViewModel extends ChangeNotifier {
  List<IceServer> _servers = [];
  ObjectDB? _db;

  IceServersViewModel() {
    _init();
  }

  void _init() async {
    _db = await ObjectDBFactory.named("iceservers");
    await _db!.remove({"uuid": null});
    List<Map<dynamic, dynamic>> result = await _db!.find({});
    /* _servers = result
        .map((e) => e.cast<String, dynamic>())
        .map((e) => IceServer.fromMap(e))
        .toList(); */
    notifyListeners();
  }

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
