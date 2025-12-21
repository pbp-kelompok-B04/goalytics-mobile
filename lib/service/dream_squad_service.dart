// lib/service/dream_squad_service.dart
import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/dream_squad_models.dart';
import 'package:flutter/foundation.dart';
import 'api_config.dart';

class DreamSquadService {
  final CookieRequest request;
  final String baseUrl;

  DreamSquadService(this.request, {required this.baseUrl});

  /// Ambil squads (dan juga discovery_players). Jika [query] diberikan,
  /// backend akan mengembalikan discovery_players yang difilter.
  Future<SquadModel> fetchSquadList({String query = ""}) async {
    final encoded = Uri.encodeQueryComponent(query);
    // Pastikan baseUrl + path konsisten dan selalu ada trailing slash
    final base = ApiConfig.baseUrl.endsWith('/') ? ApiConfig.baseUrl : '${ApiConfig.baseUrl}/';
    final endpoint = "${base}dream-squad/api/squads/";
    final url = query.isNotEmpty ? "$endpoint?q=$encoded" : endpoint;

    debugPrint("fetchSquadList GET: $url");

    final response = await request.get(url);
    debugPrint("fetchSquadList raw response: $response");

    // Robust handling: pastikan response adalah Map<String,dynamic>
    if (response is Map<String, dynamic>) {
      return SquadModel.fromJson(response);
    } else {
      // deteksi HTML login page (heuristik sederhana)
      final s = response.toString().toLowerCase();
      if (s.contains('<form') || s.contains('csrfmiddlewaretoken') || s.contains('login')) {
        throw Exception('Server returned HTML (probably login page or redirect). Check session/cookies and endpoint URL.');
      }
      throw Exception('Unexpected API response type: ${response.runtimeType}');
    }
  }


  Future<Map<String, dynamic>> addBannedWord(String word) async {
    final response = await request.postJson(
      "${ApiConfig.baseUrl}/dream-squad/api/banned-words/add/",
      jsonEncode({'word': word}),
    );
    return response;
  }

  Future<Map<String, dynamic>> fetchPlayersForModal() async {
    final response = await request.get("${ApiConfig.baseUrl}/dream-squad/api/players-modal/");
    return response;
  }

  Future<Map<String, dynamic>> createSquad(String name, List<int> playerIds) async {
    final response = await request.postJson(
      "${ApiConfig.baseUrl}/dream-squad/api/create/",
      jsonEncode({
        'name': name,
        'mandatory_players': playerIds,
      }),
    );
    return response;
  }

  Future<Map<String, dynamic>> getSquadDetail(int squadId, {String query = ""}) async {
    final response = await request.get("${ApiConfig.baseUrl}/dream-squad/api/$squadId/?q=${Uri.encodeQueryComponent(query)}");
    return response;
  }

  Future<Map<String, dynamic>> addPlayerToSquad(int squadId, int playerId) async {
    final response = await request.postJson(
      "${ApiConfig.baseUrl}/dream-squad/api/add/$squadId/$playerId/",
      jsonEncode({}),
    );
    return response;
  }

  Future<Map<String, dynamic>> removePlayerFromSquad(int squadId, int playerId) async {
    final response = await request.postJson(
      "${ApiConfig.baseUrl}/dream-squad/api/remove/$squadId/$playerId/",
      jsonEncode({}),
    );
    return response;
  }

  Future<Map<String, dynamic>> editSquad(int squadId, String name, List<int> playerIds) async {
    final response = await request.postJson(
      "${ApiConfig.baseUrl}/dream-squad/api/edit/$squadId/",
      jsonEncode({
        'name': name,
        'players': playerIds,
      }),
    );
    return response;
  }

  /// PENTING: untuk search kita memanggil endpoint squads API (squad_list_api)
  /// karena di sana backend mengembalikan key "discovery_players".
  Future<List<DiscoveryPlayer>> searchPlayers(String query) async {
    // gunakan fetchSquadList yang sudah mengembalikan discovery_players
    final model = await fetchSquadList(query: query);
    // debug
    debugPrint("searchPlayers -> found ${model.discoveryPlayers.length} items for q='$query'");
    return model.discoveryPlayers;
  }

  Future<Map<String, dynamic>> saveSquad({int? id, required String name, required List<int> playerIds}) async {
    if (id == null) {
      return await createSquad(name, playerIds);
    } else {
      return await editSquad(id, name, playerIds);
    }
  }

  Future<Map<String, dynamic>> deleteSquad(int squadId) async {
    final response = await request.postJson(
      "${ApiConfig.baseUrl}/dream-squad/api/delete/$squadId/",
      jsonEncode({}),
    );
    return response;
  }

  Future<PlayerModel> getPlayerDetail(int playerId) async {
    final response = await request.get("${ApiConfig.baseUrl}/dream-squad/api/player/$playerId/");
    return PlayerModel.fromJson(response);
  }
}
