import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/data/db/location_dao.dart';

class BackgroundLocalDatabaseService {
  final LocationDao _dao;

  BackgroundLocalDatabaseService(this._dao);

  Future<void> saveLocation({
    required String userId,
    required String campId,
    required double latitude,
    required double longitude,
  }) {
    return _dao.upsertLocation(
      Location(
        userRemoteId: userId,
        campRemoteId: campId,
        latitude: latitude,
        longitude: longitude,
        lastUpdated: DateTime.now(),
      ),
    );
  }
}
