import 'package:dox/interpreter.dart';
import 'package:dox/lexer.dart';
import 'package:dox/parser.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:collection/collection.dart';

Function eq = const ListEquality().equals;

void main() {
  test('Should parse expressions', () {
    final inputs = <String, Object?>{
      '(2 + 3)': 5.0,
      '-5 * (-1)': 5.0,
      '!true': false,
      '!!!!(true)': true,
      '8 - 3 * 2': 2.0,
      '(8 - 3) * 2': 10.0,
      '5 + 4 > 4': true,
      '8 * 2 == 4 + 4 + 4 + 4': true,
      '6 / 3 != 2': false,
    };

    final interpreter = Interpreter();
    for (final kv in inputs.entries) {
      final input = kv.key;
      final expected = kv.value;

      final tokens = Lexer.enumerate(input);
      final parser = Parser(tokens: tokens.toList());
      final expr = parser.parse();

      final actual = expr?.accept(interpreter);

      expect(actual, expected, reason: input);
    }
  });
}
