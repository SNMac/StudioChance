/// 점포를 내 화면에서 부르는 이름 규칙. 점포 별명이 있으면 별명, 없으면 점포 이름이다
/// (CONTEXT.md "점포 별명")
mixin StoreNaming {
  /// 관리자가 정한 점포 이름. 고객에게 보내는 안내문처럼 다른 사람이 읽는 곳에 쓴다
  String get name;

  /// 내가 붙인 점포 별명. 없으면 null
  String? get alias;

  /// 내 화면에 보이는 점포 이름
  String get displayName => alias ?? name;
}
