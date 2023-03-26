extension StringExt on String {
  bool get isDigit {
    if (length != 1) return false;
    final char = codeUnitAt(0);
    return char >= '0'.codeUnitAt(0) && char <= '9'.codeUnitAt(0);
  }

  bool get isAlpha {
    if (length != 1) return false;
    if (this == '_') return true;
    final char = codeUnitAt(0);
    return char >= 'a'.codeUnitAt(0) && char <= 'z'.codeUnitAt(0) ||
        char >= 'A'.codeUnitAt(0) && char <= 'Z'.codeUnitAt(0);
  }

  bool get isAlphaNumeric => isAlpha || isDigit;
}
