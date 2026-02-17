# UI 공통 컴포넌트 상세

## 목차
- [색상 시스템](#색상-시스템)
- [CustomAppBar](#customappbar)
- [AppBar 버튼](#appbar-버튼)
- [SafeAreaWithPadding](#safeareawithpadding)
- [LoadingOverlay](#loadingoverlay)
- [GroupedFormContainer](#groupedformcontainer)
- [BodyTextField](#bodytextfield)
- [showCustomAlertDialog](#showcustomalertdialog)
- [상수 값](#상수-값)
- [테마 / 폰트](#테마--폰트)

---

## 색상 시스템

`CupertinoColors`를 사용한 적응형 색상. `context` Extension으로 접근:

```dart
// lib/presentation/commons/extensions/context_colors.dart
extension ContextColors on BuildContext {
  Color get label => CupertinoDynamicColor.resolve(CupertinoColors.label, this);
  Color get secondaryLabel => CupertinoDynamicColor.resolve(CupertinoColors.secondaryLabel, this);
  Color get tertiaryLabel => CupertinoDynamicColor.resolve(CupertinoColors.tertiaryLabel, this);
  Color get quaternaryLabel => CupertinoDynamicColor.resolve(CupertinoColors.quaternaryLabel, this);
  Color get systemBackground => CupertinoDynamicColor.resolve(CupertinoColors.systemBackground, this);
  Color get secondarySystemBackground => ...;
  Color get secondarySystemGroupedBackground => ...;
  Color get separator => CupertinoDynamicColor.resolve(CupertinoColors.separator, this);
  Color get systemRed => CupertinoDynamicColor.resolve(CupertinoColors.systemRed, this);
  Color get systemBlue => CupertinoDynamicColor.resolve(CupertinoColors.systemBlue, this);
  // ... 등
}

// 사용
Text('제목', style: TextStyle(color: context.label));
Container(color: context.secondarySystemGroupedBackground);
```

브랜드 색상 (비적응형)은 `lib/presentation/commons/extensions/colors.dart`에 `const Color`로 정의.

---

## CustomAppBar

iOS/Android 높이에 대응하는 앱바:

```dart
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.leading = const AppBarNaviBackButton(),
    this.actions,
  });

  @override
  Size get preferredSize =>
    Size.fromHeight(Platform.isIOS ? 44.0 : kToolbarHeight);
}
```

사용:
```dart
appBar: CustomAppBar(
  title: '화면 제목',
  leading: AppBarNaviBackButton(isEnabled: !isLoading),
  actions: [
    AppBarActionButton(
      label: '저장',
      onPressed: canSave ? onSave : null,
    ),
  ],
),
```

---

## AppBar 버튼

### AppBarNaviBackButton (네비게이션 뒤로가기)

```dart
const AppBarNaviBackButton({this.isEnabled = true})
// < 아이콘, isEnabled=false이면 quaternaryLabel 색상
```

### AppBarModalBackButton (모달 닫기)

```dart
const AppBarModalBackButton({this.isEnabled = true})
// × 아이콘
```

### AppBarActionButton (우측 텍스트 버튼)

```dart
AppBarActionButton(
  label: '다음',
  onPressed: canProceed ? onNext : null, // null이면 비활성화 (quaternaryLabel)
)
```

---

## SafeAreaWithPadding

```dart
class SafeAreaWithPadding extends StatelessWidget {
  final Widget child;
  const SafeAreaWithPadding({super.key, required this.child});
  // SafeArea + Padding(horizontal: horizontalPadding)
}
```

---

## LoadingOverlay

전체 화면 반투명 오버레이 + 로딩 인디케이터:

```dart
LoadingOverlay(isLoading: isLoading)
// AnimatedSwitcher로 부드럽게 표시/숨김
// CircularProgressIndicator.adaptive() 사용
```

화면 구성에서 항상 `Stack`의 마지막 자식으로 배치:

```dart
Stack(
  children: [
    SafeAreaWithPadding(child: ...),
    LoadingOverlay(isLoading: isLoading), // 항상 마지막
  ],
)
```

---

## GroupedFormContainer

iOS 설정 스타일의 그룹 폼:

```dart
GroupedFormContainer(
  header: '매장 정보',
  footer: '매장 이름은 나중에 변경할 수 있습니다.',
  children: [
    BodyTextField(placeholder: '매장 이름', ...),
    BodyTextField(placeholder: '주소', ...),
  ],
)
// children 사이에 자동으로 Divider 추가
// secondarySystemGroupedBackground 배경색
// formBorderRadius(12.0) 둥근 모서리
```

---

## BodyTextField

CupertinoTextField.borderless 래퍼:

```dart
BodyTextField(
  placeholder: '닉네임을 입력하세요',
  controller: _controller,
  maxLength: 10,
  keyboardType: TextInputType.text,
  textInputAction: TextInputAction.done,
  onChanged: (value) => notifier.setName(value),
)
// 내장: FocusNode 관리, clear 버튼, 포커스 시 스타일 변경
```

---

## showCustomAlertDialog

적응형 알림 다이얼로그 (iOS: CupertinoAlertDialog, Android: MaterialAlertDialog):

```dart
showCustomAlertDialog(
  context: context,
  title: '삭제하시겠습니까?',
  content: '이 작업은 되돌릴 수 없습니다.',
  showCancel: true,                    // 취소 버튼 표시
  confirmLabel: '삭제',                // 기본값: '확인'
  isDestructive: true,                 // 확인 버튼 빨간색
  onBeforeConfirmPop: () async {       // 확인 전 비동기 작업
    await deleteItem();
  },
  onAfterConfirmPop: () {              // 확인 후 작업
    Navigator.pop(context);
  },
);
```

---

## 상수 값

```dart
// lib/constants/ui_constants.dart
const double inputFormComponentHeight = 48.0;
const double verticalPadding = 32.0;
const double horizontalPadding = 16.0;
const double formBorderRadius = 12.0;

// lib/constants/data_constants.dart
const int storeInviteCodeAvailableMin = 15;
const int userSoftDeleteDays = 7;
const int storeSoftDeleteDays = 7;
const int holidayValue = 8;
const int emptyValue = -1;
```

최상위 `const` 값으로 정의, 클래스에 감싸지 않음.

---

## 테마 / 폰트

```dart
// MyApp에서 설정
MaterialApp.router(
  themeMode: ThemeMode.system,
  theme: ThemeData(
    useMaterial3: true,
    fontFamily: 'Pretendard',
    // textTheme: headlineLarge(24, bold) ~ labelSmall(10, normal)
  ),
  darkTheme: ThemeData(useMaterial3: true, ...),
)
```

- 폰트: **Pretendard** (400, 500, 600, 700)
- 보조 폰트: **Roboto** (500) - 특정 용도
- Material 3 디자인 시스템
- 키보드 자동 해제: `GestureDetector.onTap` → `FocusManager.instance.primaryFocus?.unfocus()`
