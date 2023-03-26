import 'package:dox/lexer.dart';
import 'package:dox/token.dart';
import 'package:dox/token_type.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:collection/collection.dart';

Function eq = const ListEquality().equals;

void main() {
  test('Should parse number expressions', () {
    final inputs = ['(2)', '1', '99', '123', '123.45', '0.9'];
    final outputs = [
      [
        Token(type: TokenType.leftParen),
        Token(type: TokenType.number, value: 2.0),
        Token(type: TokenType.rightParen),
        Token(type: TokenType.eof),
      ],
      [
        Token(type: TokenType.number, value: 1.0),
        Token(type: TokenType.eof),
      ],
      [
        Token(type: TokenType.number, value: 99.0),
        Token(type: TokenType.eof),
      ],
      [
        Token(type: TokenType.number, value: 123.0),
        Token(type: TokenType.eof),
      ],
      [
        Token(type: TokenType.number, value: 123.45),
        Token(type: TokenType.eof),
      ],
      [
        Token(type: TokenType.number, value: 0.9),
        Token(type: TokenType.eof),
      ],
    ];
    for (int i = 0; i < inputs.length; ++i) {
      final input = inputs[i];
      final output = outputs[i];
      final tokens = Lexer.enumerate(input).toList();
      expect(tokens, output);
    }
  });
  test('Should parse unary expressions', () {
    final inputs = ['e', '!true'];
    final outputs = [
      [
        Token(type: TokenType.identifier, value: 'e'),
        Token(type: TokenType.eof),
      ],
      [
        Token(type: TokenType.bang),
        Token(type: TokenType.trueT, value: true),
        Token(type: TokenType.eof),
      ],
    ];
    for (int i = 0; i < inputs.length; ++i) {
      final input = inputs[i];
      final output = outputs[i];
      final tokens = Lexer.enumerate(input).toList();
      expect(tokens, output);
    }
  });
}
