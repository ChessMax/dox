import 'package:dox/lexer.dart';
import 'package:dox/parser.dart';
import 'package:dox/visitor.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  test('Should parse expressions', () {
    final inputs = <String, String>{
      '(2);': '2.0;',
      '-5;': '-5.0;',
      '!true;': '!true;',
      '!!!!(true);': '!!!!true;',
      '8 - 3 * 2;': '(8.0 - (3.0 * 2.0));',
      '(8 - 3) * 2;': '((8.0 - 3.0) * 2.0);',
      '5 + 4 > 4;': '((5.0 + 4.0) > 4.0);',
      '8 * 2 == 4 + 4 + 4 + 4;':
          '((8.0 * 2.0) == (((4.0 + 4.0) + 4.0) + 4.0));',
      // 'true and false': '(true and false)',
      // 'false or false': '(false or false)',
      // 'false or true and false': '(false or (true and false))',
    };

    final printer = PrintVisitor();
    for (final kv in inputs.entries) {
      final input = kv.key;
      final expected = kv.value;

      final tokens = Lexer.enumerate(input);
      final parser = Parser(tokens: tokens.toList());
      final expr = parser.parse();

      final actual = expr.accept(printer);

      expect(actual, expected);
    }
  });
}
