import 'dart:convert';

List<Teamplayers> teamPlayersFromMap(String str) => List<Teamplayers>.from(json.decode(str).map((x) => Teamplayers.fromMap(x)));

String teamPlayersToMap(List<Teamplayers> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class Teamplayers {
  Team? team;
  List<Player>? players;

  Teamplayers({
    this.team,
    this.players,
  });

  factory Teamplayers.fromMap(Map<String, dynamic> json) => Teamplayers(
    team: json["team"] == null ? null : Team.fromMap(json["team"]),
    players: json["players"] == null ? [] : List<Player>.from(json["players"]!.map((x) => Player.fromMap(x))),
  );

  Map<String, dynamic> toMap() => {
    "team": team?.toMap(),
    "players": players == null ? [] : List<dynamic>.from(players!.map((x) => x.toMap())),
  };
}

class Player {
  int? id;
  String? name;
  int? age;
  int? number;
  String? position;
  String? photo;

  Player({
    this.id,
    this.name,
    this.age,
    this.number,
    this.position,
    this.photo,
  });

  factory Player.fromMap(Map<String, dynamic> json) => Player(
    id: json["id"],
    name: json["name"],
    age: json["age"],
    number: json["number"],
    position: json["position"],
    photo: json["photo"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "age": age,
    "number": number,
    "position": position,
    "photo": photo,
  };
}

class Team {
  int? id;
  String? name;
  String? logo;

  Team({
    this.id,
    this.name,
    this.logo,
  });

  factory Team.fromMap(Map<String, dynamic> json) => Team(
    id: json["id"],
    name: json["name"],
    logo: json["logo"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "logo": logo,
  };
}
