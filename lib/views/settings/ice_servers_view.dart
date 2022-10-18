import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:objectdb/objectdb.dart';

import 'ice_server_config_view_page.dart';
import '../../components/ice_server.dart';
import '../../database/objectdb_factory.dart';

class IceServersView extends StatefulWidget {
  final Stream<IceServer>? insert;

  const IceServersView({super.key, this.insert});

  @override
  State<IceServersView> createState() => _IceServersView();
}

class _IceServersView extends State<IceServersView> {
  late final StreamSubscription<IceServer>? _subscription;
  Map<String, IceServer> _servers = {};
  ObjectDB? _database;

  BorderSide _listViewBorderSide(BuildContext context) => BorderSide(
        color: const CupertinoDynamicColor.withBrightness(
          color: CupertinoColors.lightBackgroundGray,
          darkColor: CupertinoColors.secondaryLabel,
        ).resolveFrom(context),
      );

  TextStyle _listViewTextStyle(BuildContext context) => TextStyle(
        color: const CupertinoDynamicColor.withBrightness(
          color: CupertinoColors.black,
          darkColor: CupertinoColors.white,
        ).resolveFrom(context),
      );

  @override
  void initState() {
    super.initState();
    _subscription = widget.insert?.listen((event) {
      _insert(event);
    });
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

  void _insert(IceServer server) async {
    if (_database == null) return;
    ObjectId id = await _database!.insert(server.toJson());
    setState(() {
      _servers[id.hexString] = server;
    });
  }

  void _update(String id, IceServer server) async {
    if (_database == null) return;
    _database!.update({"_id": id}, server.toJson());
    setState(() {
      _servers[id] = server;
    });
  }

  void _remove(String id) {
    if (_database == null) return;
    _database!.remove({"_id": id});
    setState(() {
      _servers.remove(id);
    });
  }

  Future<void> _onModifyBtnPressed(MapEntry<String, IceServer> entry) async {
    IceServer? server = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (BuildContext context) => IceServerConfigViewPage(
          configuration: entry.value,
        ),
      ),
    );
    if (null == server) return;
    _update(entry.key, server);
  }

  @override
  Widget build(BuildContext context) {
    List<MapEntry<String, IceServer>> servers = _servers.entries.toList();

    return ListView.builder(
      itemCount: servers.length,
      itemBuilder: (BuildContext context, int index) {
        MapEntry<String, IceServer> entry = servers.elementAt(index);
        return Container(
          decoration: BoxDecoration(
            border: Border(
              top: index == 0 ? _listViewBorderSide(context) : BorderSide.none,
              bottom: _listViewBorderSide(context),
            ),
          ),
          child: Dismissible(
            background: Container(
              color: Colors.red,
              child: const Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  CupertinoIcons.delete_solid,
                  color: Colors.white,
                ),
              ),
            ),
            key: Key(entry.key),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 00, 22),
                    child: Text(
                      entry.value.urls, //configuration.urls,
                      overflow: TextOverflow.ellipsis,
                      style: _listViewTextStyle(context),
                    ),
                  ),
                ),
                CupertinoButton(
                  child: Icon(
                    CupertinoIcons.forward,
                    color: Colors.grey.shade500,
                  ),
                  onPressed: () => _onModifyBtnPressed(entry),
                ),
              ],
            ),
            confirmDismiss: (direction) async => _servers.length > 1,
            onDismissed: (DismissDirection direction) async {
              _remove(entry.key);
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _database?.close();
    _subscription?.cancel();
  }
}
