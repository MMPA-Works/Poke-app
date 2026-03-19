class MonsterModel {
  const MonsterModel({
    required this.monsterId,
    required this.monsterName,
    required this.monsterType,
    required this.spawnLatitude,
    required this.spawnLongitude,
    required this.spawnRadiusMeters,
    this.pictureUrl,
  });

  final int monsterId;
  final String monsterName;
  final String monsterType;
  final double spawnLatitude;
  final double spawnLongitude;
  final double spawnRadiusMeters;
  final String? pictureUrl;

  factory MonsterModel.fromJson(Map<String, dynamic> json) {
    return MonsterModel(
      monsterId: _tryParseInt(json['monster_id'] ?? json['monsterId']) ?? 0,
      monsterName:
          _normalizeText(json['monster_name'] ?? json['monsterName']) ?? '',
      monsterType:
          _normalizeText(json['monster_type'] ?? json['monsterType']) ?? '',
      spawnLatitude:
          _tryParseDouble(json['spawn_latitude'] ?? json['spawnLatitude']) ?? 0,
      spawnLongitude:
          _tryParseDouble(json['spawn_longitude'] ?? json['spawnLongitude']) ??
          0,
      spawnRadiusMeters:
          _tryParseDouble(
            json['spawn_radius_meters'] ?? json['spawnRadiusMeters'],
          ) ??
          0,
      pictureUrl: _normalizeText(json['picture_url'] ?? json['pictureUrl']),
    );
  }

  MonsterModel copyWith({
    int? monsterId,
    String? monsterName,
    String? monsterType,
    double? spawnLatitude,
    double? spawnLongitude,
    double? spawnRadiusMeters,
    String? pictureUrl,
  }) {
    return MonsterModel(
      monsterId: monsterId ?? this.monsterId,
      monsterName: monsterName ?? this.monsterName,
      monsterType: monsterType ?? this.monsterType,
      spawnLatitude: spawnLatitude ?? this.spawnLatitude,
      spawnLongitude: spawnLongitude ?? this.spawnLongitude,
      spawnRadiusMeters: spawnRadiusMeters ?? this.spawnRadiusMeters,
      pictureUrl: pictureUrl ?? this.pictureUrl,
    );
  }

  Map<String, String> toApiMap({bool includeId = false}) {
    final payload = <String, String>{
      'monster_name': monsterName.trim(),
      'monster_type': monsterType.trim(),
      'spawn_latitude': spawnLatitude.toString(),
      'spawn_longitude': spawnLongitude.toString(),
      'spawn_radius_meters': spawnRadiusMeters.toString(),
      'picture_url': pictureUrl?.trim() ?? '',
    };

    if (includeId) {
      payload['monster_id'] = monsterId.toString();
    }

    return payload;
  }

  static int? _tryParseInt(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value.toString().trim());
  }

  static double? _tryParseDouble(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString().trim());
  }

  static String? _normalizeText(Object? value) {
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
