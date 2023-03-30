import 'package:dox/expr.dart';
import 'package:dox/token.dart';
import 'package:dox/token_type.dart';

class Parser {
  final List<Token> tokens;
  int position = 0;

  Parser({required this.tokens});

  bool get isAtEnd => position >= tokens.length;

  Token? get peek => position < tokens.length ? tokens[position] : null;

  Token? get peekNext =>
      position + 1 < tokens.length ? tokens[position + 1] : null;

  void consume() => ++position;

  void consumeToken(TokenType type) {
    final token = peek;
    if (token != null && token.type == type) {
      consume();
    } else {
      throw 'Expected $type not found';
    }
  }

  bool tryConsumeToken(TokenType type) {
    final token = peek;
    if (token != null && token.type == type) {
      consume();
      return true;
    } else {
      return false;
    }
  }

  Expr parse() => parseProgram();

  Expr parseProgram() {
    final statements = <Statement>[];
    while (!isAtEnd && peek?.type != TokenType.eof) {
      statements.add(parseStatement());
    }
    consumeToken(TokenType.eof);
    return Program(statements: statements);
  }

  Statement parsePrintStatement() {
    final expr = parseExpression();
    consumeToken(TokenType.semicolon);
    return PrintStatement(expr: expr);
  }

  Statement parseExpressionStatement() {
    final expr = parseExpression();
    consumeToken(TokenType.semicolon);
    return ExprStatement(expr: expr);
  }

  Statement parseStatement() {
    if (tryConsumeToken(TokenType.print)) {
      return parsePrintStatement();
    }
    return parseExpressionStatement();
  }

  Expr parseExpression() {
    Expr expr = parseEquality();
    return expr;
  }

  Expr parseEquality() {
    Expr expr = parseComparison();

    Token? token = peek;
    while (token != null &&
        (token.type == TokenType.equalEqual ||
            token.type == TokenType.bangEqual)) {
      consume();
      final right = parseComparison();
      expr = BinaryExpr(left: expr, operator: token, right: right);
      token = peek;
    }

    return expr;
  }

  Expr parseComparison() {
    Expr expr = parseTerm();

    Token? token = peek;
    while (token != null &&
        (token.type == TokenType.less ||
            token.type == TokenType.greater ||
            token.type == TokenType.lessOrEqual ||
            token.type == TokenType.greaterOrEqual)) {
      consume();
      final right = parseTerm();
      expr = BinaryExpr(left: expr, operator: token, right: right);
      token = peek;
    }

    return expr;
  }

  // Expr parseOr() {
  //   Expr expr = parseAnd();
  //
  //   Token? token = peek;
  //   while (token != null && token.type == TokenType.or) {
  //     consume();
  //     final right = parseAnd();
  //     expr = BinaryExpr(left: expr, operator: token, right: right);
  //     token = peek;
  //   }
  //
  //   return expr;
  // }

  // Expr parseAnd() {
  //   Expr expr = parseTerm();
  //
  //   Token? token = peek;
  //   while (token != null && token.type == TokenType.and) {
  //     consume();
  //     final right = parseTerm();
  //     expr = BinaryExpr(left: expr, operator: token, right: right);
  //     token = peek;
  //   }
  //
  //   return expr;
  // }

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
