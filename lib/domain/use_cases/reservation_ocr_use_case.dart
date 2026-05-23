import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';
import 'package:studio_chance/common/exceptions/ocr_exceptions.dart';
import 'package:studio_chance/domain/entities/reservation_ocr_result.dart';
import 'package:studio_chance/domain/repository_interfaces/reservation_ocr_repository.dart';

abstract interface class ReservationOcrUseCase {
  Future<Either<Exception, ReservationOcrResult>> execute(Uint8List imageBytes);
}

class ReservationOcrUseCaseImpl implements ReservationOcrUseCase {
  final ReservationOcrRepository _repository;

  const ReservationOcrUseCaseImpl({required ReservationOcrRepository repository})
      : _repository = repository;

  @override
  Future<Either<Exception, ReservationOcrResult>> execute(
    Uint8List imageBytes,
  ) async {
    final result = await _repository.analyzeReservationImage(imageBytes);
    return result.fold(
      left,
      (ocrResult) {
        if (ocrResult.customerName == null &&
            ocrResult.customerPhone == null &&
            ocrResult.startTime == null) {
          return left(OcrParsingException('핵심 필드 미추출'));
        }
        return right(ocrResult);
      },
    );
  }
}
