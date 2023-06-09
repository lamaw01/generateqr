import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';

class HomeData with ChangeNotifier {
  final screenshotController = ScreenshotController();

  Future<void> captureQrImage({required String fileName}) async {
    await screenshotController
        .capture(delay: const Duration(seconds: 1))
        .then((Uint8List? result) async {
      debugPrint(result.toString());
      if (result != null) {
        downloadQrImage(
          bytes: result,
          downloadName: '$fileName.png',
        );
      }
    }).catchError((Object err) {
      debugPrint(err.toString());
    });
  }

  void downloadQrImage({
    required List<int> bytes,
    required String downloadName,
  }) {
    // Encode our file in base64
    final base64 = base64Encode(bytes);
    // Create the link with the file
    final anchor =
        AnchorElement(href: 'data:application/octet-stream;base64,$base64')
          ..target = 'blank';
    // add the name
    anchor.download = downloadName;
    // trigger download
    document.body!.append(anchor);
    anchor.click();
    anchor.remove();
    return;
  }
}
