class ApiConstants {
  static const String baseUrl = "https://ai-turf11-laravel.rmsiry.easypanel.host/api/v1";

  // AUTH
  static const sendOtp = "/auth/send-otp";
  static const resendOtp = "/auth/resend-otp";
  static const login = "/auth/login";
  static const register = "/auth/register";
  static const checkPhone = "/auth/check-phone";
  static const logout = "/auth/logout";

  // MATCHES
  static const matches = "/matches";
  static const nearbyMatches = "/matches/nearby";
  static const myMatches = "/matches/my";
  static const wallet = "/wallet";
  static const walletTopupOrder = "/wallet/topup/order";
  static const walletTopupVerify = "/wallet/topup/verify";

  static String matchDetail(dynamic matchId) => "/matches/$matchId";
  static String joinMatch(dynamic matchId) => "/matches/$matchId/join";
  static String leaveMatch(dynamic matchId) => "/matches/$matchId/leave";
}
