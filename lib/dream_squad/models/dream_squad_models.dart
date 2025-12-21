import 'dart:convert';

// Helper functions
SquadModel squadModelFromJson(String str) => SquadModel.fromJson(json.decode(str));
String squadModelToJson(SquadModel data) => json.encode(data.toJson());

PlayerModel playerModelFromJson(String str) => PlayerModel.fromJson(json.decode(str));
String playerModelToJson(PlayerModel data) => json.encode(data.toJson());

class SquadModel {
  bool success;
  bool isAdmin;
  List<MySquad> mySquads;
  GlobalStats stats;
  List<DiscoveryPlayer> discoveryPlayers;
  AdminExtras adminExtras;

  SquadModel({
    required this.success,
    required this.isAdmin,
    required this.mySquads,
    required this.stats,
    required this.discoveryPlayers,
    required this.adminExtras,
  });

  factory SquadModel.fromJson(Map<String, dynamic> json) => SquadModel(
    // Menggunakan ?? untuk menangani nilai null dari API
    success: json["success"] ?? false,
    isAdmin: json["is_admin"] ?? false,
    // Data sekarang diambil langsung dari root (bukan json["data"]["..."])
    mySquads: json["my_squads"] != null
        ? List<MySquad>.from(json["my_squads"].map((x) => MySquad.fromJson(x)))
        : [],
    stats: GlobalStats.fromJson(json["stats"] ?? {}),
    discoveryPlayers: json["discovery_players"] != null
        ? List<DiscoveryPlayer>.from(json["discovery_players"].map((x) => DiscoveryPlayer.fromJson(x)))
        : [],
    adminExtras: AdminExtras.fromJson(json["admin_extras"] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "is_admin": isAdmin,
    "my_squads": List<dynamic>.from(mySquads.map((x) => x.toJson())),
    "stats": stats.toJson(),
    "discovery_players": List<dynamic>.from(discoveryPlayers.map((x) => x.toJson())),
    "admin_extras": adminExtras.toJson(),
  };
}

class AdminExtras {
  List<String> bannedWords;
  List<DiscoveryPlayer> popularPlayers;

  AdminExtras({
    required this.bannedWords,
    required this.popularPlayers,
  });

  factory AdminExtras.fromJson(Map<String, dynamic> json) => AdminExtras(
    bannedWords: List<String>.from((json["banned_words"] ?? []).map((x) => x.toString())),
    popularPlayers: json["popular_players"] != null
        ? List<DiscoveryPlayer>.from(json["popular_players"].map((x) => DiscoveryPlayer.fromJson(x)))
        : [],
  );

  Map<String, dynamic> toJson() => {
    "banned_words": List<dynamic>.from(bannedWords.map((x) => x)),
    "popular_players": List<dynamic>.from(popularPlayers.map((x) => x)),
  };
}

class DiscoveryPlayer {
  int id;
  String name;
  String position;
  String clubName;
  int age;
  String? imageUrl;
  int? usage;
  int goals;
  int assists;

  DiscoveryPlayer({
    required this.id,
    required this.name,
    required this.position,
    required this.clubName,
    required this.age,
    this.imageUrl,
    this.usage,
    this.goals = 0,
    this.assists = 0,
  });

  factory DiscoveryPlayer.fromJson(Map<String, dynamic> json) {
    // helper untuk konversi ke int aman dari berbagai jenis numeric
    int toIntSafe(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is num) return (v).toInt();
      // fallback: coba parse string
      try {
        return int.parse(v.toString());
      } catch (_) {
        return 0;
      }
    }

    int? toNullableInt(dynamic v) {
      if (v == null) return null;
      return toIntSafe(v);
    }

    return DiscoveryPlayer(
      id: (json["id"] is int) ? json["id"] as int : (json["id"] is num ? (json["id"] as num).toInt() : int.tryParse(json["id"].toString()) ?? 0),
      name: json["name"] ?? "Unknown",
      position: json["position"] ?? "N/A",
      clubName: json["club_name"] ?? "Free Agent",
      age: toIntSafe(json["age"]),
      imageUrl: json["image_url"],
      usage: toNullableInt(json["usage"]),
      goals: toIntSafe(json["goals"]),
      assists: toIntSafe(json["assists"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "position": position,
    "club_name": clubName,
    "age": age,
    "image_url": imageUrl,
    "usage": usage,
    "goals": goals,
    "assists": assists,
  };
}

class GlobalStats {
  int totalSquads;
  int totalPlayersUsed;
  double averageAge;

  GlobalStats({
    required this.totalSquads,
    required this.totalPlayersUsed,
    required this.averageAge,
  });

  factory GlobalStats.fromJson(Map<String, dynamic> json) => GlobalStats(
    totalSquads: json["total_squads"] ?? 0,
    totalPlayersUsed: json["total_players_used"] ?? 0,
    averageAge: (json["average_age"] ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "total_squads": totalSquads,
    "total_players_used": totalPlayersUsed,
    "average_age": averageAge,
  };
}

class MySquad {
  int id;
  String name;
  int playerCount;

  MySquad({
    required this.id,
    required this.name,
    required this.playerCount,
  });

  factory MySquad.fromJson(Map<String, dynamic> json) => MySquad(
    id: json["id"] ?? 0,
    name: json["name"] ?? "Unnamed Squad",
    playerCount: json["player_count"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "player_count": playerCount,
  };
}

// --- PLAYER DETAIL MODEL ---
// --- PLAYER DETAIL MODEL ---
// (replace this block in dream_squad_models.dart)

class PlayerModel {
  bool success;
  String name;
  String? imageUrl;
  String positionDisplay;
  String clubName;
  String nation;
  int age;
  Attacking attacking;
  Passing passing;
  Defensive defensive;

  PlayerModel({
    required this.success,
    required this.name,
    this.imageUrl,
    required this.positionDisplay,
    required this.clubName,
    required this.nation,
    required this.age,
    required this.attacking,
    required this.passing,
    required this.defensive,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    int toIntSafe(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is num) return (v).toInt();
      try {
        return int.parse(v.toString());
      } catch (_) {
        return 0;
      }
    }

    double toDoubleSafe(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is num) return (v).toDouble();
      try {
        return double.parse(v.toString());
      } catch (_) {
        return 0.0;
      }
    }

    return PlayerModel(
      success: json["success"] ?? true,
      name: json["name"] ?? "Unknown",
      imageUrl: json["image_url"],
      positionDisplay: json["position_display"] ?? "N/A",
      clubName: json["club_name"] ?? "No Club",
      nation: json["nation"] ?? "N/A",
      age: toIntSafe(json["age"]),
      attacking: Attacking.fromJson(json["attacking"] ?? {}, toIntSafe, toDoubleSafe),
      passing: Passing.fromJson(json["passing"] ?? {}, toDoubleSafe, toIntSafe),
      defensive: Defensive.fromJson(json["defensive"] ?? {}, toIntSafe),
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "name": name,
    "image_url": imageUrl,
    "position_display": positionDisplay,
    "club_name": clubName,
    "nation": nation,
    "age": age,
    "attacking": attacking.toJson(),
    "passing": passing.toJson(),
    "defensive": defensive.toJson(),
  };
}

class Attacking {
  int goals;
  int assists;
  double xg;

  Attacking({required this.goals, required this.assists, required this.xg});

  // menerima helper agar konversi seragam
  factory Attacking.fromJson(Map<String, dynamic> json, int Function(dynamic) toIntSafe, double Function(dynamic) toDoubleSafe) => Attacking(
    goals: toIntSafe(json["goals"] ?? 0),
    assists: toIntSafe(json["assists"] ?? 0),
    xg: toDoubleSafe(json["xg"] ?? 0.0),
  );

  Map<String, dynamic> toJson() => {
    "goals": goals,
    "assists": assists,
    "xg": xg,
  };
}

class Passing {
  double accuracy;
  int completed;

  Passing({required this.accuracy, required this.completed});

  factory Passing.fromJson(Map<String, dynamic> json, double Function(dynamic) toDoubleSafe, int Function(dynamic) toIntSafe) => Passing(
    accuracy: toDoubleSafe(json["pass_accuracy"] ?? 0.0),
    completed: toIntSafe(json["passes_completed"] ?? 0),
  );

  Map<String, dynamic> toJson() => {
    "pass_accuracy": accuracy,
    "passes_completed": completed,
  };
}

class Defensive {
  int tacklesWon;
  int clearances;

  Defensive({required this.tacklesWon, required this.clearances});

  factory Defensive.fromJson(Map<String, dynamic> json, int Function(dynamic) toIntSafe) => Defensive(
    tacklesWon: toIntSafe(json["tackles_won"] ?? 0),
    clearances: toIntSafe(json["clearances"] ?? 0),
  );

  Map<String, dynamic> toJson() => {
    "tackles_won": tacklesWon,
    "clearances": clearances,
  };
}
