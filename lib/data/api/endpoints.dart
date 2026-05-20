import 'package:mastercs_mobile/core/api/api_config.dart';

class Endpoints {
  final ApiConfig apiConfig;

  const Endpoints(this.apiConfig);

  /// Builds a full URL for the given endpoint.
  String buildUrl(String endpoint) {
    final route = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return '${apiConfig.baseUrl}$route';
  }

  // * Auth Endpoints *
  String get hasUser => buildUrl('/auth/exists');
  String get login => buildUrl('/auth/login');
  String get register => buildUrl('/auth/register');
  String get logout => buildUrl('/auth/logout');
  String get forgotPassword => buildUrl('/auth/forgotPassword');
  String updatePassword(String auth) => buildUrl('/auth/updatePassword/$auth');

  // * Account Endpoints (for current authenticated user) *
  String get myAccount => buildUrl('/me');
  String get updateMyAccount => buildUrl('/me');
  String get deleteMyAccount => buildUrl('/me');
  String get myFcmTokens => buildUrl('/self/FCMtokens');
  String get profilePictureUpload => buildUrl('/me/profilePicture');
  String get profilePictureDelete => buildUrl('/me/profilePicture');
  String getProfilePicture(String filename) => buildUrl('/$filename');

  /// Get base URL without path (for serving static profile images)
  String get baseUrl => apiConfig.baseUrl;

  // * User Endpoints (for retrieving general users) *
  String getUsersByCamp(String campId) =>
      buildUrl('/camps/$campId/participants');
  String getUser(String userId) => buildUrl('/users/$userId');

  // * Camp Endpoints *
  String get getMyCamps => buildUrl('/camps');
  String get createCamp => buildUrl('/camps');
  String joinCamp(String code) => buildUrl('/camps/$code');
  String getCamp(String campId) => buildUrl('/camps/$campId');
  String leaveCamp(String campId) => buildUrl('/camps/$campId/leave');
  String deleteCamp(String campId) => buildUrl('/camps/$campId');
  String downloadJoinQrCode(String campId) =>
      buildUrl('/camps/$campId/joinQrCode/download');
  // Admin Camp Endpoints
  String updateMemberRole(String campId, String userId) =>
      buildUrl('/camps/$campId/participants/$userId');
  String removeMember(String campId, String userId) =>
      buildUrl('/camps/$campId/participants/$userId');
  String updateCamp(String id) => buildUrl('/camps/$id');

  // * Payment Endpoints *
  String getPaymentsByCamp(String campId) =>
      buildUrl('/camps/$campId/payments');
  String get getMyPayments => buildUrl('/me/payments');
  String getMyPaymentsByCamp(String campId) =>
      buildUrl('/me/camps/$campId/payments');
  // Admin Payment Endpoints
  String updateUserPayment(String campId, String userId, String paymentId) =>
      buildUrl('/camps/$campId/participants/$userId/payments/$paymentId');
  String createPayment(String campId) => buildUrl('/camps/$campId/payments');
  String updatePayment(String campId, String paymentId) =>
      buildUrl('/camps/$campId/payments/$paymentId');
  String deletePayment(String campId, String paymentId) =>
      buildUrl('/camps/$campId/payments/$paymentId');

  // * Room Endpoints (user permission) *
  String joinRoom(String campId, String code) =>
      buildUrl('/camps/$campId/rooms/$code');
  String createRoom(String campId) => buildUrl('/camps/$campId/rooms');
  String updateRoom(String campId, String roomId) =>
      buildUrl('/camps/$campId/rooms/$roomId');
  String leaveRoom(String campId) => buildUrl('/camps/$campId/rooms/leave');

  // * Group Endpoints (camper permission) *
  String joinGroup(String campId, String code) =>
      buildUrl('/camps/$campId/groups/$code');
  String createGroup(String campId) => buildUrl('/camps/$campId/groups');
  String updateGroup(String campId, String groupId) =>
      buildUrl('/camps/$campId/groups/$groupId');
  String leaveGroup(String campId) => buildUrl('/camps/$campId/groups/leave');
  String endGroup(String campId) => buildUrl('/camps/$campId/groups/end');

  // * Chat Endpoints (user permission) *
  String leaveChat(String campId, String chatId) =>
      buildUrl('/camps/$campId/chats/$chatId/leave');
  String getMyCampChats(String campId) => buildUrl('/camps/$campId/chats');
}
