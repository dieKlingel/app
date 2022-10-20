import 'package:objectdb/objectdb.dart';
// ignore: implementation_imports
import 'package:objectdb/src/objectdb_storage_indexeddb.dart';

class ObjectDBStorageFactory {
  static StorageInterface get(String path) {
    return IndexedDBStorage(path);
  }

  static Future<String> getDefaultDatabase() async {
    return "dieklingel_default_web_database";
  }

  static Future<String> getDatabseDirectory() async {
    return "";
  }
}
