class UserSession {
  static int? playerId;
  static String? playerName;

  static void clear() {
    playerId = null;
    playerName = null;
  }
}