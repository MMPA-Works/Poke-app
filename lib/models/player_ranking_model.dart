class PlayerRanking {
  final String playerName;
  final int monstersCaught;

  PlayerRanking({
    required this.playerName,
    required this.monstersCaught,
  });

  factory PlayerRanking.fromJson(Map<String, dynamic> json) {
    return PlayerRanking(
      playerName: json['player_name'] ?? 'Unknown',
      monstersCaught: json['monsters_caught'] is int
          ? json['monsters_caught']
          : int.parse(json['monsters_caught'].toString()),
    );
  }
}