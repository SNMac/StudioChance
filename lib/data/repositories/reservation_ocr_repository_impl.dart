import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/common/exceptions/ocr_exceptions.dart';
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
      final exception = switch (e) {
        FirebaseException(code: final code)
            when code == 'unavailable' ||
                code == 'deadline-exceeded' ||
                code == 'network-request-failed' =>
          OcrNetworkException(e.toString(), code: code),
        FormatException() || TypeError() =>
          OcrParsingException(e.toString()),
        _ => OcrUnknownException(e.toString()),
      };
      return left(exception);
    }
  }
}

@Riverpod(keepAlive: true)
ReservationOcrRepository reservationOcrRepository(Ref ref) {
  return ReservationOcrRepositoryImpl(
    geminiDataSource: ref.watch(geminiDataSourceProvider),
  );
}
