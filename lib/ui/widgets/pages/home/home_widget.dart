import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:math_scan/ui/widgets/pages/home/home_model.dart';
import 'package:math_scan/ui/widgets/snackbar.dart';
import 'package:provider/provider.dart';

class HomePageWidget extends StatelessWidget {
  const HomePageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: SnackBarScope.new, lazy: false),
        ChangeNotifierProvider(create: (context) => HomePage()),
      ],
      child: const _Scaffold(),
    );
  }
}

class _Scaffold extends StatelessWidget {
  const _Scaffold();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<HomePage>();

    return Scaffold(
      body: model.imageData != null
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
                            model.imageData!,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: !model.isLoading
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 32, left: 32, right: 32, top: 16),
                            child: model.latex != ''
                                ? FittedBox(
                                    child: Math.tex(
                                      model.latex,
                                      mathStyle: MathStyle.display,
                                      textStyle: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: model.ocrText != ''
                                        ? Text(
                                            model.ocrText,
                                            style: Theme.of(context).textTheme.titleLarge,
                                            textAlign: TextAlign.center,
                                          )
                                        : Text(
                                            model.errorText ?? "Couldn't find formulas",
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
        onPressed: model.snap,
        child: const Icon(Icons.add),
      ),
    );
  }
}
