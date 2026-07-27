import 'dart:typed_data';

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

  /// 갤러리에서 이미지를 선택하고 bytes를 반환한다. 상태는 변경하지 않는다.
  /// 사용자가 선택을 취소하거나 읽기 실패 시 null 반환.
  Future<Uint8List?> pickForPreview() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return null;
      return await picked.readAsBytes();
    } catch (e) {
      _logger.e('이미지 선택 실패', error: e);
      return null;
    }
  }

  /// 확인된 이미지 bytes로 OCR을 실행한다.
  Future<void> analyzeImage(
    Uint8List bytes, {
    Map<String, List<String>>? storeSpaceMap,
  }) async {
    final myGeneration = ++_generation;
    state = const AsyncLoading();
    try {
      final result = await ref
          .read(reservationOcrUseCaseProvider)
          .execute(bytes, storeSpaceMap: storeSpaceMap);
      if (_generation != myGeneration || !ref.mounted) return;
      final stackTrace = StackTrace.current;
      result.fold(
        (e) {
          _logger.e('OCR 실패', error: e);
          state = AsyncError(e, stackTrace);
        },
        (ocrResult) => state = AsyncData(ocrResult),
      );
    } catch (e, st) {
      if (_generation != myGeneration || !ref.mounted) return;
      _logger.e('OCR 분석 실패', error: e, stackTrace: st);
      state = AsyncError(OcrUnknownException(e.toString()), st);
    }
  }

  void cancel() {
    _generation++;
    state = const AsyncData(null);
  }
}
