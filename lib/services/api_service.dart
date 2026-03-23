import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/monster_model.dart';
import '../models/player_ranking_model.dart';

class ApiService {
  static final http.Client _client = http.Client();
  static const Duration _timeout = Duration(seconds: 20);

  static String get baseUrl => AppConfig.apiBaseUrl;

  static Future<Map<String, dynamic>> registerPlayer(
    String name,
    String username,
    String password,
  ) async {
    return await _postJson(
      endpoint: 'register.php',
      body: {'player_name': name, 'username': username, 'password': password},
    );
  }

  static Future<Map<String, dynamic>> loginPlayer(
    String username,
    String password,
  ) async {
    return await _postJson(
      endpoint: 'login.php',
      body: {'username': username, 'password': password},
    );
  }

  static Future<Map<String, dynamic>> catchMonster(
    int playerId,
    int monsterId,
    int locationId,
    double latitude,
    double longitude,
  ) async {
    return await _postJson(
      endpoint: 'add_monster_catch.php',
      body: {
        'player_id': playerId,
        'monster_id': monsterId,
        'location_id': locationId,
        'latitude': latitude,
        'longitude': longitude,
      },
    );
  }

  // NOTE: This is the ONLY getPlayerRankings method now.
  static Future<List<PlayerRanking>> getPlayerRankings() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/top_monster_hunters.php'))
          .timeout(_timeout);

      final jsonMap = _decodeResponse(response);
      _throwIfRequestFailed(
        jsonMap,
        fallbackMessage: 'Failed to load rankings.',
      );

      final data = jsonMap['data'];
      if (data is! List) throw const ApiException('Invalid ranking list.');

      return data
          .whereType<Map>()
          .map(
            (item) => PlayerRanking.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } on TimeoutException {
      throw const ApiException('Request timed out.');
    } on SocketException {
      throw const ApiException('Unable to reach the server.');
    }
  }

  static Future<Map<String, dynamic>> addLocation({
    required String locationName,
    required double centerLatitude,
    required double centerLongitude,
    required double radiusMeters,
  }) async {
    final jsonMap = await _postJson(
      endpoint: 'add_location.php',
      body: {
        "location_name": locationName,
        "center_latitude": centerLatitude,
        "center_longitude": centerLongitude,
        "radius_meters": radiusMeters,
      },
    );
    _throwIfRequestFailed(jsonMap, fallbackMessage: 'Failed to add location.');
    return jsonMap;
  }

  static Future<List<Map<String, dynamic>>> getLocations() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/get_locations.php'))
          .timeout(_timeout);
      final jsonMap = _decodeResponse(response);

      if (jsonMap["success"] == true && jsonMap["locations"] is List) {
        return List<Map<String, dynamic>>.from(jsonMap["locations"]);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // RESTORED METHOD
  static Future<List<MonsterModel>> getMonsters() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/get_monsters.php'))
          .timeout(_timeout);

      final jsonMap = _decodeResponse(response);
      _throwIfRequestFailed(jsonMap, fallbackMessage: 'Failed to load monsters.');

      final data = jsonMap['data'];
      if (data is! List) {
        throw const ApiException('Invalid monster list received from the server.');
      }

      return data
          .whereType<Map>()
          .map((item) => MonsterModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on TimeoutException {
      throw const ApiException('Request timed out while loading monsters.');
    } on SocketException {
      throw const ApiException('Unable to reach the server.');
    }
  }

  // RESTORED METHOD
  static Future<Map<String, dynamic>> addMonster({
    required String monsterName,
    required String monsterType,
    required double spawnLatitude,
    required double spawnLongitude,
    required double spawnRadiusMeters,
    String? pictureUrl,
  }) async {
    final jsonMap = await _postJson(
      endpoint: 'add_monster.php',
      body: {
        "monster_name": monsterName,
        "monster_type": monsterType,
        "spawn_latitude": spawnLatitude,
        "spawn_longitude": spawnLongitude,
        "spawn_radius_meters": spawnRadiusMeters,
        "picture_url": pictureUrl ?? "",
      },
    );

    _throwIfRequestFailed(jsonMap, fallbackMessage: 'Failed to add monster.');
    return jsonMap;
  }

  static Future<Map<String, dynamic>> updateMonster({
    required int monsterId,
    required String monsterName,
    required String monsterType,
    required double spawnLatitude,
    required double spawnLongitude,
    required double spawnRadiusMeters,
    String? pictureUrl,
  }) async {
    final jsonMap = await _postJson(
      endpoint: 'update_monster.php',
      body: {
        "monster_id": monsterId,
        "monster_name": monsterName,
        "monster_type": monsterType,
        "spawn_latitude": spawnLatitude,
        "spawn_longitude": spawnLongitude,
        "spawn_radius_meters": spawnRadiusMeters,
        "picture_url": pictureUrl ?? "",
      },
    );

    _throwIfRequestFailed(
      jsonMap,
      fallbackMessage: 'Failed to update monster.',
    );
    return jsonMap;
  }

  static Future<Map<String, dynamic>> deleteMonster({
    required int monsterId,
  }) async {
    final jsonMap = await _postJson(
      endpoint: 'delete_monster.php',
      body: {"monster_id": monsterId},
    );

    _throwIfRequestFailed(
      jsonMap,
      fallbackMessage: 'Failed to delete monster.',
    );
    return jsonMap;
  }

  static Future<String> uploadMonsterImage(File imageFile) async {
    if (!await imageFile.exists()) {
      throw const ApiException('Selected image file could not be found.');
    }

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload_monster_image.php'),
      );
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);
      final jsonMap = _decodeResponse(response);

      _throwIfRequestFailed(jsonMap, fallbackMessage: 'Image upload failed.');

      final imageUrl = _extractString(jsonMap, const [
        'image_url',
        'picture_url',
        'url',
      ]);

      if (imageUrl == null || imageUrl.isEmpty) {
        throw const ApiException('Server did not return an image URL.');
      }

      return imageUrl;
    } on TimeoutException {
      throw const ApiException('Image upload timed out.');
    } on SocketException {
      throw const ApiException('Unable to reach the server for image upload.');
    }
  }

  static String? resolveImageUrl(String? rawPath) {
    if (rawPath == null || rawPath.trim().isEmpty) {
      return null;
    }

    final trimmed = rawPath.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    if (trimmed.startsWith('/')) {
      return '$baseUrl$trimmed';
    }

    return '$baseUrl/$trimmed';
  }

  // --- INTERNAL HELPERS ---

  static Future<Map<String, dynamic>> _postJson({
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/$endpoint'),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _decodeResponse(response);
    } on TimeoutException {
      throw const ApiException('Request timed out. Check your connection.');
    } on SocketException {
      throw const ApiException('Unable to reach the server.');
    }
  }

  static Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.body.trim().isEmpty) {
      throw const ApiException('Server returned an empty response.');
    }

    print('RAW SERVER RESPONSE: ${response.body}');

    dynamic decodedBody;
    try {
      decodedBody = jsonDecode(response.body);
    } on FormatException {
      throw const ApiException('Server returned invalid JSON data.');
    }

    if (decodedBody is! Map<String, dynamic>) {
      throw const ApiException('Unexpected response format from the server.');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message =
          _extractString(decodedBody, const ['message', 'error', 'details']) ??
          'Request failed with status ${response.statusCode}.';
      throw ApiException(message);
    }

    return decodedBody;
  }

  static void _throwIfRequestFailed(
    Map<String, dynamic> jsonMap, {
    required String fallbackMessage,
  }) {
    if (_isSuccess(jsonMap)) {
      return;
    }

    final message =
        _extractString(jsonMap, const ['message', 'error', 'details']) ??
        fallbackMessage;
    throw ApiException(message);
  }

  static bool _isSuccess(Map<String, dynamic> jsonMap) {
    final value = jsonMap['success'];
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1' || normalized == 'ok';
    }
    return false;
  }

  static String? _extractString(
    Map<String, dynamic> jsonMap,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = jsonMap[key];
      if (value == null) {
        continue;
      }

      final text = value.toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }
    return null;
  }
}

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
