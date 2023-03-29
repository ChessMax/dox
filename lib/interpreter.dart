import 'package:dox/dox.dart';
import 'package:dox/expr.dart';
import 'package:dox/token_type.dart';
import 'package:dox/visitor.dart';

class Interpreter extends Visitor<Object?> {
  void interpret(Expr expr) {
    try {
      final value = evaluate(expr);
      print(stringify(value));
    } catch (e) {
      Dox.runtimeError(e);
    }
  }

  String stringify(Object? value) {
    if (value == null) return 'nil';
    if (value is double) {
      final text = value.toString();
      return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
    }
    return value.toString();
  }

  Object? evaluate(Expr expr) => expr.accept(this);

  @override
  Object? visitLiteral(LiteralExpr expr) => expr.value;

  @override
  Object? visitBinary(BinaryExpr expr) {
    final left = expr.left.accept(this);
    final right = expr.right.accept(this);
    switch (expr.operator.type) {
      case TokenType.minus:
        if (left is! double || right is! double) {
          throw 'Expected double but got: $left, right';
        }
        return left - right;
      case TokenType.plus:
        if (left is! double || right is! double) {
          throw 'Expected double but got: $left, right';
        }
        return left + right;
      case TokenType.slash:
        if (left is! double || right is! double) {
          throw 'Expected double but got: $left, right';
        }
        return left / right;
      case TokenType.star:
        if (left is! double || right is! double) {
          throw 'Expected double but got: $left, right';
        }
        return left * right;
      case TokenType.less:
        if (left is! double || right is! double) {
          throw 'Expected double but got: $left, right';
        }
        return left < right;
      case TokenType.lessOrEqual:
        if (left is! double || right is! double) {
          throw 'Expected double but got: $left, right';
        }
        return left <= right;
      case TokenType.greater:
        if (left is! double || right is! double) {
          throw 'Expected double but got: $left, right';
        }
        return left > right;
      case TokenType.greaterOrEqual:
        if (left is! double || right is! double) {
          throw 'Expected double but got: $left, right';
        }
        return left >= right;
      case TokenType.equalEqual:
        return left == right;
      case TokenType.bangEqual:
        return left != right;
      case TokenType.leftParen:
      case TokenType.rightParen:
      case TokenType.leftBrace:
      case TokenType.rightBrace:
      case TokenType.comma:
      case TokenType.dot:
      case TokenType.semicolon:
      case TokenType.equal:
      case TokenType.bang:
      case TokenType.identifier:
      case TokenType.string:
      case TokenType.number:
      case TokenType.and:
      case TokenType.classT:
      case TokenType.elseT:
      case TokenType.falseT:
      case TokenType.fun:
      case TokenType.forT:
      case TokenType.ifT:
      case TokenType.nil:
      case TokenType.or:
      case TokenType.print:
      case TokenType.returnT:
      case TokenType.superT:
      case TokenType.thisT:
      case TokenType.trueT:
      case TokenType.varT:
      case TokenType.whileT:
      case TokenType.eof:
        return null;
    }
  }

  @override
  Object? visitUnary(UnaryExpr expr) {
    switch (expr.operator.type) {
      case TokenType.minus:
        final value = expr.expr.accept(this);
        if (value is! double) throw 'Expected a number value, but got $value';
        return -value;
      case TokenType.bang:
        final value = expr.expr.accept(this);
        if (value is! bool) throw 'Expected a number value, but got $value';
        return !value;
      case TokenType.leftParen:
      case TokenType.rightParen:
      case TokenType.leftBrace:
      case TokenType.rightBrace:
      case TokenType.comma:
      case TokenType.dot:
      case TokenType.plus:
      case TokenType.semicolon:
      case TokenType.slash:
      case TokenType.star:
      case TokenType.less:
      case TokenType.lessOrEqual:
      case TokenType.equal:
      case TokenType.equalEqual:
      case TokenType.greater:
      case TokenType.greaterOrEqual:
      case TokenType.bangEqual:
      case TokenType.identifier:
      case TokenType.string:
      case TokenType.number:
      case TokenType.and:
      case TokenType.classT:
      case TokenType.elseT:
      case TokenType.falseT:
      case TokenType.fun:
      case TokenType.forT:
      case TokenType.ifT:
      case TokenType.nil:
      case TokenType.or:
      case TokenType.print:
      case TokenType.returnT:
      case TokenType.superT:
      case TokenType.thisT:
      case TokenType.trueT:
      case TokenType.varT:
      case TokenType.whileT:
      case TokenType.eof:
        return null;
    }
  }
}
