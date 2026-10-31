extension StoreDeletionFormatter on DateTime {
  /// 삭제 예정 점포가 완전히 지워질 때까지 남은 기간 (이 [DateTime]이 기한이다)
  /// - 하루 이상 남았으면 일 수를 올림해 "3일 후", 24시간 미만이면 "오늘"
  /// - 마이페이지 점포 행은 "3일 후 삭제", 점포 상세 안내는 "3일 후 삭제됩니다"로 쓴다
  String remainingUntilDeletion(DateTime now) {
    final remaining = difference(now);
    if (remaining < const Duration(days: 1)) return '오늘';
    final days = (remaining.inMinutes / Duration.minutesPerDay).ceil();
    return '$days일 후';
  }
}
