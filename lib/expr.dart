import 'package:dox/token.dart';
import 'package:dox/visitor.dart';

abstract class Expr {
  T accept<T>(Visitor<T> visitor);
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

  LiteralExpr({required this.value});

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitLiteral(this);

  @override
  String toString() => value.toString();
}
