import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/comparison_model.dart';
import 'api_config.dart';

class ComparisonService {
  static Future<SavedComparison> getComparisons(CookieRequest request) async {
    final response = await request.get(
      "${ApiConfig.baseUrl}/comparison/api/saved-comparisons/",
    );

    if (response is Map) {
  final Map<String, dynamic> data =
      Map<String, dynamic>.from(response);

  if (data.containsKey('comparisons')) {
    return savedComparisonFromJson(jsonEncode(data));
  }

  if (data.containsKey('data')) {
    final List list = data['data'];
    return SavedComparison(
      comparisons: list.map((e) {
        final item = Map<String, dynamic>.from(e);
        return Comparison.fromJson(item);
      }).toList(),
    );
  }

  throw Exception("Format response tidak dikenali");
} else if (response is List<dynamic>) {
      return SavedComparison(
        comparisons: List<Comparison>.from(
          response.map((x) => Comparison.fromJson(x as Map<String, dynamic>)),
        ),
      );
    } else {
      throw Exception("Failed to load comparisons: ${response.runtimeType}");
    }
  }


  static Future<bool> saveComparison({
    required CookieRequest request,
    required int player1Id,
    required int player2Id,
    String notes = "",
    int? comparisonId,
  }) async {
     final Map<String, dynamic> data = {
      "player1_id": player1Id,
      "player2_id": player2Id,
      "notes": notes,
      if (comparisonId != null) "comparison_id": comparisonId
    };

    final response = await request.post(
      "${ApiConfig.baseUrl}/comparison/api/save-comparison-flutter/",
      jsonEncode(data), 
    );

    if (response is Map<String, dynamic>) {
      return response['success'] == true;
    } else if (response is Map) {
      final Map<dynamic, dynamic> res = response;
      return res['success'] == true;
    } else {
      print('Unexpected response type: ${response.runtimeType}');
      return false;
    }
  }

  static Future<bool> deleteComparison({
    required int comparisonId,
    required CookieRequest request,
  }) async {
    try {
      final response = await request.post(

        "${ApiConfig.baseUrl}/comparison/api/saved-comparisons-flutter/$comparisonId/delete/",
        {}, 
      );

      if (response['success'] == true) {
        return true;
      } else {
        print("Delete failed: ${response['error']}");
        return false;
      }
    } catch (e) {
      print('Error deleting comparison: $e');
      return false;
    }
  }


  static Future<Map<String, dynamic>> getComparisonDetail(
    int comparisonId,
    CookieRequest request,
  ) async {
    try {
      final response = await request.get(
        '${ApiConfig.baseUrl}/comparison/api/saved-comparisons-flutter/$comparisonId/',
      );

      if (response is Map) {
        return Map<String, dynamic>.from(response);
      } else {
        throw Exception('Unexpected response type: ${response.runtimeType}');
      }
    } catch (e) {
      print('Error getting comparison detail: $e');
      rethrow;
    }
  }
}