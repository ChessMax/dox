import 'package:dox/dox.dart';
import 'package:dox/expr.dart';
import 'package:dox/statement.dart';
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

  Token consumeSemicolon() => consumeToken(TokenType.semicolon);

  Token consumeToken(TokenType type) {
    final token = peek;
    if (token != null && token.type == type) {
      consume();
      return token;
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

  Statement parse() => parseProgram();

  Statement parseProgram() {
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

  Statement parseVarDeclaration() {
    Expr? expr;
    final identifier = consumeToken(TokenType.identifier);
    if (tryConsumeToken(TokenType.equal)) {
      expr = parseExpression();
    }

    consumeSemicolon();

    return VariableDeclaration(identifier: identifier, expr: expr);
  }

  Block parseBlock() {
    final statements = <Statement>[];
    while (!isAtEnd && peek?.type != TokenType.rightBrace) {
      statements.add(parseStatement());
    }
    consumeToken(TokenType.rightBrace);
    return Block(statements: statements);
  }

  Statement parseCondition() {
    consumeToken(TokenType.leftParen);
    final expr = parseExpression();
    consumeToken(TokenType.rightParen);
    final than = parseStatement();
    final elseStatement =
        tryConsumeToken(TokenType.elseT) ? parseStatement() : null;

    return Condition(expr: expr, than: than, elseStatement: elseStatement);
  }

  Statement parseWhile() {
    consumeToken(TokenType.leftParen);
    final expr = parseExpression();
    consumeToken(TokenType.rightParen);
    final body = parseStatement();
    return While(expr: expr, body: body);
  }

  Statement parseFor() {
    Expr? condition;
    Expr? increment;
    Statement? initializer;

    consumeToken(TokenType.leftParen);

    if (tryConsumeToken(TokenType.semicolon)) {
      initializer = null;
    } else if (tryConsumeToken(TokenType.varT)) {
      initializer = parseVarDeclaration();
    } else {
      initializer = parseExpressionStatement();
    }

    if (tryConsumeToken(TokenType.semicolon)) {
      condition = null;
    } else {
      condition = parseExpression();
      consumeToken(TokenType.semicolon);
    }

    if (tryConsumeToken(TokenType.rightParen)) {
      increment = null;
    } else {
      increment = parseExpression();
      consumeToken(TokenType.rightParen);
    }

    final body = parseStatement();

    return For(
      initializer: initializer,
      condition: condition,
      increment: increment,
      body: body,
    );
  }

  FuncDeclaration parseFuncDeclaration([String type = 'function']) {
    // TODO: use type?
    final name = consumeToken(TokenType.identifier);
    final params = <Token>[];
    consumeToken(TokenType.leftParen);
    while (peek?.type != TokenType.rightParen) {
      final param = consumeToken(TokenType.identifier);

      if (params.length >= 255) {
        Dox.error(-1, 'Can not have more than 255 parameters');
      }

      params.add(param);
      if (!tryConsumeToken(TokenType.comma)) {
        break;
      }
    }
    consumeToken(TokenType.rightParen);
    consumeToken(TokenType.leftBrace);
    final body = parseBlock().statements;
    return FuncDeclaration(name: name, params: params, body: body);
  }

  Statement parseReturn() {
    Expr? expr;
    if (!tryConsumeToken(TokenType.semicolon)) {
      expr = parseExpression();
      consumeToken(TokenType.semicolon);
    }

    return Return(expr: expr);
  }

  Statement parseClass() {
    final name = consumeToken(TokenType.identifier);
    consumeToken(TokenType.leftBrace);
    final statements = <FuncDeclaration>[];
    while (!isAtEnd && peek?.type != TokenType.rightBrace) {
      statements.add(parseFuncDeclaration('method'));
    }
    consumeToken(TokenType.rightBrace);
    return Klass(name: name, methods: statements);
  }

  Statement parseStatement() {
    if (tryConsumeToken(TokenType.classT)) {
      return parseClass();
    }
    if (tryConsumeToken(TokenType.returnT)) {
      return parseReturn();
    }
    if (tryConsumeToken(TokenType.fun)) {
      return parseFuncDeclaration();
    }
    if (tryConsumeToken(TokenType.varT)) {
      return parseVarDeclaration();
    }
    if (tryConsumeToken(TokenType.leftBrace)) {
      return parseBlock();
    }
    if (tryConsumeToken(TokenType.forT)) {
      return parseFor();
    }
    if (tryConsumeToken(TokenType.ifT)) {
      return parseCondition();
    }
    if (tryConsumeToken(TokenType.whileT)) {
      return parseWhile();
    }
    if (tryConsumeToken(TokenType.print)) {
      return parsePrintStatement();
    }
    return parseExpressionStatement();
  }

  Expr parseExpression() {
    Expr expr = parseAssignment();
    return expr;
  }

  Expr parseAssignment() {
    final expr = parseOr();

    if (tryConsumeToken(TokenType.equal)) {
      final value = parseAssignment();
      if (expr is VariableExpr) {
        return AssignExpr(name: expr.name, value: value);
      } else if (expr is GetExpr) {
        return SetExpr(object: expr.object, name: expr.name, value: value);
      }
      Dox.error(-1, 'Invalid assignment target.');
    }
    return expr;
  }

  Expr parseOr() {
    Expr expr = parseAnd();

    Token? token = peek;
    while (token != null && token.type == TokenType.or) {
      consume();
      final right = parseAnd();
      expr = LogicExpr(left: expr, operator: token, right: right);
      token = peek;
    }

    return expr;
  }

  Expr parseAnd() {
    Expr expr = parseEquality();

    Token? token = peek;
    while (token != null && token.type == TokenType.and) {
      consume();
      final right = parseEquality();
      expr = LogicExpr(left: expr, operator: token, right: right);
      token = peek;
    }

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

    return parseCall();
  }

  Expr parseCall() {
    Expr expr = parsePrimary();
    while (true) {
      if (tryConsumeToken(TokenType.leftParen)) {
        expr = parseCallArguments(expr);
      } else if (tryConsumeToken(TokenType.dot)) {
        final name = consumeToken(TokenType.identifier);
        expr = GetExpr(object: expr, name: name);
      } else {
        break;
      }
    }
    return expr;
  }

  Expr parseCallArguments(Expr callee) {
    final arguments = <Expr>[];
    final token = peek;
    if (token?.type != TokenType.rightParen) {
      do {
        final argument = parseExpression();
        if (arguments.length >= 255) {
          Dox.error(-1, 'Can not have more than 255 arguments.');
        }
        arguments.add(argument);
      } while (tryConsumeToken(TokenType.comma));
    }

    consumeToken(TokenType.rightParen);

    return CallExpr(callee: callee, arguments: arguments);
  }

  Expr parsePrimary() {
    final literal = tryParseLiteral();
    if (literal != null) return LiteralExpr(value: literal.value);

    if (tryConsumeToken(TokenType.thisT)) {
      return ThisExpr(keyword: tokens[position - 1]);
    }

    final identifier = tryParseIdentifier();
    if (identifier != null) return VariableExpr(name: identifier);

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
    return ParenExpr(expr: expr);
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

  Token? tryParseLiteral() {
    final token = peek;
    if (token != null) {
      if (token.type == TokenType.number ||
          token.type == TokenType.string ||
          token.type == TokenType.trueT ||
          token.type == TokenType.falseT ||
          token.type == TokenType.nil) {
        consume();
        return token;
      }
    }

    return null;
  }

  Token? tryParseIdentifier() {
    final token = peek;
    if (token != null) {
      if (token.type == TokenType.identifier) {
        consume();
        return token;
      }
    }

    return null;
  }
}
