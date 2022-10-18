import 'package:objectdb/objectdb.dart';

import 'objectdb_mobile_storage_factory.dart'
    if (dart.library.js) 'objectdb_web_storage_factory.dart';

typedef JSON = Map<dynamic, dynamic>;

class ObjectDBFactory {
  static Future<ObjectDB> get({String? path}) async {
    path ??= await ObjectDBStorageFactory.getDefaultDatabase();
    return ObjectDB(ObjectDBStorageFactory.get(path));
  }

  static Future<String> getDefaultPath() async {
    return await ObjectDBStorageFactory.getDefaultDatabase();
  }
}
