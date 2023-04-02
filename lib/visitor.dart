import 'package:dox/expr.dart';
import 'package:dox/statement.dart';

abstract class Visitor<T> {
  T visitUnary(UnaryExpr expr);

  T visitBinary(BinaryExpr expr);

  T visitLiteral(LiteralExpr expr);

  T visitExprStatement(ExprStatement statement);

  T visitPrintStatement(PrintStatement statement);

  T visitProgram(Program program);

  T visitVariableDeclaration(VariableDeclaration declaration);

  T visitVariable(VariableExpr variable);

  T visitAssign(AssignExpr assign);

  T visitParen(ParenExpr paren);

  T visitBlock(Block block);

  T visitCondition(Condition condition);

  T visitLogic(LogicExpr logic);
}

class PrintVisitor extends Visitor<String> {
  @override
  String visitBinary(BinaryExpr expr) =>
      '(${expr.left.accept(this)} ${expr.operator} ${expr.right.accept(this)})';

  @override
  String visitLogic(LogicExpr logic) => visitBinary(logic);

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
    final expr = declaration.expr;
    if (expr != null) {
      return 'var ${declaration.identifier} = ${expr.accept(this)};';
    }
    return 'var ${declaration.identifier}';
  }

  @override
  String visitVariable(VariableExpr variable) => '${variable.name}';

  @override
  String visitAssign(AssignExpr assign) =>
      '${assign.name} = ${assign.value.accept(this)}';

  @override
  String visitParen(ParenExpr paren) {
    final expr = paren.expr;
    if (expr is BinaryExpr) {
      return paren.expr.accept(this);
    }
    return '(${paren.expr.accept(this)})';
  }

  @override
  String visitBlock(Block block) {
    StringBuffer buffer = StringBuffer('{\n');
    buffer.writeAll(block.statements.map<String>((e) => e.accept(this)), '\n');
    buffer.write('\n}');
    return buffer.toString();
  }

  @override
  String visitCondition(Condition condition) {
    StringBuffer buffer = StringBuffer('if (${condition.expr.accept(this)}');
    buffer.writeln('\n{');
    buffer.writeln(condition.than.accept(this));
    buffer.writeln('\n}');
    final elseStatement = condition.elseStatement;
    if (elseStatement != null) {
      buffer.writeln(' else {');
      buffer.writeln(elseStatement.accept(this));
      buffer.writeln('}');
    }
    return buffer.toString();
  }
}
