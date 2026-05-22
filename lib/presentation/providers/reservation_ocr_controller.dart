import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/domain/entities/reservation_ocr_result.dart';
import 'package:studio_chance/domain/use_cases/reservation_ocr_use_case_provider.dart';

part 'reservation_ocr_controller.g.dart';

@riverpod
class ReservationOcrController extends _$ReservationOcrController {
  final _logger = Logger();
  final _picker = ImagePicker();

  @override
  FutureOr<ReservationOcrResult?> build() => null;

  Future<void> extractFromImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    state = const AsyncLoading();
    final bytes = await picked.readAsBytes();
    final result =
        await ref.read(reservationOcrUseCaseProvider).execute(bytes);
    result.fold(
      (e) {
        _logger.e('OCR 실패', error: e);
        state = AsyncError(e, StackTrace.current);
      },
      (ocrResult) => state = AsyncData(ocrResult),
    );
  }
}
