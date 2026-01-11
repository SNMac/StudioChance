import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';

class AuthStreamListenable extends ChangeNotifier {
  AuthStreamListenable(Ref ref) {
    ref.listen(appAuthControllerProvider, (previous, next) {
      notifyListeners();
    });
  }
}
