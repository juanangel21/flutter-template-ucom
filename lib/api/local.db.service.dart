import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class LocalDBService {
  Future<String> _getFilePath(String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$filename';
  }

  Future<File> _getFile(String filename, {bool forceUpdate = false}) async {
    final path = await _getFilePath(filename);
    final file = File(path);

    final exists = await file.exists();
    if (forceUpdate || !exists) {
      print("[LocalDB] Copiando desde assets: $filename");
      final data = await rootBundle.loadString('assets/data/$filename');
      await file.writeAsString(data);
    } else {
      print("[LocalDB] Usando archivo local: $filename");
    }

    return file;
  }

  Future<List<Map<String, dynamic>>> getAll(String filename, {bool forceUpdate = false}) async {
    final file = await _getFile(filename, forceUpdate: forceUpdate);
    final contents = await file.readAsString();

    try {
      final jsonData = jsonDecode(contents);
      if (jsonData is List) {
        return List<Map<String, dynamic>>.from(jsonData);
      } else {
        print("[LocalDB] ⚠️ El contenido de $filename no es una lista.");
        return [];
      }
    } catch (e) {
      print("[LocalDB] ❌ Error al leer JSON en $filename: $e");
      return [];
    }
  }

  Future<void> saveAll(String filename, List<Map<String, dynamic>> data) async {
    final file = await _getFile(filename);
    await file.writeAsString(jsonEncode(data));
    print("[LocalDB] Guardado $filename con ${data.length} registros.");
  }

  /// Agrega un item nuevo a la lista (opcional: evitar duplicados)
  Future<void> add(String filename, Map<String, dynamic> newItem, {String? uniqueKey}) async {
    final list = await getAll(filename);

    if (uniqueKey != null) {
      final exists = list.any((e) => e[uniqueKey] == newItem[uniqueKey]);
      if (exists) {
        print("[LocalDB] 🔁 El item con $uniqueKey=${newItem[uniqueKey]} ya existe. No se agrega.");
        return;
      }
    }

    list.add(newItem);
    await saveAll(filename, list);
  }

  /// Limpia el contenido de un archivo (por ejemplo para reiniciar pagos)
  Future<void> clear(String filename) async {
    final file = await _getFile(filename);
    await file.writeAsString(jsonEncode([]));
    print("[LocalDB] Archivo $filename limpiado.");
  }
}
