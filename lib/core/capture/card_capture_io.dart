import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';

/// Captura o widget da carta como PNG e devolve o caminho do arquivo.
Future<String?> captureCard(GlobalKey boundaryKey, String fileName) async {
  final boundary =
      boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) return null;

  final image = await boundary.toImage(pixelRatio: 2.4);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  if (data == null) return null;

  final directory = await getTemporaryDirectory();
  final file = File('${directory.path}/$fileName');
  await file.writeAsBytes(data.buffer.asUint8List());
  return file.path;
}
