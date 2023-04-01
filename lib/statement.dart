import 'package:dox/expr.dart';
import 'package:dox/token.dart';
import 'package:dox/visitor.dart';

abstract class Statement {
  T accept<T>(Visitor<T> visitor);
}

class ExprStatement extends Statement {
  final Expr expr;

  ExprStatement({required this.expr});

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitExprStatement(this);
}

class VariableDeclaration extends Statement {
  final Token identifier;
  final Expr? expr;

  VariableDeclaration({required this.identifier, this.expr});

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitVariableDeclaration(this);
}

class PrintStatement extends Statement {
  final Expr expr;

  PrintStatement({required this.expr});

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitPrintStatement(this);
}

class Program extends Statement {
  final List<Statement> statements;

  Program({required this.statements});

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitProgram(this);
}