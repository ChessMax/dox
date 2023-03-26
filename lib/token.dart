import 'package:dox/token_type.dart';
import 'package:equatable/equatable.dart';

class Token extends Equatable {
  final TokenType type;
  final Object? value;

  const Token({
    required this.type,
    this.value,
  });

  @override
  List<Object?> get props => [type, value];

  @override
  String toString() {
    switch (type) {
      case TokenType.leftParen:
        return '(';
      case TokenType.rightParen:
        return ')';
      case TokenType.leftBrace:
        return '[';
      case TokenType.rightBrace:
        return ']';
      case TokenType.comma:
        return ',';
      case TokenType.dot:
        return '.';
      case TokenType.minus:
        return '-';
      case TokenType.plus:
        return '+';
      case TokenType.semicolon:
        return ';';
      case TokenType.slash:
        return '/';
      case TokenType.star:
        return '*';
      case TokenType.less:
        return '<';
      case TokenType.lessOrEqual:
        return '<=';
      case TokenType.equal:
        return '=';
      case TokenType.equalEqual:
        return '==';
      case TokenType.greater:
        return '>';
      case TokenType.greaterOrEqual:
        return '>=';
      case TokenType.bang:
        return '!';
      case TokenType.bangEqual:
        return '!=';
      case TokenType.identifier:
        return value.toString();
      case TokenType.string:
        return '"$value"';
      case TokenType.number:
        return value.toString();
      case TokenType.and:
        return 'and';
      case TokenType.classT:
        return 'class';
      case TokenType.elseT:
        return 'else';
      case TokenType.falseT:
        return 'false';
      case TokenType.fun:
        return 'fun';
      case TokenType.forT:
        return 'for';
      case TokenType.ifT:
        return 'if';
      case TokenType.nil:
        return 'nil';
      case TokenType.or:
        return 'or';
      case TokenType.print:
        return 'print';
      case TokenType.returnT:
        return 'return';
      case TokenType.superT:
        return 'super';
      case TokenType.thisT:
        return 'this';
      case TokenType.trueT:
        return 'true';
      case TokenType.varT:
        return 'var';
      case TokenType.whileT:
        return 'while';
      case TokenType.eof:
        return 'eof';
    }
  }
}
