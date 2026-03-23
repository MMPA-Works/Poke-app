class PlayerRanking {
  final String playerName;
  final int monstersCaught;

  PlayerRanking({
    required this.playerName,
    required this.monstersCaught,
  });

  factory PlayerRanking.fromJson(Map<String, dynamic> json) {
    final catches = json['monsters_caught'] ?? json['total_catches'] ?? 0;

    return PlayerRanking(
      playerName: json['player_name'] ?? 'Unknown',
      monstersCaught: catches is int ? catches : int.parse(catches.toString()),
    );
  }
}
