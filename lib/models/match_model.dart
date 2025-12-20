import 'dart:convert';

List<Match> matchFromJson(String str) => List<Match>.from(json.decode(str).map((x) => Match.fromJson(x)));

String matchToJson(List<Match> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Match {
  String model;
  int pk;
  Fields fields;

  Match({
    required this.model,
    required this.pk,
    required this.fields,
  });

  factory Match.fromJson(Map<String, dynamic> json) => Match(
    model: json["model"],
    pk: json["pk"],
    fields: Fields.fromJson(json["fields"]),
  );

  Map<String, dynamic> toJson() => {
    "model": model,
    "pk": pk,
    "fields": fields.toJson(),
  };
}

class Fields {
  int? homeClub;
  int? awayClub;
  String? homeClubName;
  String? awayClubName;
  DateTime matchDatetime;
  String venue;
  int createdBy;
  DateTime createdAt;
  bool isActive;

  Fields({
    this.homeClub,
    this.awayClub,
    this.homeClubName,
    this.awayClubName,
    required this.matchDatetime,
    required this.venue,
    required this.createdBy,
    required this.createdAt,
    required this.isActive,
  });

  factory Fields.fromJson(Map<String, dynamic> json) => Fields(
    homeClub: json["home_club"],
    awayClub: json["away_club"],
    homeClubName: json["home_club_name"],
    awayClubName: json["away_club_name"],
    matchDatetime: DateTime.parse(json["match_datetime"]),
    venue: json["venue"],
    createdBy: json["created_by"],
    createdAt: DateTime.parse(json["created_at"]),
    isActive: json["is_active"],
  );

  Map<String, dynamic> toJson() => {
    "home_club": homeClub,
    "away_club": awayClub,
    "home_club_name": homeClubName,
    "away_club_name": awayClubName,
    "match_datetime": matchDatetime.toIso8601String(),
    "venue": venue,
    "created_by": createdBy,
    "created_at": createdAt.toIso8601String(),
    "is_active": isActive,
  };
}