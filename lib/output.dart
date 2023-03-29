abstract class Output {
  const Output();
  void print(Object? value);
}

class StandardOutput extends Output {
  const StandardOutput();

  @override
  void print(Object? value) => print(value);
}

class TestOutput extends Output {
  String _output = '';

  String get output => _output;

  @override
  void print(Object? value) {
    _output += value.toString();
  }

  void clear() => _output = '';
}
