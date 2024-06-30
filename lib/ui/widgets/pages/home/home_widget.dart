import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:screen_capturer/screen_capturer.dart';

import '../../../../domain/entities/request_image.dart';
import '../../../../domain/entities/response_latex.dart';
import '../../../../mem_equals.dart';

FutureOr<String> get filePath async => _filePath ??= '${(await getTemporaryDirectory()).path}/math.png';
String? _filePath;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      setState(() {
        errorText = e.toString();
      });
      return null;
    }
  }

  Future<void> _snap() async {
    CapturedData? capturedData = await ScreenCapturer.instance.capture(
      imagePath: await filePath,
    );
    if (capturedData?.imageBytes == null) return;

    final capturedImageData = capturedData!.imageBytes!;
    if (memEquals(capturedImageData, imageData)) return;

    setState(() {
      imageData = capturedImageData;
      isLoading = true;
      errorText = null;
      latex = '';
      ocrText = '';
    });

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Copied to clipboard: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: result),
                ],
              ),
            ),
          ),
        );
      } else {
        errorText = response.errorMessage;
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: imageData != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16, left: 32, right: 32, top: 32),
                      child: FittedBox(
                        child: Card(
                          elevation: 8,
                          child: Image.memory(
                            imageData!,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: !isLoading
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 32, left: 32, right: 32, top: 16),
                            child: latex != ''
                                ? FittedBox(
                                    child: Math.tex(
                                      latex,
                                      mathStyle: MathStyle.display,
                                      textStyle: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: ocrText != ''
                                        ? Text(
                                            ocrText,
                                            style: Theme.of(context).textTheme.titleLarge,
                                            textAlign: TextAlign.center,
                                          )
                                        : Text(
                                            errorText ?? "Couldn't find formulas",
                                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.error),
                                            textAlign: TextAlign.center,
                                          ),
                                  ),
                          )
                        : const Center(
                            child: CircularProgressIndicator(),
                          ),
                  ),
                ],
              ),
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(36.0),
                child: Text(
                  'Click on the button below to take a screenshot',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _snap,
        child: const Icon(Icons.add),
      ),
    );
  }
}
