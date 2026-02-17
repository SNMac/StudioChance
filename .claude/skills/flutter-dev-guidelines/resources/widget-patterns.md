# 위젯 패턴 상세

## 목차
- [위젯 타입 선택 기준](#위젯-타입-선택-기준)
- [화면 구성 공식](#화면-구성-공식)
- [ref.listen 패턴](#reflisten-패턴)
- [로컬 핸들러 함수](#로컬-핸들러-함수)
- [PopScope 뒤로가기 제어](#popscope-뒤로가기-제어)
- [Controller Interface + Mixin 패턴](#controller-interface--mixin-패턴)

---

## 위젯 타입 선택 기준

### ConsumerWidget (기본값)

Riverpod 상태만 읽는 화면:

```dart
class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(signInControllerProvider);
    // ...
  }
}
```

### ConsumerStatefulWidget

TextEditingController, FocusNode 등 Flutter 로컬 상태가 필요한 화면:

```dart
class InviteCodeInputScreen extends ConsumerStatefulWidget {
  const InviteCodeInputScreen({super.key});

  @override
  ConsumerState<InviteCodeInputScreen> createState() =>
      _InviteCodeInputScreenState();
}

class _InviteCodeInputScreenState extends ConsumerState<InviteCodeInputScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(controllerProvider);
    // ...
  }
}
```

### StatelessWidget

순수 재사용 위젯 (상태 없음):

```dart
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  const LoadingOverlay({super.key, required this.isLoading});
  // ...
}
```

### StatefulWidget

Riverpod 불필요, Flutter 로컬 상태만 필요:

```dart
class BodyTextField extends StatefulWidget { ... }
class _BodyTextFieldState extends State<BodyTextField> {
  late final FocusNode _focusNode;
  // ...
}
```

---

## 화면 구성 공식

### 기본 구조

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  // 1. ref.listen (사이드 이펙트)
  ref.listen(controllerProvider, (previous, next) { ... });

  // 2. ref.watch (상태 읽기)
  final state = ref.watch(controllerProvider);
  final isLoading = state is AsyncLoading;

  // 3. 로컬 핸들러 함수 정의
  void onSubmit() { ... }

  // 4. UI 반환
  return Scaffold(
    appBar: CustomAppBar(
      title: '화면 제목',
      leading: AppBarNaviBackButton(isEnabled: !isLoading),
      actions: [
        AppBarActionButton(
          label: '다음',
          onPressed: canSubmit && !isLoading ? onSubmit : null,
        ),
      ],
    ),
    body: PopScope(
      canPop: !isLoading,
      child: Stack(
        children: [
          SafeAreaWithPadding(
            child: Column(children: [...]),
          ),
          LoadingOverlay(isLoading: isLoading),
        ],
      ),
    ),
  );
}
```

### 핵심 요소

- `CustomAppBar`: iOS/Android 높이 대응
- `PopScope`: 로딩 중 뒤로가기 방지
- `Stack` + `LoadingOverlay`: 로딩 오버레이
- `SafeAreaWithPadding`: SafeArea + 표준 패딩

---

## ref.listen 패턴

### AsyncValue 에러 처리

```dart
ref.listen(controllerProvider, (previous, next) {
  next.whenOrNull(
    error: (error, stackTrace) {
      if (error is AppException) {
        showCustomAlertDialog(
          context: context,
          title: error.title,
          content: error.content,
          showCancel: false,
        );
      }
    },
  );
});
```

### 성공 시 네비게이션

```dart
ref.listen(controllerProvider, (previous, next) {
  next.whenOrNull(
    data: (value) {
      if (value != null) {
        SCRoute.home.pushChild(context);
      }
    },
    error: (error, _) { ... },
  );
});
```

### 무음 에러 처리 (AuthCancelledException 등)

```dart
ref.listen(signInControllerProvider, (previous, next) {
  next.when(
    data: (_) {},
    error: (error, stackTrace) {
      if (error is AuthException && error.isSilentable) return; // 무시
      showErrorDialog(error);
    },
    loading: () {},
  );
});
```

---

## 로컬 핸들러 함수

이벤트 핸들러는 `build()` 내부에 로컬 함수로 정의:

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  void showErrorDialog(String title, String content) {
    showCustomAlertDialog(context: context, title: title, content: content);
  }

  void onGoogleButtonTapped() {
    ref.read(signInControllerProvider.notifier).signInWithGoogle();
  }

  void onAppleButtonTapped() {
    ref.read(signInControllerProvider.notifier).signInWithApple();
  }

  return Column(children: [
    ElevatedButton(onPressed: onGoogleButtonTapped, child: Text('Google')),
    ElevatedButton(onPressed: onAppleButtonTapped, child: Text('Apple')),
  ]);
}
```

---

## PopScope 뒤로가기 제어

### 로딩 중 뒤로가기 방지

```dart
PopScope(
  canPop: !isLoading,
  onPopInvokedWithResult: (didPop, result) {
    if (didPop || isLoading) return;
    if (context.mounted && context.canPop()) context.pop();
  },
  child: ...
)
```

### 커스텀 뒤로가기 동작 (온보딩 등)

```dart
PopScope(
  canPop: widget.enableBackGesture,
  onPopInvokedWithResult: (didPop, result) {
    if (didPop) return;
    _handleCustomBack();
  },
  child: ...
)
```

---

## Controller Interface + Mixin 패턴

폼 로직을 재사용할 때 (생성/수정 화면 공유):

```dart
// 인터페이스 정의
abstract interface class StoreFormControllerable {
  void setName(String name);
  void setAddress(String address);
  Future<void> submit();
}

// 기본 구현 Mixin
mixin StoreFormMixin {
  StoreFormState get state;
  set state(StoreFormState value);

  void setName(String name) => state = state.copyWith(name: name);
  void setAddress(String address) => state = state.copyWith(address: address);
}

// Controller에서 사용
@riverpod
class StoreCreationController extends _$StoreCreationController
    with StoreFormMixin
    implements StoreFormControllerable {
  @override
  StoreFormState build() => const StoreFormState();

  @override
  Future<void> submit() async { ... } // 생성 로직
}
```
