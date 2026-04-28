class ApiConstants {
  static const String baseUrl = "https://ai-turf11-laravel.rmsiry.easypanel.host/api/v1";

  // AUTH
  static const sendOtp = "/auth/send-otp";
  static const resendOtp = "/auth/resend-otp";
  static const login = "/auth/login";
  static const register = "/auth/register";
  static const checkPhone = "/auth/check-phone";
  static const logout = "/auth/logout";
  static const profile = "/profile";
  static const bookings = "/bookings";

  // MATCHES
  static const matches = "/matches";
  static const nearbyMatches = "/matches/nearby";
  static const myMatches = "/matches/my";
  static const wallet = "/wallet";
  static const walletTransactions = "/wallet/transactions";
  static const walletTopupOrder = "/wallet/topup";
  static const walletTopupOrderLegacy = "/wallet/topup/order";
  static const walletTopupVerify = "/wallet/verify";
  static const turfsNearby = "/turfs/nearby";
  static const teams = "/teams";
  static const joinTeam = "/teams/join";
  static const tournaments = "/tournaments";

  static String matchDetail(dynamic matchId) => "/matches/$matchId";
  static String joinMatch(dynamic matchId) => "/matches/$matchId/join";
  static String leaveMatch(dynamic matchId) => "/matches/$matchId/leave";
  static String turfDetail(dynamic turfId) => "/turfs/$turfId";
  static String turfSlots(dynamic turfId) => "/turfs/$turfId/slots";
  static String cancelBooking(dynamic bookingId) => "/bookings/$bookingId/cancel";
  static String bookingInviteLink(dynamic bookingId) =>
      "/bookings/$bookingId/invite-link";
  static String bookingPlayers(dynamic bookingId) => "/bookings/$bookingId/players";
  static String teamDetail(dynamic teamId) => "/teams/$teamId";
  static String teamInviteLink(dynamic teamId) => "/teams/$teamId/invite-link";
  static String teamRemoveMember(dynamic teamId, dynamic memberId) =>
      "/teams/$teamId/remove/$memberId";
  static String teamLeave(dynamic teamId) => "/teams/$teamId/leave";
  static const joinBooking = "/bookings/join";
  static String tournamentRegister(dynamic tournamentId) =>
      "/tournaments/$tournamentId/register";
  static String tournamentTeams(dynamic tournamentId) =>
      "/tournaments/$tournamentId/teams";
  static String tournamentTeamPlayers(dynamic tournamentId, dynamic teamId) =>
      "/tournaments/$tournamentId/teams/$teamId/players";
}
