String stringify(Object? value) {
  if (value == null) return 'nil';
  if (value is double) {
    final text = value.toString();
    return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
  }
  return value.toString();
}
