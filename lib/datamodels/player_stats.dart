import 'dart:convert';

List<TeamPlayerStat> teamPlayerStatFromMap(String str) => List<TeamPlayerStat>.from(json.decode(str).map((x) => TeamPlayerStat.fromMap(x)));

String teamPlayerStatToMap(List<TeamPlayerStat> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class TeamPlayerStat {
  StatPlayer? player;
  List<Statistic>? statistics;

  TeamPlayerStat({
    this.player,
    this.statistics,
  });

  factory TeamPlayerStat.fromMap(Map<String, dynamic> json) => TeamPlayerStat(
    player: json["player"] == null ? null : StatPlayer.fromMap(json["player"]),
    statistics: json["statistics"] == null ? [] : List<Statistic>.from(json["statistics"]!.map((x) => Statistic.fromMap(x))),
  );

  Map<String, dynamic> toMap() => {
    "player": player?.toMap(),
    "statistics": statistics == null ? [] : List<dynamic>.from(statistics!.map((x) => x.toMap())),
  };
}

class StatPlayer {
  int? id;
  String? name;
  String? firstname;
  String? lastname;
  int? age;
  Birth? birth;
  String? nationality;
  String? height;
  String? weight;
  bool? injured;
  String? photo;

  StatPlayer({
    this.id,
    this.name,
    this.firstname,
    this.lastname,
    this.age,
    this.birth,
    this.nationality,
    this.height,
    this.weight,
    this.injured,
    this.photo,
  });

  factory StatPlayer.fromMap(Map<String, dynamic> json) => StatPlayer(
    id: json["id"],
    name: json["name"],
    firstname: json["firstname"],
    lastname: json["lastname"],
    age: json["age"],
    birth: json["birth"] == null ? null : Birth.fromMap(json["birth"]),
    nationality: json["nationality"],
    height: json["height"],
    weight: json["weight"],
    injured: json["injured"],
    photo: json["photo"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "firstname": firstname,
    "lastname": lastname,
    "age": age,
    "birth": birth?.toMap(),
    "nationality": nationality,
    "height": height,
    "weight": weight,
    "injured": injured,
    "photo": photo,
  };
}

class Birth {
  DateTime? date;
  String? place;
  String? country;

  Birth({
    this.date,
    this.place,
    this.country,
  });

  factory Birth.fromMap(Map<String, dynamic> json) => Birth(
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    place: json["place"],
    country: json["country"],
  );

  Map<String, dynamic> toMap() => {
    "date": "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
    "place": place,
    "country": country,
  };
}

class Statistic {
  Team? team;
  League? league;
  Games? games;
  Substitutes? substitutes;
  Shots? shots;
  Goals? goals;
  Passes? passes;
  Tackles? tackles;
  Duels? duels;
  Dribbles? dribbles;
  Fouls? fouls;
  Cards? cards;
  Penalty? penalty;

  Statistic({
    this.team,
    this.league,
    this.games,
    this.substitutes,
    this.shots,
    this.goals,
    this.passes,
    this.tackles,
    this.duels,
    this.dribbles,
    this.fouls,
    this.cards,
    this.penalty,
  });

  factory Statistic.fromMap(Map<String, dynamic> json) => Statistic(
    team: json["team"] == null ? null : Team.fromMap(json["team"]),
    league: json["league"] == null ? null : League.fromMap(json["league"]),
    games: json["games"] == null ? null : Games.fromMap(json["games"]),
    substitutes: json["substitutes"] == null ? null : Substitutes.fromMap(json["substitutes"]),
    shots: json["shots"] == null ? null : Shots.fromMap(json["shots"]),
    goals: json["goals"] == null ? null : Goals.fromMap(json["goals"]),
    passes: json["passes"] == null ? null : Passes.fromMap(json["passes"]),
    tackles: json["tackles"] == null ? null : Tackles.fromMap(json["tackles"]),
    duels: json["duels"] == null ? null : Duels.fromMap(json["duels"]),
    dribbles: json["dribbles"] == null ? null : Dribbles.fromMap(json["dribbles"]),
    fouls: json["fouls"] == null ? null : Fouls.fromMap(json["fouls"]),
    cards: json["cards"] == null ? null : Cards.fromMap(json["cards"]),
    penalty: json["penalty"] == null ? null : Penalty.fromMap(json["penalty"]),
  );

  Map<String, dynamic> toMap() => {
    "team": team?.toMap(),
    "league": league?.toMap(),
    "games": games?.toMap(),
    "substitutes": substitutes?.toMap(),
    "shots": shots?.toMap(),
    "goals": goals?.toMap(),
    "passes": passes?.toMap(),
    "tackles": tackles?.toMap(),
    "duels": duels?.toMap(),
    "dribbles": dribbles?.toMap(),
    "fouls": fouls?.toMap(),
    "cards": cards?.toMap(),
    "penalty": penalty?.toMap(),
  };
}

class Cards {
  int? yellow;
  int? yellowred;
  int? red;

  Cards({
    this.yellow,
    this.yellowred,
    this.red,
  });

  factory Cards.fromMap(Map<String, dynamic> json) => Cards(
    yellow: json["yellow"],
    yellowred: json["yellowred"],
    red: json["red"],
  );

  Map<String, dynamic> toMap() => {
    "yellow": yellow,
    "yellowred": yellowred,
    "red": red,
  };
}

class Dribbles {
  int? attempts;
  int? success;
  dynamic past;

  Dribbles({
    this.attempts,
    this.success,
    this.past,
  });

  factory Dribbles.fromMap(Map<String, dynamic> json) => Dribbles(
    attempts: json["attempts"],
    success: json["success"],
    past: json["past"],
  );

  Map<String, dynamic> toMap() => {
    "attempts": attempts,
    "success": success,
    "past": past,
  };
}

class Duels {
  int? total;
  int? won;

  Duels({
    this.total,
    this.won,
  });

  factory Duels.fromMap(Map<String, dynamic> json) => Duels(
    total: json["total"],
    won: json["won"],
  );

  Map<String, dynamic> toMap() => {
    "total": total,
    "won": won,
  };
}

class Fouls {
  int? drawn;
  int? committed;

  Fouls({
    this.drawn,
    this.committed,
  });

  factory Fouls.fromMap(Map<String, dynamic> json) => Fouls(
    drawn: json["drawn"],
    committed: json["committed"],
  );

  Map<String, dynamic> toMap() => {
    "drawn": drawn,
    "committed": committed,
  };
}

class Games {
  int? appearences;
  int? lineups;
  int? minutes;
  dynamic number;
  String? position;
  String? rating;
  bool? captain;

  Games({
    this.appearences,
    this.lineups,
    this.minutes,
    this.number,
    this.position,
    this.rating,
    this.captain,
  });

  factory Games.fromMap(Map<String, dynamic> json) => Games(
    appearences: json["appearences"],
    lineups: json["lineups"],
    minutes: json["minutes"],
    number: json["number"],
    position: json["position"],
    rating: json["rating"],
    captain: json["captain"],
  );

  Map<String, dynamic> toMap() => {
    "appearences": appearences,
    "lineups": lineups,
    "minutes": minutes,
    "number": number,
    "position": position,
    "rating": rating,
    "captain": captain,
  };
}

class Goals {
  int? total;
  int? conceded;
  int? assists;
  dynamic saves;

  Goals({
    this.total,
    this.conceded,
    this.assists,
    this.saves,
  });

  factory Goals.fromMap(Map<String, dynamic> json) => Goals(
    total: json["total"],
    conceded: json["conceded"],
    assists: json["assists"],
    saves: json["saves"],
  );

  Map<String, dynamic> toMap() => {
    "total": total,
    "conceded": conceded,
    "assists": assists,
    "saves": saves,
  };
}

class League {
  int? id;
  String? name;
  String? country;
  String? logo;
  String? flag;
  int? season;

  League({
    this.id,
    this.name,
    this.country,
    this.logo,
    this.flag,
    this.season,
  });

  factory League.fromMap(Map<String, dynamic> json) => League(
    id: json["id"],
    name: json["name"],
    country: json["country"],
    logo: json["logo"],
    flag: json["flag"],
    season: json["season"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "country": country,
    "logo": logo,
    "flag": flag,
    "season": season,
  };
}

class Passes {
  int? total;
  int? key;
  dynamic accuracy;

  Passes({
    this.total,
    this.key,
    this.accuracy,
  });

  factory Passes.fromMap(Map<String, dynamic> json) => Passes(
    total: json["total"],
    key: json["key"],
    accuracy: json["accuracy"],
  );

  Map<String, dynamic> toMap() => {
    "total": total,
    "key": key,
    "accuracy": accuracy,
  };
}

class Penalty {
  dynamic won;
  dynamic commited;
  int? scored;
  int? missed;
  dynamic saved;

  Penalty({
    this.won,
    this.commited,
    this.scored,
    this.missed,
    this.saved,
  });

  factory Penalty.fromMap(Map<String, dynamic> json) => Penalty(
    won: json["won"],
    commited: json["commited"],
    scored: json["scored"],
    missed: json["missed"],
    saved: json["saved"],
  );

  Map<String, dynamic> toMap() => {
    "won": won,
    "commited": commited,
    "scored": scored,
    "missed": missed,
    "saved": saved,
  };
}

class Shots {
  int? total;
  int? on;

  Shots({
    this.total,
    this.on,
  });

  factory Shots.fromMap(Map<String, dynamic> json) => Shots(
    total: json["total"],
    on: json["on"],
  );

  Map<String, dynamic> toMap() => {
    "total": total,
    "on": on,
  };
}

class Substitutes {
  int? substitutesIn;
  int? out;
  int? bench;

  Substitutes({
    this.substitutesIn,
    this.out,
    this.bench,
  });

  factory Substitutes.fromMap(Map<String, dynamic> json) => Substitutes(
    substitutesIn: json["in"],
    out: json["out"],
    bench: json["bench"],
  );

  Map<String, dynamic> toMap() => {
    "in": substitutesIn,
    "out": out,
    "bench": bench,
  };
}

class Tackles {
  int? total;
  dynamic blocks;
  dynamic interceptions;

  Tackles({
    this.total,
    this.blocks,
    this.interceptions,
  });

  factory Tackles.fromMap(Map<String, dynamic> json) => Tackles(
    total: json["total"],
    blocks: json["blocks"],
    interceptions: json["interceptions"],
  );

  Map<String, dynamic> toMap() => {
    "total": total,
    "blocks": blocks,
    "interceptions": interceptions,
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
