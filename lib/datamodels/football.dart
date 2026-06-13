import 'dart:convert';

import 'package:get/get_rx/src/rx_types/rx_types.dart';

List<FootballData> welcomeFromMap(String str) => List<FootballData>.from(json.decode(str).map((x) => FootballData.fromMap(x)));

String welcomeToMap(List<FootballData> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class FootballData {
  int? id;
  int? matchId;
  String? referee;
  String? state;
  String? timezone;
  DateTime? date;
  int? timestamp;
  dynamic winnerName;
  Team? homeTeam;
  Team? awayTeam;
  Goals? goals;
  Score? score;
  Status? status;
  dynamic events;
  Periods? periods;
  Venue? venue;
  League? league;
  int? seasonId;
  int? leagueId;
  int? homeTeamId;
  int? awayTeamId;
  int? venueId;
  DateTime? createdAt;
  DateTime? updatedAt;

  FootballData({
    this.id,
    this.matchId,
    this.referee,
    this.state,
    this.timezone,
    this.date,
    this.timestamp,
    this.winnerName,
    this.homeTeam,
    this.awayTeam,
    this.goals,
    this.score,
    this.status,
    this.events,
    this.periods,
    this.venue,
    this.league,
    this.seasonId,
    this.leagueId,
    this.homeTeamId,
    this.awayTeamId,
    this.venueId,
    this.createdAt,
    this.updatedAt,
  });

  factory FootballData.fromMap(Map<String, dynamic> json) => FootballData(
    id: json["id"],
    matchId: json["match_id"],
    referee: json["referee"],
    state: json["state"],
    timezone: json["timezone"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    timestamp: json["timestamp"],
    winnerName: json["winner_name"],
    homeTeam: json["home_team"] == null ? null : Team.fromMap(json["home_team"]),
    awayTeam: json["away_team"] == null ? null : Team.fromMap(json["away_team"]),
    goals: json["goals"] == null ? null : Goals.fromMap(json["goals"]),
    score: json["score"] == null ? null : Score.fromMap(json["score"]),
    status: json["status"] == null ? null : Status.fromMap(json["status"]),
    events: json["events"],
    periods: json["periods"] == null ? null : Periods.fromMap(json["periods"]),
    venue: json["venue"] == null ? null : Venue.fromMap(json["venue"]),
    league: json["league"] == null ? null : League.fromMap(json["league"]),
    seasonId: json["season_id"],
    leagueId: json["league_id"],
    homeTeamId: json["home_team_id"],
    awayTeamId: json["away_team_id"],
    venueId: json["venue_id"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "match_id": matchId,
    "referee": referee,
    "state": state,
    "timezone": timezone,
    "date": date?.toIso8601String(),
    "timestamp": timestamp,
    "winner_name": winnerName,
    "home_team": homeTeam?.toMap(),
    "away_team": awayTeam?.toMap(),
    "goals": goals?.toMap(),
    "score": score?.toMap(),
    "status": status?.toMap(),
    "events": events,
    "periods": periods?.toMap(),
    "venue": venue?.toMap(),
    "league": league?.toMap(),
    "season_id": seasonId,
    "league_id": leagueId,
    "home_team_id": homeTeamId,
    "away_team_id": awayTeamId,
    "venue_id": venueId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class Team {
  int? id;
  String? name;
  String? logo;
  bool? winner;

  Team({
    this.id,
    this.name,
    this.logo,
    this.winner,
  });

  factory Team.fromMap(Map<String, dynamic> json) => Team(
    id: json["id"],
    name: json["name"],
    logo: json["logo"],
    winner: json["winner"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "logo": logo,
    "winner": winner,
  };
}

class Event {
  Time? time;
  Team? team;
  Assist? player;
  Assist? assist;
  String? type;
  String? detail;
  dynamic comments;

  Event({
    this.time,
    this.team,
    this.player,
    this.assist,
    this.type,
    this.detail,
    this.comments,
  });

  factory Event.fromMap(Map<String, dynamic> json) => Event(
    time: json["time"] == null ? null : Time.fromMap(json["time"]),
    team: json["team"] == null ? null : Team.fromMap(json["team"]),
    player: json["player"] == null ? null : Assist.fromMap(json["player"]),
    assist: json["assist"] == null ? null : Assist.fromMap(json["assist"]),
    type: json["type"],
    detail: json["detail"],
    comments: json["comments"],
  );

  Map<String, dynamic> toMap() => {
    "time": time?.toMap(),
    "team": team?.toMap(),
    "player": player?.toMap(),
    "assist": assist?.toMap(),
    "type": type,
    "detail": detail,
    "comments": comments,
  };
}

class Assist {
  dynamic id;
  String? name;

  Assist({
    this.id,
    this.name,
  });

  factory Assist.fromMap(Map<String, dynamic> json) => Assist(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
  };
}

class Time {
  int? elapsed;
  dynamic extra;

  Time({
    this.elapsed,
    this.extra,
  });

  factory Time.fromMap(Map<String, dynamic> json) => Time(
    elapsed: json["elapsed"],
    extra: json["extra"],
  );

  Map<String, dynamic> toMap() => {
    "elapsed": elapsed,
    "extra": extra,
  };
}

class EventsClass {
  EventsClass();

  factory EventsClass.fromMap(Map<String, dynamic> json) => EventsClass(
  );

  Map<String, dynamic> toMap() => {
  };
}

class Goals {
  int? home =0 ;
  int? away =0;

  Goals({
    this.home,
    this.away,
  });

  factory Goals.fromMap(Map<String, dynamic> json) => Goals(
    home: json["home"],
    away: json["away"],
  );

  Map<String, dynamic> toMap() => {
    "home": home,
    "away": away,
  };
}

class League {
  int? id;
  String? name;
  String? country;
  String? logo;
  String? flag;
  int? season;
  String? round;
  RxBool? isFavourite=RxBool(false);

  League({
    this.id,
    this.name,
    this.country,
    this.logo,
    this.flag,
    this.season,
    this.round,
  });

  factory League.fromMap(Map<String, dynamic> json) => League(
    id: json["id"],
    name: json["name"],
    country: json["country"],
    logo: json["logo"],
    flag: json["flag"],
    season: json["season"],
    round: json["round"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "country": country,
    "logo": logo,
    "flag": flag,
    "season": season,
    "round": round,
  };
}

class Periods {
  int? first;
  int? second;

  Periods({
    this.first,
    this.second,
  });

  factory Periods.fromMap(Map<String, dynamic> json) => Periods(
    first: json["first"],
    second: json["second"],
  );

  Map<String, dynamic> toMap() => {
    "first": first,
    "second": second,
  };
}

class Score {
  Goals? halftime;
  Goals? fulltime;
  Goals? extratime;
  Goals? penalty;

  Score({
    this.halftime,
    this.fulltime,
    this.extratime,
    this.penalty,
  });

  factory Score.fromMap(Map<String, dynamic> json) => Score(
    halftime: json["halftime"] == null ? null : Goals.fromMap(json["halftime"]),
    fulltime: json["fulltime"] == null ? null : Goals.fromMap(json["fulltime"]),
    extratime: json["extratime"] == null ? null : Goals.fromMap(json["extratime"]),
    penalty: json["penalty"] == null ? null : Goals.fromMap(json["penalty"]),
  );

  Map<String, dynamic> toMap() => {
    "halftime": halftime?.toMap(),
    "fulltime": fulltime?.toMap(),
    "extratime": extratime?.toMap(),
    "penalty": penalty?.toMap(),
  };
}

class Status {
  String? long;
  String? short;
  int? elapsed;

  Status({
    this.long,
    this.short,
    this.elapsed,
  });

  factory Status.fromMap(Map<String, dynamic> json) => Status(
    long: json["long"],
    short: json["short"],
    elapsed: json["elapsed"],
  );

  Map<String, dynamic> toMap() => {
    "long": long,
    "short": short,
    "elapsed": elapsed,
  };
}

class Venue {
  int? id;
  String? name;
  String? city;

  Venue({
    this.id,
    this.name,
    this.city,
  });

  factory Venue.fromMap(Map<String, dynamic> json) => Venue(
    id: json["id"],
    name: json["name"],
    city: json["city"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "city": city,
  };
}
