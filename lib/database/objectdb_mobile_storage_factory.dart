import 'dart:io';

import 'package:objectdb/objectdb.dart';
// ignore: implementation_imports
import 'package:objectdb/src/objectdb_storage_filesystem.dart';
import 'package:path_provider/path_provider.dart';

class ObjectDBStorageFactory {
  static StorageInterface get(String path) {
    return FileSystemStorage(path);
  }

  static Future<String> getDefaultDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path;
    return "$path/dieklingel_default_mobile_database";
  }
}
