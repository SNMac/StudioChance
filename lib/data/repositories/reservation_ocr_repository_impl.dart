import 'dart:typed_data';
import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/common/utils/exception_utils.dart';
import 'package:studio_chance/data/data_sources/gemini_data_source.dart';
import 'package:studio_chance/domain/entities/reservation_ocr_result.dart';
import 'package:studio_chance/domain/repository_interfaces/reservation_ocr_repository.dart';

part 'reservation_ocr_repository_impl.g.dart';

class ReservationOcrRepositoryImpl implements ReservationOcrRepository {
  final Logger _logger = Logger();
  final GeminiDataSource _geminiDataSource;

  ReservationOcrRepositoryImpl({required GeminiDataSource geminiDataSource})
      : _geminiDataSource = geminiDataSource;

  @override
  Future<Either<Exception, ReservationOcrResult>> analyzeReservationImage(
    Uint8List imageBytes,
  ) async {
    try {
      final model = await _geminiDataSource.analyzeReservationImage(imageBytes);
      return right(model.toEntity());
    } catch (e) {
      _logger.e('OCR 분석 실패', error: e);
      return left(toException(e));
    }
  }
}

@Riverpod(keepAlive: true)
ReservationOcrRepository reservationOcrRepository(Ref ref) {
  return ReservationOcrRepositoryImpl(
    geminiDataSource: ref.watch(geminiDataSourceProvider),
  );
}
