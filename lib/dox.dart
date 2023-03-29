import 'package:dox/lexer.dart';
import 'package:dox/parser.dart';
import 'package:dox/visitor.dart';

abstract class Dox {
  static bool _hadError = false;
  static bool _hadRuntimeError = false;

  static void runtimeError(Object error) {
    print(error);
    _hadRuntimeError = true;
  }

  static Future<void> main(List<String> args) async {
    parseAndPrint('(2)');
    parseAndPrint('-5');
    parseAndPrint('!true');
    parseAndPrint('!!!!(true)');
    parseAndPrint('8 - 3 * 2');
    parseAndPrint('(8 - 3) * 2');
  }

  static void parseAndPrint(String program) {
    try {
      final tokens = Lexer.enumerate(program);
      final parser = Parser(tokens: tokens.toList());
      final expr = parser.parse();
      final printer = PrintVisitor();
      print(expr?.accept(printer));
    } catch (e) {
      print(e);
    }
  }
}
