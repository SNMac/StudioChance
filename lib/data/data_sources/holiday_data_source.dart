import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/exceptions/holiday_exceptions.dart';
import 'package:studio_chance/data/data_sources/firestore_data_source_base.dart';
import 'package:studio_chance/data/models/holiday_year_model.dart';

part 'holiday_data_source.g.dart';

abstract interface class HolidayDataSource {
  /// [years]의 `holidays/{year}` 문서 조회. 문서가 없는 연도는 결과에서 빠진다.
  Future<Map<int, HolidayYearModel>> getHolidayYears(Set<int> years);
}

class HolidayFirestoreDataSource extends FirestoreDataSourceBase
    implements HolidayDataSource {
  final FirebaseFirestore _firestore;

  HolidayFirestoreDataSource(this._firestore);

  @override
  String get errorLogTag => 'Holiday Firestore Error';

  @override
  bool isDomainException(Object e) => e is HolidayException;

  @override
  Exception buildParsingException(String message) =>
      HolidayDataParsingException(message: message);

  @override
  Exception mapFirebaseCode(String code, String message) => switch (code) {
    'permission-denied' || 'unauthenticated' =>
      HolidayPermissionDeniedException(message: message, code: code),
    'unavailable' || 'deadline-exceeded' => HolidayNetworkException(
      message: message,
      code: code,
    ),
    _ => HolidayUnknownException(message: message, code: code),
  };

  @override
  Future<Map<int, HolidayYearModel>> getHolidayYears(Set<int> years) async {
    try {
      final yearList = years.toList();
      final snapshots = await Future.wait([
        for (final year in yearList)
          _firestore.collection('holidays').doc('$year').get(),
      ]);

      return {
        for (final (index, snapshot) in snapshots.indexed)
          if (snapshot.data() case final data?)
            yearList[index]: HolidayYearModel.fromJson(data),
      };
    } catch (e, stackTrace) {
      throw handleFirestoreError(e, stackTrace);
    }
  }
}

@Riverpod(keepAlive: true)
HolidayDataSource holidayDataSource(Ref ref) {
  return HolidayFirestoreDataSource(FirebaseFirestore.instance);
}
