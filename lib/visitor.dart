import 'package:dox/expr.dart';

abstract class Visitor<T> {
  T visitUnary(UnaryExpr expr);

  T visitBinary(BinaryExpr expr);

  T visitLiteral(LiteralExpr expr);
}

class PrintVisitor extends Visitor<String> {
  @override
  String visitBinary(BinaryExpr expr) =>
      '(${expr.left.accept(this)} ${expr.operator} ${expr.right.accept(this)})';

  @override
  String visitLiteral(LiteralExpr expr) => expr.value.toString();

  @override
  String visitUnary(UnaryExpr expr) =>
      '${expr.operator}${expr.expr.accept(this)}';
}
