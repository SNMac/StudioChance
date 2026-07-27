import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/use_cases/store_use_case_provider.dart';

part 'store_detail_provider.g.dart';

@riverpod
Future<Store?> storeDetail(Ref ref, String storeId) async {
  final result = await ref.watch(storeUseCaseProvider).getStore(storeId);
  return result.fold((_) => null, (store) => store);
}
