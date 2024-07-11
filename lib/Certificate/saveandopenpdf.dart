import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

class SaveAndOpenDocument {
  static Future<File> savePDF({
    required String name,
    required Document pdf,
  }) async {
    Directory? root;
    if (Platform.isAndroid) {
      final roots = await getExternalCacheDirectories();
      root = roots?.firstOrNull;
    } else {
      root = await getApplicationCacheDirectory();
    }

    if (root == null) {
      throw FileSystemException('Failed to get cache directory');
    }

    final file = File('${root.path}/$name');
    await file.writeAsBytes(await pdf.save());
    debugPrint('${file.path}');
    return file;
  }

  static Future<void> openPDF(File file) async {
    final path = file.path;
    await OpenFile.open(path);
  }
}
