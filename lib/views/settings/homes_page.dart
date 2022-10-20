import 'package:dieklingel_app/components/home.dart';
import 'package:dieklingel_app/components/radio_box.dart';
import 'package:dieklingel_app/views/settings/home_config_page.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:objectdb/objectdb.dart';

import '../../database/objectdb_factory.dart';

class HomesPage extends StatefulWidget {
  const HomesPage({super.key});

  @override
  State<StatefulWidget> createState() => _HomesPage();
}

class _HomesPage extends State<HomesPage> {
  Map<String, Home> _homes = {};
  ObjectDB? _database;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    _database = await ObjectDBFactory.named("mqtt_configurations");
    List<Map<dynamic, dynamic>> result = await _database!.find({});
    Map<String, Home> homes = {};
    for (Map<dynamic, dynamic> document in result) {
      String id = document["_id"];
      Home home = Home.fromJson(document.cast<String, dynamic>());
      homes[id] = home;
    }
    setState(() {
      _homes = homes;
    });
  }

  Future<void> _insert(Home home) async {
    if (null == _database) return;
    ObjectId id = await _database!.insert(home.toJson());
    setState(() {
      _homes[id.hexString] = home;
    });
  }

  Future<void> _update(String id, Home home) async {
    if (null == _database) return;
    await _database!.update({"_id": id}, home.toJson());
    setState(() {
      _homes[id] = home;
    });
  }

  Future<void> _remove(String id) async {
    if (null == _database) return;
    await _database!.remove({"_id": id});
    setState(() {
      _homes.remove(id);
    });
  }

  void _onPlusBtnPressed() async {
    Home? result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const HomeConfigPage(),
      ),
    );
    if (null == result) return;
    await _insert(result);
  }

  void _onListTilePressed(String id, Home home) async {
    Home? result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => HomeConfigPage(configuration: home),
      ),
    );
    if (null == result) return;
    await _update(id, result);
  }

  String _selected = "";

  void _onSelectionChanged(String id) {
    setState(() {
      _selected = id;
    });
  }

  Widget _listview() {
    List<MapEntry<String, Home>> entries = _homes.entries.toList();

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
                    MapEntry<String, Home> entry = entries[index];

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
                          prefix: Row(
                            children: [
                              RadioBox(
                                value: entry.key == _selected,
                                onChanged: (value) =>
                                    _onSelectionChanged(entry.key),
                              ),
                              const SizedBox(width: 10),
                              Text(entry.value.name),
                            ],
                          ),
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
        middle: const Text("Homes"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _onPlusBtnPressed,
          child: const Icon(CupertinoIcons.plus),
        ),
      ),
      child: SafeArea(
        child: _listview(),
      ),
    );
  }
}
