import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:screen_capturer/screen_capturer.dart';

import '../../../../domain/entities/request_image.dart';
import '../../../../domain/entities/response_latex.dart';
import '../../../../mem_equals.dart';
import '../../snackbar.dart';

class HomePage extends ChangeNotifier {
  static FutureOr<String> get filePath async => _filePath ??= '${(await getTemporaryDirectory()).path}/math.png';
  static String? _filePath;

  String latex = '';
  String ocrText = '';
  Uint8List? imageData;
  bool isLoading = false;
  String? errorText;

  Future<ResponseLatex?> requestLatex(RequestImage image) async {
    try {
      final response = await http.post(
        Uri.parse('https://mathsolver.microsoft.com/cameraexp/api/v1/getlatex'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: image.toJson(),
      );

      switch (response.statusCode) {
        case 200:
          return ResponseLatex.fromJson(response.body);
        default:
          return null;
      }
    } on Exception catch (e) {
      errorText = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> snap() async {
    CapturedData? capturedData = await ScreenCapturer.instance.capture(
      imagePath: await filePath,
    );
    if (capturedData?.imageBytes == null) return;

    final capturedImageData = capturedData!.imageBytes!;
    if (memEquals(capturedImageData, imageData)) return;

    imageData = capturedImageData;
    isLoading = true;
    errorText = null;
    latex = '';
    ocrText = '';
    notifyListeners();

    ResponseLatex? response = await requestLatex(
      RequestImage(
        data: base64Encode(capturedData.imageBytes!),
      ),
    );

    if (response != null) {
      if (!response.isError) {
        String result = '';
        if (response.latex != '') {
          result = response.latex;
          latex = response.latex;
        } else {
          result = response.ocrText ?? '';
          ocrText = response.ocrText ?? '';
        }
        Clipboard.setData(ClipboardData(text: result));
        showSnackbar(TextSpan(
          children: [
            const TextSpan(
              text: 'Copied to clipboard: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: result),
          ],
        ));
      } else {
        errorText = response.errorMessage;
      }
    }

    isLoading = false;
    notifyListeners();
  }
}
