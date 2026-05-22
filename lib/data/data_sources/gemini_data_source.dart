import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/data/models/reservation_ocr_result_model.dart';

part 'gemini_data_source.g.dart';

abstract interface class GeminiDataSource {
  Future<ReservationOcrResultModel> analyzeReservationImage(
    Uint8List imageBytes,
  );
}

class GeminiDataSourceImpl implements GeminiDataSource {
  late final GenerativeModel _model;

  GeminiDataSourceImpl() {
    _model = FirebaseAI.vertexAI().generativeModel(
      model: 'gemini-2.0-flash',
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );
  }

  static const _prompt = '''이 이미지는 공간 예약 플랫폼의 예약 확인 스크린샷입니다.
다음 JSON 형식으로 예약 정보를 추출하세요.
추출할 수 없는 값은 null로 반환하세요.

{
  "platform": "NAVER | SPACECLOUD | YANOLJA | OTHER",
  "customerName": "예약자 이름",
  "customerPhone": "숫자만 (예: 01012345678)",
  "startTime": "ISO 8601 (예: 2026-05-22T14:00:00)",
  "endTime": "ISO 8601 또는 null",
  "isAllDay": false,
  "headCount": 2,
  "memo": "요청사항 또는 null"
}''';

  static String _detectMimeType(Uint8List bytes) {
    if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xD8) {
      return 'image/jpeg';
    }
    if (bytes.length >= 4 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'image/png';
    }
    return 'image/jpeg'; // fallback
  }

  @override
  Future<ReservationOcrResultModel> analyzeReservationImage(
    Uint8List imageBytes,
  ) async {
    final response = await _model.generateContent([
      Content.multi([
        InlineDataPart(_detectMimeType(imageBytes), imageBytes),
        TextPart(_prompt),
      ]),
    ]);
    final jsonString = response.text ?? '{}';
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return ReservationOcrResultModel.fromJson(json);
  }
}

@Riverpod(keepAlive: true)
GeminiDataSource geminiDataSource(Ref ref) {
  return GeminiDataSourceImpl();
}
