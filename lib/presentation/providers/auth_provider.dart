import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/domain/entities/auth_info.dart';
import 'package:studio_chance/domain/use_cases/auth_use_case_provider.dart';

part 'auth_provider.g.dart';

@riverpod
Stream<AuthInfo?> authStateChanges(Ref ref) {
  return ref.watch(authUseCaseProvider).authStateChanges();
}
