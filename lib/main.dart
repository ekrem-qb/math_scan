import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:http/http.dart' as http;
import 'package:math_scan/mem_equals.dart';
import 'package:math_scan/request_image.dart';
import 'package:math_scan/response_latex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screen_capturer/screen_capturer.dart';

FutureOr<String> get filePath async => _filePath ??= '${(await getTemporaryDirectory()).path}/math.png';
String? _filePath;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {
      super.didChangePlatformBrightness();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: WidgetsBinding.instance.platformDispatcher.platformBrightness,
      ),
      home: const MyHomePage(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String latex = '';
  String ocrText = '';
  Uint8List? imageData;
  bool isLoading = false;
  String? errorText;

  Future<ResponseLatex?> requestLatex(RequestImage image) async {
    try {
      final response = await http.post(
        Uri.parse('https://www.bing.com/cameraexp/api/v1/getlatex'),
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
    if (capturedData?.base64Image == null) return;

    final capturedImageData = base64Decode(capturedData!.base64Image!);
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
        data: capturedData.base64Image!,
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
