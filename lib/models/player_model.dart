class Player {
  final int playerId;
  final String playerName;

  Player({
    required this.playerId,
    required this.playerName,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      playerId: json['player_id'] is int
          ? json['player_id']
          : int.parse(json['player_id'].toString()),
      playerName: json['player_name'] ?? 'Unknown',
    );
  }
}