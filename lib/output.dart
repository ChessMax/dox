import 'dart:io';

abstract class Output {
  const Output();
  void print(Object? value);
}

class StandardOutput extends Output {
  const StandardOutput();

  @override
  void print(Object? value) => stdout.writeln(value);
}

class TestOutput extends Output {
  String _output = '';

  String get output => _output;

  @override
  void print(Object? value) {
    if (_output.isNotEmpty) {
      _output += '\n$value';
    } else {
      _output += '$value';
    }
  }

  void clear() => _output = '';
}
