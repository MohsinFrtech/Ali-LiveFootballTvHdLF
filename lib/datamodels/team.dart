import 'dart:convert';

List<TeamData> teamFromMap(String str) => List<TeamData>.from(json.decode(str).map((x) => TeamData.fromMap(x)));

String teamToMap(List<TeamData> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class TeamData {
  Team? team;
  Venue? venue;

  TeamData({
    this.team,
    this.venue,
  });

  factory TeamData.fromMap(Map<String, dynamic> json) => TeamData(
    team: json["team"] == null ? null : Team.fromMap(json["team"]),
    venue: json["venue"] == null ? null : Venue.fromMap(json["venue"]),
  );

  Map<String, dynamic> toMap() => {
    "team": team?.toMap(),
    "venue": venue?.toMap(),
  };
}

class Team {
  int? id;
  String? name;
  String? code;
  String? country;
  int? founded;
  bool? national;
  String? logo;

  Team({
    this.id,
    this.name,
    this.code,
    this.country,
    this.founded,
    this.national,
    this.logo,
  });

  factory Team.fromMap(Map<String, dynamic> json) => Team(
    id: json["id"],
    name: json["name"],
    code: json["code"],
    country: json["country"],
    founded: json["founded"],
    national: json["national"],
    logo: json["logo"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "code": code,
    "country": country,
    "founded": founded,
    "national": national,
    "logo": logo,
  };
}

class Venue {
  int? id;
  String? name;
  String? address;
  String? city;
  int? capacity;
  String? surface;
  String? image;

  Venue({
    this.id,
    this.name,
    this.address,
    this.city,
    this.capacity,
    this.surface,
    this.image,
  });

  factory Venue.fromMap(Map<String, dynamic> json) => Venue(
    id: json["id"],
    name: json["name"],
    address: json["address"],
    city: json["city"],
    capacity: json["capacity"],
    surface: json["surface"],
    image: json["image"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "address": address,
    "city": city,
    "capacity": capacity,
    "surface": surface,
    "image": image,
  };
}
