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

class FuncDeclaration extends Statement {
  final Token name;
  final List<Token> params;
  final List<Statement> body;

  FuncDeclaration({
    required this.name,
    required this.params,
    required this.body,
  });

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitFuncDeclaration(this);
}

class PrintStatement extends Statement {
  final Expr expr;

  PrintStatement({required this.expr});

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitPrintStatement(this);
}

class Block extends Statement {
  final List<Statement> statements;

  Block({required this.statements});

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitBlock(this);
}

class Condition extends Statement {
  final Expr expr;
  final Statement than;
  final Statement? elseStatement;

  Condition({required this.expr, required this.than, this.elseStatement});

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitCondition(this);
}

class While extends Statement {
  final Expr expr;
  final Statement body;

  While({required this.expr, required this.body});

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitWhile(this);
}

class For extends Statement {
  final Statement? initializer;
  final Expr? condition;
  final Expr? increment;
  final Statement body;

  For({
    required this.initializer,
    required this.condition,
    required this.increment,
    required this.body,
  });

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitFor(this);
}

class Return extends Statement {
  final Expr? expr;

  Return({required this.expr});

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitReturn(this);
}

class Klass extends Statement {
  final Token name;
  final VariableExpr? superClass;
  final List<FuncDeclaration> methods;

  Klass({required this.name, required this.superClass, required this.methods});

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitClass(this);
}

class Program extends Statement {
  final List<Statement> statements;

  Program({required this.statements});

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitProgram(this);
}
