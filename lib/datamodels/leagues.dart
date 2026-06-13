import 'dart:convert';

import 'package:floor/floor.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

List<LeagueFootball> leagueMap(String str) => List<LeagueFootball>.from(json.decode(str).map((x) => LeagueFootball.fromMap(x)));

String leagueToMap(List<LeagueFootball> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class LeagueFootball {
  int? id;
  int? leagueId;
  String? name;
  String? leagueType;
  String? logo;
  String? country;
  String? countryCode;
  String? countryFlag;
  DateTime? createdAt;
  DateTime? updatedAt;
  @ignore
  RxBool? isFavourite = RxBool(false);

  LeagueFootball({
    this.id,
    this.leagueId,
    this.name,
    this.leagueType,
    this.logo,
    this.country,
    this.countryCode,
    this.countryFlag,
    this.createdAt,
    this.updatedAt,
  });

  factory LeagueFootball.fromMap(Map<String, dynamic> json) => LeagueFootball(
    id: json["id"],
    leagueId: json["league_id"],
    name: json["name"],
    leagueType: json["league_type"],
    logo: json["logo"],
    country: json["country"],
    countryCode: json["country_code"],
    countryFlag: json["country_flag"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "league_id": leagueId,
    "name": name,
    "league_type": leagueType,
    "logo": logo,
    "country": country,
    "country_code": countryCode,
    "country_flag": countryFlag,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
