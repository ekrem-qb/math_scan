import 'dart:convert';

class RequestImage {
  final String data;
  final String inputForm = 'Image';
  RequestImage({
    required this.data,
  });

  RequestImage copyWith({
    String? data,
  }) {
    return RequestImage(
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'data': data,
      'inputForm': inputForm,
    };
  }

  factory RequestImage.fromMap(Map<String, dynamic> map) {
    return RequestImage(
      data: map['data'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory RequestImage.fromJson(String source) => RequestImage.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'RequestImage(data: $data, inputForm: $inputForm)';

  @override
  bool operator ==(covariant RequestImage other) {
    if (identical(this, other)) return true;

    return other.data == data && other.inputForm == inputForm;
  }

  @override
  int get hashCode => data.hashCode ^ inputForm.hashCode;
}
