import 'dart:convert';

List<VenueClass> venueFromJson(String str) => List<VenueClass>.from(json.decode(str).map((x) => VenueClass.fromJson(x)));

String venueToJson(List<VenueClass> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class VenueClass {
  int id;
  int? venueId;
  String? name;
  String? city;
  DateTime createdAt;
  DateTime updatedAt;

  VenueClass({
    required this.id,
    required this.venueId,
    required this.name,
    required this.city,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VenueClass.fromJson(Map<String, dynamic> json) => VenueClass(
    id: json["id"],
    venueId: json["venue_id"],
    name: json["name"],
    city: json["city"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "venue_id": venueId,
    "name": name,
    "city": city,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
