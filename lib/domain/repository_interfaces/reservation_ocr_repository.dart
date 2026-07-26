import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';
import 'package:studio_chance/domain/entities/reservation_ocr_result.dart';

abstract interface class ReservationOcrRepository {
  Future<Either<Exception, ReservationOcrResult>> analyzeReservationImage(
    Uint8List imageBytes, {
    Map<String, List<String>>? storeSpaceMap,
  });
}
