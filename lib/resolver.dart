import 'package:dox/dox.dart';
import 'package:dox/expr.dart';
import 'package:dox/interpreter.dart';
import 'package:dox/statement.dart';
import 'package:dox/token.dart';
import 'package:dox/visitor.dart';

class Resolver implements Visitor<void> {
  final Interpreter interpreter;
  final List<Map<String, bool>> scopes = [];

  Resolver({required this.interpreter});

  Map<String, bool> get peekScope => scopes.last;

  void beginScope() => scopes.add({});

  void endScope() => scopes.removeAt(scopes.length - 1);

  void resolveStatements(List<Statement> statements) {
    for (final statement in statements) {
      resolveStatement(statement);
    }
  }

  void resolveExpression(Expr expr) => expr.accept(this);

  void resolveStatement(Statement statement) => statement.accept(this);

  @override
  void visitBlock(Block block) {
    beginScope();
    resolveStatements(block.statements);
    endScope();
  }

  void declare(Token name) {
    if (scopes.isEmpty) return;
    final scope = peekScope;
    scope[name.toString()] = false;
  }

  void define(Token name) {
    if (scopes.isEmpty) return;
    final scope = peekScope;
    scope[name.toString()] = true;
  }

  @override
  void visitVariableDeclaration(VariableDeclaration declaration) {
    declare(declaration.identifier);
    final initializer = declaration.expr;
    if (initializer != null) resolveExpression(initializer);
    define(declaration.identifier);
  }

  void resolveLocal(Expr expr, Token name) {
    for (int i = scopes.length - 1; i >= 0; --i) {
      final scope = scopes[i];
      if (scope.containsKey(name.toString())) {
        interpreter.resolve(expr, scopes.length - 1 - i);
        return;
      }
    }
  }

  @override
  void visitVariable(VariableExpr variable) {
    if (scopes.isNotEmpty && peekScope[variable.name.toString()] == false) {
      Dox.error(-1, 'Can not read local variable in its own initializer.');
    }

    resolveLocal(variable, variable.name);
  }

  @override
  void visitAssign(AssignExpr assign) {
    final expr = assign.value;
    resolveExpression(expr);
    resolveLocal(expr, assign.name);
  }

  void resolveFunction(FuncDeclaration func) {
    beginScope();

    for (final param in func.params) {
      declare(param);
      define(param);
    }
    resolveStatements(func.body);
    endScope();
  }

  @override
  void visitFuncDeclaration(FuncDeclaration func) {
    declare(func.name);
    define(func.name);

    resolveFunction(func);
  }

  @override
  void visitCondition(Condition condition) {
    resolveExpression(condition.expr);
    resolveStatement(condition.than);
    final elseBranch = condition.elseStatement;
    if (elseBranch != null) resolveStatement(elseBranch);
  }

  @override
  void visitExprStatement(ExprStatement statement) =>
      resolveExpression(statement.expr);

  @override
  void visitPrintStatement(PrintStatement statement) {
    resolveExpression(statement.expr);
  }

  @override
  void visitReturn(Return statement) {
    final value = statement.expr;
    if (value != null) resolveExpression(value);
  }

  @override
  void visitWhile(While statement) {
    resolveExpression(statement.expr);
    resolveStatement(statement.body);
  }

  @override
  void visitFor(For statement) {
    final initializer = statement.initializer;
    final condition = statement.condition;
    final increment = statement.increment;
    if (initializer != null) resolveStatement(initializer);
    if (condition != null) resolveExpression(condition);
    if (increment != null) resolveExpression(increment);
    resolveStatement(statement.body);
  }

  @override
  void visitBinary(BinaryExpr expr) {
    resolveExpression(expr.left);
    resolveExpression(expr.right);
  }

  @override
  void visitCall(CallExpr call) {
    resolveExpression(call.callee);

    for (final argument in call.arguments) {
      resolveExpression(argument);
    }
  }

  @override
  void visitParen(ParenExpr paren) => resolveExpression(paren.expr);

  @override
  void visitLiteral(LiteralExpr expr) {}

  @override
  void visitLogic(LogicExpr logic) {
    resolveExpression(logic.left);
    resolveExpression(logic.right);
  }

  @override
  void visitProgram(Program program) => resolveStatements(program.statements);

  @override
  void visitUnary(UnaryExpr expr) => resolveExpression(expr.expr);
}
