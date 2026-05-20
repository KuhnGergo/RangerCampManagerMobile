import 'package:mastercs_mobile/core/api/api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Incoming chat json structure:
// {
//   "chatId": "26db2e03-6319-4a5e-93c0-1a499ebcd2e4",
//   "name": "Auf dem Wald",
//   "color": null,
//   "lastMessageAt": null,
//   "lastSeenAt": null,
//   "groupId": null,
//   "roomId": null,
//   "joinCode": null,
//   "type": "Camp",
//   "chatMembers": [
//       {
//           "userId": "a963c29b-4fd4-4a85-a20b-9dccca8f975c",
//           "lastSeen": null
//       },
//       {
//           "userId": "a963c29b-4fd4-4a85-a20b-9dccca8f975c",
//           "lastSeen": null
//       }
//   ]
// },
// Expected outgoing chat json structure:
// {
//     "name": "BajuSzoba2",
//     "color": "#123456",
//     "joinCode": "123456"
// }

/// Provider for the ChatsApi service
final chatsApiProvider = Provider<ChatsApi>((ref) {
  final client = ref.watch(httpClientProvider);
  final endpoints = ref.watch(endpointsProvider);
  return ChatsApi(client, endpoints);
});

/// API client for chat-related operations (rooms, groups, and general chats)
/// All operations are organized by entity type (Room, Group, Chat) for clarity
class ChatsApi {
  final ApiHttpClient _client;
  final Endpoints _endpoints;

  ChatsApi(this._client, this._endpoints);

  // ==================== ROOM OPERATIONS ====================

  /// Join a room by code
  /// POST /camps/:id/rooms/:code
  /// Response: {chatId, name, color, lastMessageAt, roomId, joinCode, type}
  Future<Map<String, dynamic>> joinRoom(String campId, String code) async {
    final response = await _client.post(_endpoints.joinRoom(campId, code));
    return response.jsonOrThrow['data'] as Map<String, dynamic>;
  }

  /// Create a new room
  /// POST /camps/:id/rooms
  /// Request: {name, color, joinCode (optional)}
  /// Response: {chatId, name, color, roomId, joinCode, type}
  Future<Map<String, dynamic>> createRoom({
    required String campId,
    required String name,
    required String color,
    String? joinCode,
  }) async {
    final response = await _client.post(
      _endpoints.createRoom(campId),
      body: {
        'name': name,
        'color': color,
        if (joinCode != null) 'joinCode': joinCode,
      },
    );
    return response.jsonOrThrow['data'] as Map<String, dynamic>;
  }

  /// Update room details
  /// PATCH /camps/:id/rooms/:roomId
  /// Request: {name (optional), color (optional), joinCode (optional)}
  /// Response: {chatId, name, color, lastMessageAt, lastSeenAt, roomId, joinCode, type}
  Future<Map<String, dynamic>> updateRoom({
    required String campId,
    required String roomId,
    String? name,
    String? color,
    String? joinCode,
  }) async {
    final response = await _client.patch(
      _endpoints.updateRoom(campId, roomId),
      body: {
        if (name != null) 'name': name,
        if (color != null) 'color': color,
        if (joinCode != null) 'joinCode': joinCode,
      },
    );
    return response.jsonOrThrow['data'] as Map<String, dynamic>;
  }

  /// Leave a room
  /// POST /camps/:id/rooms/leave
  /// Response: true / false + msg
  Future<bool> leaveRoom(String campId) async {
    final response = await _client.delete(_endpoints.leaveRoom(campId));
    return response.jsonOrThrow['data']['chatDeleted'] as bool;
  }

  // ==================== GROUP OPERATIONS ====================

  /// Join a group by code
  /// POST /camps/:id/groups/:code
  /// Response: {chatId, name, color, lastMessageAt, groupId, joinCode, type}
  Future<Map<String, dynamic>> joinGroup(String campId, String code) async {
    final response = await _client.post(_endpoints.joinGroup(campId, code));
    return response.jsonOrThrow['data'] as Map<String, dynamic>;
  }

  /// Create a new group
  /// POST /camps/:id/groups
  /// Request: {name, color, joinCode (optional)}
  /// Response: {chatId, name, color, groupId, joinCode, type}
  Future<Map<String, dynamic>> createGroup({
    required String campId,
    required String name,
    required String color,
    String? joinCode,
  }) async {
    final response = await _client.post(
      _endpoints.createGroup(campId),
      body: {
        'name': name,
        'color': color,
        if (joinCode != null) 'joinCode': joinCode,
      },
    );
    return response.jsonOrThrow['data'] as Map<String, dynamic>;
  }

  /// Update group details
  /// PATCH /camps/:id/groups/:groupId
  /// Request: {name (optional), color (optional), joinCode (optional)}
  /// Response: {chatId, name, color, lastMessageAt, lastSeenAt, groupId, joinCode, type}
  Future<Map<String, dynamic>> updateGroup({
    required String campId,
    required String groupId,
    String? name,
    String? color,
    String? joinCode,
  }) async {
    final response = await _client.patch(
      _endpoints.updateGroup(campId, groupId),
      body: {
        if (name != null) 'name': name,
        if (color != null) 'color': color,
        if (joinCode != null) 'joinCode': joinCode,
      },
    );
    return response.jsonOrThrow['data'] as Map<String, dynamic>;
  }

  /// Leave a group
  /// DELETE /camps/:id/groups/leave
  /// Response: true / false + msg
  Future<bool> leaveGroup(String campId) async {
    final response = await _client.delete(_endpoints.leaveGroup(campId));
    return response.jsonOrThrow['data']['chatDeleted'] as bool;
  }

  // ==================== CHAT OPERATIONS ====================

  /// Leave a specific chat
  /// DELETE /camps/:id/chats/:chatId/leave
  /// Response: true / false + msg
  Future<bool> leaveChat(String campId, String chatId) async {
    final response = await _client.delete(_endpoints.leaveChat(campId, chatId));
    return response.jsonOrThrow['data'] as bool;
  }

  /// Get all chats for a specific camp
  /// GET /camps/:id/chats
  /// Response: [{chatId, name, color, lastMessageAt, lastSeenAt, groupId, roomId, joinCode, type}]
  Future<List<Map<String, dynamic>>> getMyCampChats(String campId) async {
    final response = await _client.get(_endpoints.getMyCampChats(campId));
    final data = response.jsonOrThrow['data'];

    if (data is! List) {
      throw Exception('Invalid response format: expected List');
    }

    return data.cast<Map<String, dynamic>>();
  }
}
