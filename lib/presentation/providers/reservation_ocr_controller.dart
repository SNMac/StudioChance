import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/common/exceptions/ocr_exceptions.dart';
import 'package:studio_chance/domain/entities/reservation_ocr_result.dart';
import 'package:studio_chance/domain/use_cases/reservation_ocr_use_case_provider.dart';

part 'reservation_ocr_controller.g.dart';

@riverpod
class ReservationOcrController extends _$ReservationOcrController {
  final _logger = Logger();
  final _picker = ImagePicker();
  int _generation = 0;

  @override
  FutureOr<ReservationOcrResult?> build() => null;

  Future<void> extractFromImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    final myGeneration = ++_generation;
    state = const AsyncLoading();
    try {
      final bytes = await picked.readAsBytes();
      if (_generation != myGeneration) return;
      final result =
          await ref.read(reservationOcrUseCaseProvider).execute(bytes);
      if (_generation != myGeneration) return;
      result.fold(
        (e) {
          _logger.e('OCR 실패', error: e);
          state = AsyncError(e, StackTrace.current);
        },
        (ocrResult) => state = AsyncData(ocrResult),
      );
    } catch (e) {
      if (_generation != myGeneration) return;
      _logger.e('OCR 이미지 읽기 실패', error: e);
      state = AsyncError(OcrUnknownException(e.toString()), StackTrace.current);
    }
  }

  void cancel() {
    _generation++;
    state = const AsyncData(null);
  }
}
