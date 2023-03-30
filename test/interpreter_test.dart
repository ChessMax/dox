import 'package:dox/interpreter.dart';
import 'package:dox/lexer.dart';
import 'package:dox/output.dart';
import 'package:dox/parser.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  final output = TestOutput();
  final interpreter = Interpreter(output);

  test('Should parse expressions', () {
    final inputs = <String, Object?>{
      '(2 + 3);': 5.0,
      '-5 * (-1);': 5.0,
      '!true;': false,
      '!!!!(true);': true,
      '8 - 3 * 2;': 2.0,
      '(8 - 3) * 2;': 10.0,
      '5 + 4 > 4;': true,
      '8 * 2 == 4 + 4 + 4 + 4;': true,
      '6 / 3 != 2;': false,
      '(5 - (3 - 1)) + -1;': 2.0,
    };

    for (final kv in inputs.entries) {
      output.clear();

      final input = kv.key;
      final expected = kv.value;

      final tokens = Lexer.enumerate(input);
      final parser = Parser(tokens: tokens.toList());
      final expr = parser.parse();
      final actual = interpreter.evaluate(expr);

      expect(actual, expected, reason: input);
    }
  });

  test('Should evaluate statements', () {
    final inputs = <String, Object?>{
      'print nil;': 'nil',
      'print !(5 > 3);': 'false',
      'print 5 + 4;': '9',
      'print (2 + 3);': '5',
      'print -5 * (-1);': '5',
      'print !true;': 'false',
      'print !!!!(true);': 'true',
      'print 8 - 3 * 2;': '2',
      'print (8 - 3) * 2;': '10',
      'print 5 + 4 > 4;': 'true',
      'print 8 * 2 == 4 + 4 + 4 + 4;': 'true',
      'print 6 / 3 != 2;': 'false',
      'print (5 - (3 - 1)) + -1;': '2',
      'print 2.3 + 3.2;': '5.5',
      'print "one";': 'one',
      'print true;': 'true',
      'print 2 + 1;': '3',
    };

    for (final kv in inputs.entries) {
      output.clear();

      final input = kv.key;
      final expected = kv.value;

      final tokens = Lexer.enumerate(input);
      final parser = Parser(tokens: tokens.toList());
      final expr = parser.parse();
      interpreter.evaluate(expr);

      expect(output.output, expected, reason: input);
    }
  });

  test('Should initialize variables', () {
    final inputs = <String, Object?>{
      'var name;': '',
      'var surname = "Ivanov";': '',
      'var age = 5 + 9 * 10;': '',
      'var middleName; var id;': '',
    };

    for (final kv in inputs.entries) {
      output.clear();

      final input = kv.key;
      final expected = kv.value;

      final tokens = Lexer.enumerate(input);
      final parser = Parser(tokens: tokens.toList());
      final expr = parser.parse();
      interpreter.evaluate(expr);

      expect(output.output, expected, reason: input);
    }
  });
}
