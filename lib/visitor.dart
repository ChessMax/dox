import 'package:dox/expr.dart';

abstract class Visitor<T> {
  T visitUnary(UnaryExpr expr);

  T visitBinary(BinaryExpr expr);

  T visitLiteral(LiteralExpr expr);

  T visitExprStatement(ExprStatement statement);

  T visitPrintStatement(PrintStatement statement);

  T visitProgram(Program program);

  T visitVariableDeclaration(VariableDeclaration declaration);

  T visitVariable(VariableExpr variable);
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
  String visitVariableDeclaration(VariableDeclaration declaration) {
    if (declaration.expr != null) {
      return 'var ${declaration.identifier} = ${declaration.expr};';
    }
    return 'var ${declaration.identifier}';
  }

  @override
  String visitVariable(VariableExpr variable) => '${variable.name}';
}
