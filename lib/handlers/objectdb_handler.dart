import 'package:dieklingel_app/database/objectdb_factory.dart';
import 'package:objectdb/objectdb.dart';

class ObjectDBHandler {
  static final ObjectDBHandler _instance = ObjectDBHandler._();
  factory ObjectDBHandler.getInstance() => _instance;

  ObjectDBHandler._();

  Future<ObjectDB> get(String name) async {
    assert(name.isNotEmpty);
    String path = await ObjectDBFactory.getDefaultPath();
    return ObjectDBFactory.get(path: "$path-$name");
  }
}
