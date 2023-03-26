import 'package:dox/lexer.dart';
import 'package:dox/parser.dart';
import 'package:dox/visitor.dart';

abstract class Dox {
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
      // for (final token in tokens) {
      //   if (token.value != null) {
      //     if (token.type == TokenType.string ||
      //         token.type == TokenType.number ||
      //         token.type == TokenType.identifier) {
      //       print('${token.type.name}: ${token.value}');
      //     } else {
      //       print(token.value);
      //     }
      //   } else {
      //     print(token.type.name);
      //   }
      // }
    } catch (e) {
      print(e);
    }
  }
}
