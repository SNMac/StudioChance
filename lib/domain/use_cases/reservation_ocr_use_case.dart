import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';
import 'package:studio_chance/domain/entities/reservation_ocr_result.dart';
import 'package:studio_chance/domain/repository_interfaces/reservation_ocr_repository.dart';

abstract interface class ReservationOcrUseCase {
  Future<Either<Exception, ReservationOcrResult>> execute(
    Uint8List imageBytes, {
    Map<String, List<String>>? storeSpaceMap,
  });
}

class ReservationOcrUseCaseImpl implements ReservationOcrUseCase {
  final ReservationOcrRepository _repository;

  const ReservationOcrUseCaseImpl({required ReservationOcrRepository repository})
      : _repository = repository;

  @override
  Future<Either<Exception, ReservationOcrResult>> execute(
    Uint8List imageBytes, {
    Map<String, List<String>>? storeSpaceMap,
  }) async {
    return _repository.analyzeReservationImage(
      imageBytes,
      storeSpaceMap: storeSpaceMap,
    );
  }
}
