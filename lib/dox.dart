import 'dart:io';

import 'package:dox/interpreter.dart';
import 'package:dox/lexer.dart';
import 'package:dox/parser.dart';
import 'package:dox/resolver.dart';
import 'package:dox/statement.dart';
import 'package:dox/token.dart';

abstract class Dox {
  static bool _hadError = false;
  static bool _hadRuntimeError = false;

  static void error(int line, String message) {
    report(line, "", message);
  }

  static void report(int line, String where, String message) {
    print('[line $line] Error$where: $message');
    _hadError = true;
  }

  static void runtimeError(Object error) {
    print(error);
    _hadRuntimeError = true;
  }

  static Future<void> main(List<String> args) async {
    if (args.length > 1) {
      print('Usage: dox [script]');
      exit(64);
    } else if (args.length == 1) {
      final program = await File(args[0]).readAsString();
      run(program);
    } else {
      runRepl();
    }
  }

  static void run(String program) {
    try {
      final interpreter = Interpreter();
      final tokens = Lexer.enumerate(program);
      final parser = Parser(tokens: tokens.toList());
      final statement = parser.parse();

      if (_hadError) exit(65);

      final resolver = Resolver(interpreter: interpreter);
      resolver.resolveStatement(statement);

      if (_hadError) exit(65);

      interpreter.execute(statement);
    } catch (e) {
      print(e);
      exit(65);
    }
  }

  static void runRepl() {
    // TODO: could it be better?
    Statement? tryParseExpr(List<Token> tokens) {
      final parser = Parser(tokens: tokens);
      try {
        final expr = parser.parseExpression();
        return PrintStatement(expr: expr);
      } catch (e) {
        return null;
      }
    }

    final interpreter = Interpreter();
    while (true) {
      try {
        stdout.write('> ');
        final input = stdin.readLineSync();
        if (input == null) break;
        final tokens = Lexer.enumerate(input).toList();
        final statement =
            tryParseExpr(tokens) ?? Parser(tokens: tokens).parse();

        if (_hadError) {
          _hadError = false;
          print('Parsing error: ');
          continue;
        }

        final resolver = Resolver(interpreter: interpreter);
        resolver.resolveStatement(statement);

        if (_hadError) {
          _hadError = false;
          print('Resolving error: ');
          continue;
        }

        interpreter.execute(statement);

        if (_hadRuntimeError) {
          _hadRuntimeError = false;
          print('Runtime error: ');
          continue;
        }
      } catch (e) {
        final error = '$e';
        if (error.startsWith('Runtime error')) {
          print(error);
        } else {
          print('Unexpected error: $e');
        }
      }
    }
  }
}
