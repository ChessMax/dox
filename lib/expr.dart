import 'package:dox/token.dart';
import 'package:dox/visitor.dart';

abstract class Expr {
  T accept<T>(Visitor<T> visitor);
}

class CallExpr extends Expr {
  final Expr callee;
  final List<Expr> arguments;

  CallExpr({required this.callee, required this.arguments});

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitCall(this);
}

class GetExpr extends Expr {
  final Expr object;
  final Token name;

  GetExpr({required this.object, required this.name});

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitGet(this);
}

class SetExpr extends Expr {
  final Expr object;
  final Token name;
  final Expr value;

  SetExpr({required this.object, required this.name, required this.value});

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitSet(this);
}

class ThisExpr extends Expr {
  final Token keyword;

  ThisExpr({required this.keyword});

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitThis(this);
}

class SuperExpr extends Expr {
  final Token keyword;
  final Token method;

  SuperExpr({required this.keyword, required this.method});

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitSuper(this);
}

class AssignExpr extends Expr {
  final Token name;
  final Expr value;

  AssignExpr({required this.name, required this.value});

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitAssign(this);
}

class ParenExpr extends Expr {
  final Expr expr;

  ParenExpr({required this.expr});

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitParen(this);
}

class BinaryExpr extends Expr {
  final Expr left;
  final Token operator;
  final Expr right;

  BinaryExpr({
    required this.left,
    required this.operator,
    required this.right,
  });

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitBinary(this);
}

class LogicExpr extends BinaryExpr {
  LogicExpr({
    required super.left,
    required super.operator,
    required super.right,
  });

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitLogic(this);
}

class UnaryExpr extends Expr {
  final Token operator;
  final Expr expr;

  UnaryExpr({
    required this.operator,
    required this.expr,
  });

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitUnary(this);
}

class LiteralExpr extends Expr {
  final Object? value;

  LiteralExpr({required this.value}) : assert(value is! Token);

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitLiteral(this);

  @override
  String toString() => value.toString();
}

class VariableExpr extends Expr {
  final Token name;

  VariableExpr({required this.name});

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitVariable(this);
}
