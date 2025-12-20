import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/comparison_model.dart';
import 'api_config.dart';

class PlayerService {

  static Future<List<Player>> searchPlayers(String query) async {
    final url = Uri.parse(
      "${ApiConfig.baseUrl}/comparison/api/player-search/?q=$query",
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Failed to search player");
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final playersList = data['players'] as List<dynamic>;
    
    return List<Player>.from(
      playersList.map((x) => Player.fromJson(x as Map<String, dynamic>)),
    );
  }


static Future<Map<String, dynamic>> comparePlayers({
  required int player1Id,
  required int player2Id,
}) async {
  try {
    final url = Uri.parse(
      "${ApiConfig.baseUrl}/comparison/api/compare-players-flutter/?player1_id=$player1Id&player2_id=$player2Id"
    );

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      
      if (decoded is! Map<String, dynamic>) {
        throw Exception("Invalid response format");
      }
 
      if (decoded.containsKey('error')) {
        throw Exception(decoded['error']);
      }
      
      if (decoded.containsKey('success') && decoded['success'] == false) {
        throw Exception(decoded['error'] ?? 'Comparison failed');
      }
      
      return Map<String, dynamic>.from(decoded);
    } else if (response.statusCode == 404) {
      throw Exception("Player not found");
    } else {
      throw Exception("Failed to compare players: ${response.statusCode}");
    }
  } on http.ClientException catch (e) {
    throw Exception("Network error: ${e.message}");
  } on FormatException catch (e) {
    throw Exception("Data format error: ${e.message}");
  } catch (e) {
    throw Exception("Error: ${e.toString()}");
  }
}


  static Future<Player> getPlayerById(
    int playerId, 
    CookieRequest request,
  ) async {
    try {
      final response = await request.get(
        '${ApiConfig.baseUrl}/comparison/api/players/$playerId/',
      );

      // Handle berbagai tipe response
      if (response is Map<String, dynamic>) {
        if (response.containsKey('player')) {
          final playerData = response['player'] as Map<String, dynamic>;
          return Player.fromJson(playerData);
        }
        throw Exception('Response missing player data');
      } else if (response is Map) {
        // Jika Map<dynamic, dynamic>
        final Map<dynamic, dynamic> res = response;
        if (res.containsKey('player')) {
          final playerData = res['player'] as Map<dynamic, dynamic>;
          return Player.fromJson(Map<String, dynamic>.from(playerData));
        }
        throw Exception('Response missing player data');
      } else {
        throw Exception('Unexpected response type: ${response.runtimeType}');
      }
    } catch (e) {
      print('Error getting player by ID: $e');
      rethrow;
    }
  }
}