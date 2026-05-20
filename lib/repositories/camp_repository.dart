import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/data/db/camp_dao.dart';
import 'package:mastercs_mobile/data/api/requests/camp_api.dart';

final campRepositoryProvider = Provider<CampRepository>((ref) {
  final campDao = ref.watch(campDaoProvider);
  final campApi = ref.watch(campApiProvider);
  return CampRepository(campDao, campApi);
});

class CampRepository {
  final CampDao _dao;
  final CampApi _api;

  CampRepository(this._dao, this._api);

  /// Check if a camp is pending selection (e.g., during sync)
  Future<bool> pendingCamp(String campId) async {
    final camp = await _dao.getCampByRemoteId(campId);
    return camp?.myRole == 'Pending';
  }

  /// Get camp by local ID from database
  Future<Camp?> getCampById(String remoteId) async {
    return await _dao.getCampByRemoteId(remoteId);
  }

  /// Update camp details
  Future<void> updateCamp({
    required String id,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    int? minGroupSize,
    String? joinCode,
  }) async {
    try {
      final camp = await getCampById(id);

      if (camp == null) {
        throw Exception('Camp not found');
      }

      final newcamp = camp.copyWith(
        name: name,
        startDate: startDate != null ? Value(startDate) : Value(camp.startDate),
        endDate: endDate != null ? Value(endDate) : Value(camp.endDate),
        minGroupSize: minGroupSize != null
            ? Value(minGroupSize)
            : Value(camp.minGroupSize),
        joinCode: joinCode != null ? Value(joinCode) : Value(camp.joinCode),
      );

      await _api.updateCamp(
        campId: camp.remoteId,
        name: name,
        startDate: startDate,
        endDate: endDate,
        minGroupSize: minGroupSize,
        joinCode: joinCode,
      );

      await _dao.upsertCamp(newcamp);
    } catch (e) {
      rethrow;
    }
  }

  /// Leave camp
  Future<void> leaveCamp(String id) async {
    try {
      final camp = await getCampById(id);
      if (camp == null) {
        throw Exception('Camp not found');
      }
      await _api.leaveCamp(camp.remoteId);
      await _dao.deleteCamp(id);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete camp (owner only)
  Future<void> deleteCamp(String id) async {
    try {
      await _api.deleteCamp(id);
      await _dao.deleteCamp(id);
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch camps from server and save to database
  Future<List<Camp>> fetchAndSaveCampsFromServer() async {
    try {
      final campsData = await _api.getMyCamps();

      final camps = campsData.map((campJson) {
        return Camp(
          remoteId: campJson['id'],
          name: campJson['name'] ?? '',
          startDate: campJson['startDate'] != null
              ? DateTime.parse(campJson['startDate'])
              : null,
          endDate: campJson['endDate'] != null
              ? DateTime.parse(campJson['endDate'])
              : null,
          minGroupSize: campJson['minGroupSize'],
          chatRemoteId: campJson['campChatId'],
          joinCode: campJson['joinCode'],
          staffChatRemoteId: campJson['staffChatId'] ?? '',
          myRole: campJson['role'],
        );
      }).toList();

      // Save to local database
      if (camps.isNotEmpty) {
        await saveCampsToLocal(camps);
      }

      return camps;
    } catch (e) {
      rethrow;
    }
  }

  /// Save multiple camps to local database
  Future<void> saveCampsToLocal(List<Camp> camps) async {
    await _dao.deleteExcept(camps.map((c) => c.remoteId).toList());
    await _dao.upsertCamps(camps);
  }

  /// Create a new camp
  Future<Camp> createCamp({
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    int? minGroupSize,
    String? joinCode,
  }) async {
    try {
      final data = await _api.createCamp(
        name: name,
        startDate: startDate,
        endDate: endDate,
        minGroupSize: minGroupSize,
        joinCode: joinCode,
      );
      final camp = Camp(
        remoteId: data['id'],
        name: data['name'] ?? '',
        startDate: data['startDate'] != null
            ? DateTime.parse(data['startDate'])
            : null,
        endDate: data['endDate'] != null
            ? DateTime.parse(data['endDate'])
            : null,
        minGroupSize: data['minGroupSize'],
        chatRemoteId: data['campChatId'],
        joinCode: data['joinCode'],
        staffChatRemoteId: data['staffChatId'],
        myRole: "Owner",
      );

      // Save to local database
      await _dao.upsertCamp(camp);

      return camp;
    } catch (e) {
      rethrow;
    }
  }

  /// Join camp by code
  Future<Camp> joinCamp(String code) async {
    try {
      final data = await _api.joinCamp(code);

      final camp = Camp(
        remoteId: data['campId'],
        name: data['campName'],
        startDate: data['startDate'] != null
            ? DateTime.parse(data['startDate'])
            : null,
        endDate: data['endDate'] != null
            ? DateTime.parse(data['endDate'])
            : null,
        minGroupSize: data['minGroupSize'],
        chatRemoteId: data['chatId'],
        joinCode: data['joinCode'],
        staffChatRemoteId: data['staffChatId'],
        myRole: 'Pending',
      );

      // Save to local database
      await _dao.upsertCamp(camp);

      return camp;
    } catch (e) {
      rethrow;
    }
  }

  /// Refresh all camps data from server
  Future<void> refreshCamps() async {
    try {
      final campsData = await _api.getMyCamps();
      final camps = campsData.map((campJson) {
        return Camp(
          remoteId: campJson['campId'],
          name: campJson['campName'],
          startDate: campJson['startDate'] != null
              ? DateTime.parse(campJson['startDate'])
              : null,
          endDate: campJson['endDate'] != null
              ? DateTime.parse(campJson['endDate'])
              : null,

          minGroupSize: campJson['minGroupSize'],
          chatRemoteId: campJson['campChatId'],
          joinCode: campJson['joinCode'],
          staffChatRemoteId: campJson['staffChatId'],
          myRole: campJson['role'],
        );
      }).toList();

      // Save to local database
      if (camps.isNotEmpty) {
        await saveCampsToLocal(camps);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refreshMyCamp(String campId) async {
    try {
      final remoteCamp = await _api.getCamp(campId);

      await _dao.upsertCamp(
        Camp(
          remoteId: remoteCamp['campId'],
          name: remoteCamp['campName'] ?? '',
          startDate: remoteCamp['startDate'] != null
              ? DateTime.parse(remoteCamp['startDate'])
              : null,
          endDate: remoteCamp['endDate'] != null
              ? DateTime.parse(remoteCamp['endDate'])
              : null,
          minGroupSize: remoteCamp['minGroupSize'],
          chatRemoteId: remoteCamp['campChatId'],
          joinCode: remoteCamp['joinCode'],
          staffChatRemoteId: remoteCamp['staffChatId'],
          myRole: remoteCamp['role'],
        ),
      );
    } catch (e) {
      // Handle error silently, keep local data
      rethrow;
    }
  }

  /// Clear all camps from local database
  Future<void> clearAllCamps() async {
    await _dao.deleteAllCamps();
  }

  /// Download join QR code and persist it as a temporary PNG file.
  Future<File> downloadJoinQrCodePng(String campId) async {
    final bytes = await _api.downloadJoinQrCode(campId);

    if (bytes.isEmpty) {
      throw Exception('Received empty QR code image data');
    }

    final tempDir = await getTemporaryDirectory();
    final filename =
        'camp_${campId}_join_qr_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File(p.join(tempDir.path, filename));

    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}
