import 'dart:convert';

List<Prediction> predictionFromJson(String str) => List<Prediction>.from(json.decode(str).map((x) => Prediction.fromJson(x)));

String predictionToJson(List<Prediction> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Prediction {
  String model;
  int pk;
  Fields fields;

  Prediction({
    required this.model,
    required this.pk,
    required this.fields,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) => Prediction(
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
  int user;
  String? username;
  int match;
  int predictedHomeScore;
  int predictedAwayScore;
  String explanation;
  DateTime createdAt;
  int upvoteCount;
  bool isDeleted;
  bool userHasUpvoted;

  Fields({
    required this.user,
    this.username,
    required this.match,
    required this.predictedHomeScore,
    required this.predictedAwayScore,
    required this.explanation,
    required this.createdAt,
    required this.upvoteCount,
    required this.isDeleted,
    required this.userHasUpvoted,
  });

  factory Fields.fromJson(Map<String, dynamic> json) => Fields(
    user: json["user"],
    username: json["username"],
    match: json["match"],
    predictedHomeScore: json["predicted_home_score"],
    predictedAwayScore: json["predicted_away_score"],
    explanation: json["explanation"],
    createdAt: DateTime.parse(json["created_at"]),
    upvoteCount: json["upvote_count"],
    isDeleted: json["is_deleted"],
    userHasUpvoted: json["user_has_upvoted"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "user": user,
    "username": username,
    "match": match,
    "predicted_home_score": predictedHomeScore,
    "predicted_away_score": predictedAwayScore,
    "explanation": explanation,
    "created_at": createdAt.toIso8601String(),
    "upvote_count": upvoteCount,
    "is_deleted": isDeleted,
    "user_has_upvoted": userHasUpvoted,
  };
}