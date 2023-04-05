import 'dart:io';

import 'package:dox/callable.dart';
import 'package:dox/environment.dart';
import 'package:dox/expr.dart';
import 'package:dox/output.dart';
import 'package:dox/runtime_error.dart';
import 'package:dox/statement.dart';
import 'package:dox/stringify.dart';
import 'package:dox/token_type.dart';
import 'package:dox/visitor.dart';

class Interpreter extends Visitor<Object?> {
  final Output _output;
  final globals = Environment();
  late Environment environment = globals;

  Interpreter([this._output = const StandardOutput()]) {
    globals.define('clock', ClockFunc());
    globals.define('readLine', ReadLineFunc());
  }

  void execute(Statement statement) => statement.accept(this);

  void executeBlock(List<Statement> block, Environment environment) {
    final oldEnvironment = this.environment;

    try {
      this.environment = Environment(parent: environment);
      block.forEach(execute);
    } finally {
      this.environment = oldEnvironment;
    }
  }

  Object? evaluate(Expr expr) => expr.accept(this);

  Object? evaluateStatement(Statement statement) => statement.accept(this);

  @override
  Object? visitLiteral(LiteralExpr expr) => expr.value;

  @override
  Object? visitBinary(BinaryExpr expr) {
    final left = expr.left.accept(this);
    final right = expr.right.accept(this);
    switch (expr.operator.type) {
      case TokenType.minus:
        if (left is! double || right is! double) {
          throw 'Expected double but got: $left, $right';
        }
        return left - right;
      case TokenType.plus:
        if (left is double && right is double) {
          return left + right;
        } else if (left is String && right is String) {
          return left + right;
        }
        throw 'Expected double or String but got: $left, $right';
      case TokenType.slash:
        if (left is! double || right is! double) {
          throw 'Expected double but got: $left, $right';
        }
        return left / right;
      case TokenType.star:
        if (left is! double || right is! double) {
          throw 'Expected double but got: $left, $right';
        }
        return left * right;
      case TokenType.less:
        if (left is! double || right is! double) {
          throw 'Expected double but got: $left, $right';
        }
        return left < right;
      case TokenType.lessOrEqual:
        if (left is! double || right is! double) {
          throw 'Expected double but got: $left, $right';
        }
        return left <= right;
      case TokenType.greater:
        if (left is! double || right is! double) {
          throw 'Expected double but got: $left, $right';
        }
        return left > right;
      case TokenType.greaterOrEqual:
        if (left is! double || right is! double) {
          throw 'Expected double but got: $left, $right';
        }
        return left >= right;
      case TokenType.equalEqual:
        return left == right;
      case TokenType.bangEqual:
        return left != right;
      case TokenType.leftParen:
      case TokenType.rightParen:
      case TokenType.leftBrace:
      case TokenType.rightBrace:
      case TokenType.comma:
      case TokenType.dot:
      case TokenType.semicolon:
      case TokenType.equal:
      case TokenType.bang:
      case TokenType.identifier:
      case TokenType.string:
      case TokenType.number:
      case TokenType.and:
      case TokenType.classT:
      case TokenType.elseT:
      case TokenType.falseT:
      case TokenType.fun:
      case TokenType.forT:
      case TokenType.ifT:
      case TokenType.nil:
      case TokenType.or:
      case TokenType.print:
      case TokenType.returnT:
      case TokenType.superT:
      case TokenType.thisT:
      case TokenType.trueT:
      case TokenType.varT:
      case TokenType.whileT:
      case TokenType.eof:
        return null;
    }
  }

  @override
  Object? visitUnary(UnaryExpr expr) {
    switch (expr.operator.type) {
      case TokenType.minus:
        final value = expr.expr.accept(this);
        if (value is! double) throw 'Expected a number value, but got $value';
        return -value;
      case TokenType.bang:
        final value = expr.expr.accept(this);
        if (value is! bool) throw 'Expected a number value, but got $value';
        return !value;
      case TokenType.leftParen:
      case TokenType.rightParen:
      case TokenType.leftBrace:
      case TokenType.rightBrace:
      case TokenType.comma:
      case TokenType.dot:
      case TokenType.plus:
      case TokenType.semicolon:
      case TokenType.slash:
      case TokenType.star:
      case TokenType.less:
      case TokenType.lessOrEqual:
      case TokenType.equal:
      case TokenType.equalEqual:
      case TokenType.greater:
      case TokenType.greaterOrEqual:
      case TokenType.bangEqual:
      case TokenType.identifier:
      case TokenType.string:
      case TokenType.number:
      case TokenType.and:
      case TokenType.classT:
      case TokenType.elseT:
      case TokenType.falseT:
      case TokenType.fun:
      case TokenType.forT:
      case TokenType.ifT:
      case TokenType.nil:
      case TokenType.or:
      case TokenType.print:
      case TokenType.returnT:
      case TokenType.superT:
      case TokenType.thisT:
      case TokenType.trueT:
      case TokenType.varT:
      case TokenType.whileT:
      case TokenType.eof:
        return null;
    }
  }

  @override
  Object? visitExprStatement(ExprStatement statement) =>
      statement.expr.accept(this);

  @override
  Object? visitPrintStatement(PrintStatement statement) {
    final value = stringify(evaluate(statement.expr));
    _output.print(value);
    return null;
  }

  @override
  Object? visitProgram(Program program) {
    Object? result;
    for (final statement in program.statements) {
      result = evaluateStatement(statement);
    }
    return result;
  }

  @override
  Object? visitVariableDeclaration(VariableDeclaration declaration) {
    final expr = declaration.expr;
    final value = expr != null ? evaluate(expr) : null;
    environment.define(declaration.identifier.value as String, value);
    return null;
  }

  @override
  Object? visitVariable(VariableExpr variable) {
    final name = variable.name.value as String;
    return environment.getValue(name);
  }

  @override
  Object? visitAssign(AssignExpr assign) {
    final name = assign.name.value as String;
    final value = evaluate(assign.value);
    environment.setValue(name, value);
    return value;
  }

  @override
  Object? visitParen(ParenExpr paren) => evaluate(paren.expr);

  @override
  Object? visitBlock(Block block) {
    executeBlock(block.statements, Environment(parent: environment));
    return null;
  }

  @override
  Object? visitCondition(Condition condition) {
    final value = evaluate(condition.expr);
    if (value == true) {
      execute(condition.than);
    } else {
      final elseStatement = condition.elseStatement;
      if (elseStatement != null) {
        execute(elseStatement);
      }
    }

    return null;
  }

  @override
  Object? visitLogic(LogicExpr logic) {
    final value = evaluate(logic.left);

    if (logic.operator.type == TokenType.or) {
      if (isTruthy(value)) return value;
    } else if (!isTruthy(value)) {
      return value;
    }
    return evaluate(logic.right);
  }

  bool isTruthy(Object? value) {
    return value == true;
  }

  @override
  Object? visitWhile(While statement) {
    while (isTruthy(evaluate(statement.expr))) {
      execute(statement.body);
    }
    return null;
  }

  @override
  Object? visitFor(For statement) {
    final initializer = statement.initializer;
    final expr = statement.condition;
    final increment = statement.increment;
    final body = statement.body;
    final oldEnvironment = environment;
    environment = Environment(parent: environment);
    try {
      if (initializer != null) execute(initializer);
      while (expr == null || isTruthy(evaluate(expr))) {
        execute(body);
        if (increment != null) evaluate(increment);
      }
    } finally {
      environment = oldEnvironment;
    }
    return null;
  }

  @override
  Object? visitCall(CallExpr call) {
    final callee = evaluate(call.callee);

    if (callee is! Callable) {
      throw 'Runtime error: expected function or class';
    }

    final arguments = [
      for (final argument in call.arguments) evaluate(argument),
    ];

    if (arguments.length != callee.arity) {
      throw 'Runtime error: Expected ${callee.arity} arguments but got ${arguments.length}.';
    }

    try {
      return callee.invoke(this, arguments);
    } on ReturnError catch (e) {
      return e.value;
    }
  }

  @override
  Object? visitFuncDeclaration(FuncDeclaration func) {
    final name = func.name.toString();
    environment.define(name, Func(environment: environment, func: func));
    return null;
  }

  @override
  Object? visitReturn(Return statement) {
    final expr = statement.expr;
    final value = expr != null ? evaluate(expr) : null;
    throw ReturnError(value: value);
  }
}

class Func extends Callable {
  final FuncDeclaration func;
  final Environment environment;

  Func({required this.environment, required this.func});

  @override
  int get arity => func.params.length;

  @override
  Object? invoke(Interpreter interpreter, List<Object?> arguments) {
    Environment environment = Environment(parent: this.environment);
    for (int i = 0; i < func.params.length; ++i) {
      final param = func.params[i].toString();
      final value = arguments[i];
      environment.define(param, value);
    }

    interpreter.executeBlock(func.body, environment);

    return null;
  }

  @override
  String toString() => '<fn ${func.name}>';
}

abstract class NativeFunc extends Callable {
  @override
  String toString() => '<native fn>';
}

class ClockFunc extends NativeFunc {
  @override
  int get arity => 0;

  @override
  Object? invoke(Interpreter interpreter, List<Object?> arguments) {
    return DateTime.now().millisecondsSinceEpoch / 1000;
  }
}

class ReadLineFunc extends NativeFunc {
  @override
  int get arity => 0;

  @override
  Object? invoke(Interpreter interpreter, List<Object?> arguments) {
    return stdin.readLineSync();
  }
}
