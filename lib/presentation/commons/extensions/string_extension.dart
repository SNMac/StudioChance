extension StringExtension on String {
  String insertZwj() {
    return replaceAllMapped(RegExp(r'(\S)(?=\S)'), (m) => '${m[1]}\u200D');
  }

  /// 목적격 조사(을/를)를 붙인다. 끝 글자가 한글이 아니면(숫자·영문 등) 받침을
  /// 알 수 없으므로 '을(를)'을 붙인다
  String withObjectParticle() {
    if (isEmpty) return this;
    final last = codeUnitAt(length - 1);
    const hangulStart = 0xAC00;
    const hangulEnd = 0xD7A3;
    if (last < hangulStart || last > hangulEnd) return '$this을(를)';
    final hasFinalConsonant = (last - hangulStart) % 28 != 0;
    return hasFinalConsonant ? '$this을' : '$this를';
  }
}
