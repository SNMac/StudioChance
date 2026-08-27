import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/data/repositories/notification_repository_impl.dart';
import 'package:studio_chance/domain/use_cases/notification_use_case.dart';

part 'notification_use_case_provider.g.dart';

@Riverpod(keepAlive: true)
NotificationUseCase notificationUseCase(Ref ref) {
  return NotificationUseCaseImpl(
    notificationRepository: ref.watch(notificationRepositoryProvider),
  );
}
