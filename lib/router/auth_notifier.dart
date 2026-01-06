import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_chance/presentation/providers/auth_state_provider.dart';

class AuthNotifier extends ChangeNotifier {
  AuthNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, _) {
      notifyListeners();
    });
  }
}
