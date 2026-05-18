/// [e]가 [Exception]이면 그대로 반환, 아니면 [Exception]으로 래핑
Exception toException(Object e) => e is Exception ? e : Exception(e.toString());
