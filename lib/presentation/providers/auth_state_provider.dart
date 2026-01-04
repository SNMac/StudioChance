import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/domain/usecases/auth_use_case.dart';

part 'auth_state_provider.g.dart';

@Riverpod(keepAlive: true)
Stream<User?> authState(Ref ref) {
  return ref.watch(authUseCaseProvider).authStateChanges();
}