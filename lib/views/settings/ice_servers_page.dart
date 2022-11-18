import 'package:dieklingel_app/components/ice_server.dart';
import 'package:dieklingel_app/views/settings/ice_server_config_page.dart';
import 'package:dieklingel_app/views/sheets/ice_server_config_sheet.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:objectdb/objectdb.dart';

import '../../database/objectdb_factory.dart';

class IceServersPage extends StatefulWidget {
  const IceServersPage({super.key});

  @override
  State<StatefulWidget> createState() => _IceServersPage();
}

class _IceServersPage extends State<IceServersPage> {
  Map<String, IceServer> _servers = {};
  ObjectDB? _database;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    _database = await ObjectDBFactory.named("ice_servers");
    List<Map<dynamic, dynamic>> result = await _database!.find({});
    Map<String, IceServer> servers = {};
    for (Map<dynamic, dynamic> document in result) {
      String id = document["_id"];
      IceServer server = IceServer.fromJson(document.cast<String, dynamic>());
      servers[id] = server;
    }
    setState(() {
      _servers = servers;
    });
  }

  Future<void> _insert(IceServer server) async {
    if (null == _database) return;
    ObjectId id = await _database!.insert(server.toJson());
    setState(() {
      _servers[id.hexString] = server;
    });
  }

  Future<void> _update(String id, IceServer server) async {
    if (null == _database) return;
    await _database!.update({"_id": id}, server.toJson());
    setState(() {
      _servers[id] = server;
    });
  }

  Future<void> _remove(String id) async {
    if (null == _database) return;
    await _database!.remove({"_id": id});
    setState(() {
      _servers.remove(id);
    });
  }

  void _onPlusBtnPressed() async {
    /* IceServer? result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const IceServerConfigPage(),
      ),
    );
    if (null == result) return;
    await _insert(result);*/
  }

  void _onListTilePressed(String id, IceServer server) async {
    IceServer? result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => IceServerConfigPage(configuration: server),
      ),
    );
    if (null == result) return;
    await _update(id, result);
  }

  Widget _listview() {
    List<MapEntry<String, IceServer>> entries = _servers.entries.toList();

    return SingleChildScrollView(
      clipBehavior: Clip.none,
      child: entries.isEmpty
          ? Container()
          : Padding(
              padding: const EdgeInsets.only(top: 20),
              child: CupertinoFormSection(
                children: List.generate(
                  entries.length,
                  (index) {
                    MapEntry<String, IceServer> entry = entries[index];

                    return Dismissible(
                      background: Container(
                        padding: const EdgeInsets.all(8),
                        alignment: Alignment.centerRight,
                        color: Colors.red,
                        child: const Icon(
                          CupertinoIcons.delete,
                          color: Colors.white,
                        ),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) => _remove(entry.key),
                      key: Key(entry.key),
                      child: CupertinoInkWell(
                        onTap: () => _onListTilePressed(
                          entry.key,
                          entry.value,
                        ),
                        child: CupertinoFormRow(
                          padding: const EdgeInsets.all(12),
                          prefix: Text(entry.value.urls),
                          child: const Icon(CupertinoIcons.forward),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("ICE Servers"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _onPlusBtnPressed,
          child: const Icon(
            CupertinoIcons.plus,
          ), //callIsActive ? null : ,
        ),
      ),
      child: SafeArea(
        child: _listview(),
      ),
    );
  }
}
