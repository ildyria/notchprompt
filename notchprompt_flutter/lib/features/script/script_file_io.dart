import 'dart:io';

import 'package:file_picker/file_picker.dart';

/// Opens a native file picker for `.txt` files.
/// Returns the file contents as a UTF-8 string, or null if cancelled.
/// Throws on read error.
Future<String?> importScriptText() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: const ['txt'],
  );

  final path = result?.files.single.path;
  if (path == null) return null;

  return File(path).readAsString();
}

/// Opens a native save dialog defaulting to `script.txt`.
/// Writes [text] as UTF-8. Throws on write error.
Future<void> exportScriptText(String text) async {
  final outputPath = await FilePicker.platform.saveFile(
    dialogTitle: 'Export Script',
    fileName: 'script.txt',
    type: FileType.custom,
    allowedExtensions: const ['txt'],
  );

  if (outputPath == null) return;

  await File(outputPath).writeAsString(text);
}
