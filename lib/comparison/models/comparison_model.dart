// To parse this JSON data, do
//
//     final savedComparison = savedComparisonFromJson(jsonString);

import 'dart:convert';

SavedComparison savedComparisonFromJson(String str) => SavedComparison.fromJson(json.decode(str));

String savedComparisonToJson(SavedComparison data) => json.encode(data.toJson());

class SavedComparison {
    List<Comparison> comparisons;

    SavedComparison({
        required this.comparisons,
    });

    factory SavedComparison.fromJson(Map<String, dynamic> json) => SavedComparison(
        comparisons: List<Comparison>.from(json["comparisons"].map((x) => Comparison.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "comparisons": List<dynamic>.from(comparisons.map((x) => x.toJson())),
    };
}

class Comparison {
    int id;
    Player player1;
    Player player2;
    String createdAt;
    String notes;

    Comparison({
        required this.id,
        required this.player1,
        required this.player2,
        required this.createdAt,
        required this.notes,
    });

    factory Comparison.fromJson(Map<String, dynamic> json) => Comparison(
        id: json["id"],
        player1: Player.fromJson(json["player1"]),
        player2: Player.fromJson(json["player2"]),
        createdAt: json["created_at"],
        notes: json["notes"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "player1": player1.toJson(),
        "player2": player2.toJson(),
        "created_at": createdAt,
        "notes": notes,
    };
}

class Player {
    int id;
    String name;
    String club;
    String position;

    Player({
        required this.id,
        required this.name,
        required this.club,
        required this.position,
    });

    factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json["id"],
        name: json["name"],
        club: json["club"],
        position: json["position"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "club": club,
        "position": position,
    };
}
