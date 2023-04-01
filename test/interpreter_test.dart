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
      '"hello " + "world";': 'hello world'
    };

    for (final kv in inputs.entries) {
      output.clear();

      final input = kv.key;
      final expected = kv.value;

      final tokens = Lexer.enumerate(input);
      final parser = Parser(tokens: tokens.toList());
      final expr = parser.parseExpression();
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
      final statement = parser.parse();
      interpreter.execute(statement);

      expect(output.output, expected, reason: input);
    }
  });

  test('Should initialize variables', () {
    final inputs = <String, Object?>{
      'var name;': '',
      'var surname = "Ivanov";': '',
      'var age = 5 + 9 * 10;': '',
      'var middleName; var id;': '',
      'var movie = "Sweet Home"; print movie;': 'Sweet Home',
      'var a = 1; var b = 2; var c = a + b; print c;': '3',
      'var variable; print variable;': 'nil',
    };

    for (final kv in inputs.entries) {
      output.clear();

      final input = kv.key;
      final expected = kv.value;

      final tokens = Lexer.enumerate(input);
      final parser = Parser(tokens: tokens.toList());
      final statement = parser.parse();
      interpreter.execute(statement);

      expect(output.output, expected, reason: input);
    }
  });

  test('Should assign variable', () {
    final inputs = <String, Object?>{
      'var name; name = "Ivan"; print name;': 'Ivan',
      'var a = 5; var b = 6; var c; c = a + b; print c;': '11',
      'var a = 5; a = 6; a = 7; print a;': '7',
      'var a = 5; a = true; print a;': 'true',
      'var a = false; a = nil; print a;': 'nil',
    };

    for (final kv in inputs.entries) {
      output.clear();

      final input = kv.key;
      final expected = kv.value;

      final tokens = Lexer.enumerate(input);
      final parser = Parser(tokens: tokens.toList());
      final statement = parser.parse();
      interpreter.execute(statement);

      expect(output.output, expected, reason: input);
    }
  });
}
