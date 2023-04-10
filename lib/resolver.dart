import 'package:dox/class_type.dart';
import 'package:dox/dox.dart';
import 'package:dox/expr.dart';
import 'package:dox/function_type.dart';
import 'package:dox/interpreter.dart';
import 'package:dox/statement.dart';
import 'package:dox/token.dart';
import 'package:dox/visitor.dart';

class Resolver implements Visitor<void> {
  final Interpreter interpreter;
  final List<Map<String, bool>> scopes = [];
  FunctionType currentFunction = FunctionType.none;
  ClassType currentClass = ClassType.none;

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

    if (scope.containsKey(name.toString())) {
      Dox.error(-1, 'Already variable with this name in this scope.');
    }

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

  void resolveFunction(FuncDeclaration func, FunctionType type) {
    final enclosingFunction = currentFunction;
    currentFunction = type;
    beginScope();

    for (final param in func.params) {
      declare(param);
      define(param);
    }
    resolveStatements(func.body);

    endScope();
    currentFunction = enclosingFunction;
  }

  @override
  void visitFuncDeclaration(FuncDeclaration func) {
    declare(func.name);
    define(func.name);

    resolveFunction(func, FunctionType.function);
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
    if (currentFunction == FunctionType.none) {
      Dox.error(-1, 'Can not return from top-level code.');
    }
    final value = statement.expr;
    if (value != null) {
      if (currentFunction == FunctionType.initializer) {
        Dox.error(-1, 'Can\'t return a value from an initializer.');
      }
      resolveExpression(value);
    }
  }

  @override
  void visitWhile(While statement) {
    resolveExpression(statement.expr);
    resolveStatement(statement.body);
  }

  @override
  void visitFor(For statement) {
    beginScope();
    final initializer = statement.initializer;
    final condition = statement.condition;
    final increment = statement.increment;
    if (initializer != null) resolveStatement(initializer);
    if (condition != null) resolveExpression(condition);
    if (increment != null) resolveExpression(increment);
    resolveStatement(statement.body);
    endScope();
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

  @override
  void visitClass(Klass klass) {
    final enclosingClass = currentClass;
    currentClass = ClassType.klass;

    declare(klass.name);

    beginScope();
    peekScope['this'] = true;

    for (final method in klass.methods) {
      FunctionType declaration = FunctionType.method;
      if (declaration.name.toString() == 'init') {
        declaration = FunctionType.initializer;
      }
      resolveFunction(method, declaration);
    }

    endScope();

    define(klass.name);

    currentClass = enclosingClass;
  }

  @override
  void visitGet(GetExpr get) => resolveExpression(get.object);

  @override
  void visitSet(SetExpr set) {
    resolveExpression(set.value);
    resolveExpression(set.object);
  }

  @override
  void visitThis(ThisExpr expr) {
    if (currentClass == ClassType.none) {
      Dox.error(-1, 'Can\'t use \'this\' outside of a class.');
      return;
    }
    resolveLocal(expr, expr.keyword);
  }
}
