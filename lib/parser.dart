import 'package:dox/expr.dart';
import 'package:dox/token.dart';
import 'package:dox/token_type.dart';

class Parser {
  final List<Token> tokens;
  int position = 0;

  Parser({required this.tokens});

  Token? get peek => position < tokens.length ? tokens[position] : null;

  Token? get peekNext =>
      position + 1 < tokens.length ? tokens[position + 1] : null;

  void consume() => ++position;

  Expr? parse() {
    final expr = parseExpression();
    if (expr != null) {
      final eof = peek;
      if (eof != null && eof.type == TokenType.eof) {
        return expr;
      } else {
        throw 'Expected end of file not found';
      }
    } else {
      throw 'Expected expression not found.';
    }
  }

  Expr? parseExpression() {
    Expr? expr = parseTerm();
    return expr;
  }

  Expr parseTerm() {
    Expr expr = parseFactor();
    Token? token = peek;
    while (token != null &&
        (token.type == TokenType.plus || token.type == TokenType.minus)) {
      consume();
      final right = parseFactor();
      expr = BinaryExpr(left: expr, operator: token, right: right);
      token = peek;
    }

    return expr;
  }

  Expr parseFactor() {
    Expr expr = parseUnary();
    Token? token = peek;
    while (token != null &&
        (token.type == TokenType.star || token.type == TokenType.slash)) {
      consume();
      final right = parseUnary();
      expr = BinaryExpr(left: expr, operator: token, right: right);
      token = peek;
    }

    return expr;
  }

  Expr parseUnary() {
    // !!!!a
    final operator = tryPeekUnaryOperator();
    if (operator != null) {
      consume();
      final expr = parseUnary();
      return UnaryExpr(operator: operator, expr: expr);
    }

    return parsePrimary();
  }

  Expr parsePrimary() {
    final literal = tryParseLiteral();
    if (literal != null) return literal;

    final leftParen = peek;
    if (leftParen == null || leftParen.type != TokenType.leftParen) {
      throw 'Expected left paren not found';
    }

    consume();

    final expr = parseExpression();

    if (expr == null) {
      throw 'Expected expression not found';
    }

    final rightParen = peek;
    if (rightParen == null || rightParen.type != TokenType.rightParen) {
      throw 'Expected closing parenthesis not found';
    }

    consume();
    return expr;
  }

  Token? tryPeekUnaryOperator() {
    final operator = peek;
    if (operator == null) {
      return null;
    }

    switch (operator.type) {
      case TokenType.bang:
      case TokenType.minus:
        return operator;
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

  Token? tryPeekOperator() {
    final operator = peek;
    if (operator != null) {
      switch (operator.type) {
        case TokenType.minus:
        case TokenType.plus:
        case TokenType.slash:
        case TokenType.star:
        case TokenType.less:
        case TokenType.lessOrEqual:
        case TokenType.equal:
        case TokenType.equalEqual:
        case TokenType.greater:
        case TokenType.greaterOrEqual:
          return operator;
        case TokenType.leftParen:
        case TokenType.rightParen:
        case TokenType.leftBrace:
        case TokenType.rightBrace:
        case TokenType.comma:
        case TokenType.dot:
        case TokenType.semicolon:
        case TokenType.bang:
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
          break;
      }
    }
    return null;
  }

  Expr? tryParseLiteral() {
    final token = peek;
    if (token != null) {
      if (token.type == TokenType.number ||
          token.type == TokenType.string ||
          token.type == TokenType.trueT ||
          token.type == TokenType.falseT ||
          token.type == TokenType.nil) {
        consume();
        return LiteralExpr(value: token.value);
      }
    }

    return null;
  }
}
