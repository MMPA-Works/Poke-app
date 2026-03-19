class PlayerRanking {
  final String playerName;
  final int monstersCaught;

  PlayerRanking({
    required this.playerName,
    required this.monstersCaught,
  });

  factory PlayerRanking.fromJson(Map<String, dynamic> json) {
    return PlayerRanking(
      playerName: json['player_name']?.toString() ?? "Unknown",
      monstersCaught: int.tryParse(json['monsters_caught'].toString()) ?? 0,
    );
  }
}