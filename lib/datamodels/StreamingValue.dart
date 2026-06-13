
class StreamingValueModel {
  String data;

  StreamingValueModel({
    required this.data,
  });

  factory StreamingValueModel.fromJson(Map<String, dynamic> json) => StreamingValueModel(
    data: json["data"],
  );

  Map<String, dynamic> toJson() => {
    "data": data,
  };
}
