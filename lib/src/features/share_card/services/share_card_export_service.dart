import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareCardExportService {
  const ShareCardExportService();

  Future<File> saveCard({
    required GlobalKey boundaryKey,
    required String fileNamePrefix,
    double pixelRatio = 3,
  }) async {
    final bytes = await renderPngBytes(
      boundaryKey: boundaryKey,
      pixelRatio: pixelRatio,
    );
    final directory = await getApplicationDocumentsDirectory();
    return _writePng(
      directory: directory,
      bytes: bytes,
      fileNamePrefix: fileNamePrefix,
    );
  }

  Future<void> shareCard({
    required GlobalKey boundaryKey,
    required String fileNamePrefix,
    required String word,
    Rect? sharePositionOrigin,
    double pixelRatio = 3,
  }) async {
    final bytes = await renderPngBytes(
      boundaryKey: boundaryKey,
      pixelRatio: pixelRatio,
    );
    final directory = await getTemporaryDirectory();
    final file = await _writePng(
      directory: directory,
      bytes: bytes,
      fileNamePrefix: fileNamePrefix,
    );

    await SharePlus.instance.share(
      ShareParams(
        title: '拍沃德单词卡',
        subject: '拍沃德单词卡：$word',
        text: '我用拍沃德捕捉到一个单词：$word',
        files: [
          XFile(
            file.path,
            mimeType: 'image/png',
            name: file.uri.pathSegments.last,
          ),
        ],
        fileNameOverrides: [file.uri.pathSegments.last],
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }

  Future<Uint8List> renderPngBytes({
    required GlobalKey boundaryKey,
    double pixelRatio = 3,
  }) async {
    await WidgetsBinding.instance.endOfFrame;
    final renderObject = boundaryKey.currentContext?.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) {
      throw StateError('分享卡片还没有准备好，请稍后再试。');
    }

    final image = await renderObject.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    if (byteData == null) {
      throw StateError('生成图片失败，请稍后再试。');
    }

    return byteData.buffer.asUint8List();
  }

  Future<File> _writePng({
    required Directory directory,
    required Uint8List bytes,
    required String fileNamePrefix,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/$fileNamePrefix-$timestamp.png');
    return file.writeAsBytes(bytes, flush: true);
  }
}
