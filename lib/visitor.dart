import 'package:dox/expr.dart';

abstract class Visitor<T> {
  T visitUnary(UnaryExpr expr);

  T visitBinary(BinaryExpr expr);

  T visitLiteral(LiteralExpr expr);

  T visitExprStatement(ExprStatement statement);

  T visitPrintStatement(PrintStatement statement);

  T visitProgram(Program program);

  T visitVariable(VariableStatement variable);
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

  @override
  String visitExprStatement(ExprStatement statement) =>
      '${statement.expr.accept(this)};';

  @override
  String visitPrintStatement(PrintStatement statement) =>
      'print ${statement.expr.accept(this)}';

  @override
  String visitProgram(Program program) =>
      program.statements.map((statement) => statement.accept(this)).join('\n');

  @override
  String visitVariable(VariableStatement variable) {
    if (variable.expr != null) {
      return 'var ${variable.identifier.value} = ${variable.expr};';
    }
    return 'var ${variable.identifier.value}';
  }
}
