import 'dart:convert';

class ResponseLatex {
  final String latex;
  final String? ocrText;
  final String solution;
  final int timestamp;
  final bool isError;
  final String errorMessage;
  final String customLatex;
  final String keyboardLatexInput;
  ResponseLatex({
    required this.latex,
    required this.ocrText,
    required this.solution,
    required this.timestamp,
    required this.isError,
    required this.errorMessage,
    required this.customLatex,
    required this.keyboardLatexInput,
  });

  ResponseLatex copyWith({
    String? latex,
    String? ocrText,
    String? solution,
    int? timestamp,
    bool? isError,
    String? errorMessage,
    String? customLatex,
    String? keyboardLatexInput,
  }) {
    return ResponseLatex(
      latex: latex ?? this.latex,
      ocrText: ocrText ?? this.ocrText,
      solution: solution ?? this.solution,
      timestamp: timestamp ?? this.timestamp,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      customLatex: customLatex ?? this.customLatex,
      keyboardLatexInput: keyboardLatexInput ?? this.keyboardLatexInput,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'latex': latex,
      'ocrText': ocrText,
      'solution': solution,
      'timestamp': timestamp,
      'isError': isError,
      'errorMessage': errorMessage,
      'customLatex': customLatex,
      'keyboardLatexInput': keyboardLatexInput,
    };
  }

  factory ResponseLatex.fromMap(Map<String, dynamic> map) {
    return ResponseLatex(
      latex: map['latex'] as String,
      ocrText: map['ocrText'] as String?,
      solution: map['solution'] as String,
      timestamp: map['timestamp'].toInt() as int,
      isError: map['isError'] as bool,
      errorMessage: map['errorMessage'] as String,
      customLatex: map['customLatex'] as String,
      keyboardLatexInput: map['keyboardLatexInput'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ResponseLatex.fromJson(String source) => ResponseLatex.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ResponseLatex(latex: $latex, ocrText: $ocrText, solution: $solution, timestamp: $timestamp, isError: $isError, errorMessage: $errorMessage, customLatex: $customLatex, keyboardLatexInput: $keyboardLatexInput)';
  }

  @override
  bool operator ==(covariant ResponseLatex other) {
    if (identical(this, other)) return true;

    return other.latex == latex && other.ocrText == ocrText && other.solution == solution && other.timestamp == timestamp && other.isError == isError && other.errorMessage == errorMessage && other.customLatex == customLatex && other.keyboardLatexInput == keyboardLatexInput;
  }

  @override
  int get hashCode {
    return latex.hashCode ^ ocrText.hashCode ^ solution.hashCode ^ timestamp.hashCode ^ isError.hashCode ^ errorMessage.hashCode ^ customLatex.hashCode ^ keyboardLatexInput.hashCode;
  }
}
