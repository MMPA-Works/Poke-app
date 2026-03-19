import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/monster_model.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  static const Duration _timeout = Duration(seconds: 20);

  final http.Client _client;

  static String get baseUrl => AppConfig.apiBaseUrl;

  Future<List<MonsterModel>> getMonsters() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/get_monsters.php'))
          .timeout(_timeout);

      final jsonMap = _decodeResponse(response);
      _throwIfRequestFailed(
        jsonMap,
        fallbackMessage: 'Failed to load monsters.',
      );

      final data = jsonMap['data'];
      if (data is! List) {
        throw const ApiException(
          'Invalid monster list received from the server.',
        );
      }

      return data
          .whereType<Map>()
          .map((item) => MonsterModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on TimeoutException {
      throw const ApiException(
        'Request timed out while loading monsters. Check your connection.',
      );
    } on SocketException {
      throw const ApiException(
        'Unable to reach the server. Check your internet connection.',
      );
    }
  }

  Future<void> addMonster(MonsterModel monster) async {
    final jsonMap = await _postForm(
      endpoint: 'add_monster.php',
      body: monster.toApiMap(),
    );

    _throwIfRequestFailed(jsonMap, fallbackMessage: 'Failed to add monster.');
  }

  Future<void> updateMonster(MonsterModel monster) async {
    final jsonMap = await _postForm(
      endpoint: 'update_monster.php',
      body: monster.toApiMap(includeId: true),
    );

    _throwIfRequestFailed(
      jsonMap,
      fallbackMessage: 'Failed to update monster.',
    );
  }

  Future<void> deleteMonster(int monsterId) async {
    final jsonMap = await _postForm(
      endpoint: 'delete_monster.php',
      body: {'monster_id': monsterId.toString()},
    );

    _throwIfRequestFailed(
      jsonMap,
      fallbackMessage: 'Failed to delete monster.',
    );
  }

  Future<String> uploadMonsterImage(File imageFile) async {
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
        'file_url',
        'path',
      ]);

      if (imageUrl == null || imageUrl.isEmpty) {
        throw const ApiException('Server did not return an image URL.');
      }

      return imageUrl;
    } on TimeoutException {
      throw const ApiException(
        'Image upload timed out. Check your connection and try again.',
      );
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

  Future<Map<String, dynamic>> _postForm({
    required String endpoint,
    required Map<String, String> body,
  }) async {
    try {
      final response = await _client
          .post(Uri.parse('$baseUrl/$endpoint'), body: body)
          .timeout(_timeout);
      return _decodeResponse(response);
    } on TimeoutException {
      throw const ApiException(
        'Request timed out. Check your connection and try again.',
      );
    } on SocketException {
      throw const ApiException(
        'Unable to reach the server. Check your internet connection.',
      );
    }
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.body.trim().isEmpty) {
      throw const ApiException('Server returned an empty response.');
    }

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

  void _throwIfRequestFailed(
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

  bool _isSuccess(Map<String, dynamic> jsonMap) {
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

  String? _extractString(Map<String, dynamic> jsonMap, List<String> keys) {
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
