import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SnackBarScope extends ChangeNotifier {
  SnackBarScope(this._context) {
    _subscription = _onMessageController.stream.listen(_onMessage);
  }

  final BuildContext _context;

  StreamSubscription? _subscription;

  void _onMessage(final TextSpan text) {
    if (_context.mounted) {
      ScaffoldMessenger.maybeOf(_context)?.showSnackBar(SnackBar(content: Text.rich(text)));
      if (kDebugMode) {
        print(text.toPlainText());
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final _onMessageController = StreamController<TextSpan>.broadcast();

void showSnackbar(final TextSpan message) {
  _onMessageController.add(message);
}
