import 'package:dox/string_ext.dart';
import 'package:dox/token.dart';
import 'package:dox/token_type.dart';

class Lexer {
  static Map<String, TokenType> keywords = {
    'and': TokenType.and,
    'class': TokenType.classT,
    'else': TokenType.elseT,
    'false': TokenType.falseT,
    'for': TokenType.forT,
    'fun': TokenType.fun,
    'if': TokenType.ifT,
    'nil': TokenType.nil,
    'or': TokenType.or,
    'print': TokenType.print,
    'return': TokenType.returnT,
    'super': TokenType.superT,
    'this': TokenType.thisT,
    'true': TokenType.trueT,
    'var': TokenType.varT,
    'while': TokenType.whileT,
  };

  static Iterable<Token> enumerate(String content) sync* {
    for (int i = 0; i < content.length; ++i) {
      String? nextChar() => content.length > i + 1 ? content[i + 1] : null;
      void consume() => ++i;
      bool isAtEnd() => i >= content.length;
      bool tryConsumeNext(String char) {
        if (content[i + 1] == char) {
          ++i;
          return true;
        }
        return false;
      }

      final char = content[i];
      switch (char) {
        case '(':
          yield Token(type: TokenType.leftParen);
          break;
        case ')':
          yield Token(type: TokenType.rightParen);
          break;
        case '{':
          yield Token(type: TokenType.leftBrace);
          break;
        case '}':
          yield Token(type: TokenType.rightBrace);
          break;
        case '.':
          yield Token(type: TokenType.dot);
          break;
        case ',':
          yield Token(type: TokenType.comma);
          break;
        case ';':
          yield Token(type: TokenType.semicolon);
          break;
        case '+':
          yield Token(type: TokenType.plus);
          break;
        case '-':
          yield Token(type: TokenType.minus);
          break;
        case '*':
          yield Token(type: TokenType.star);
          break;
        case '/':
          if (tryConsumeNext('/')) {
            consume();
            while (!isAtEnd()) {
              if (content[i] == '\n') {
                break;
              }
              ++i;
            }
            continue;
          }
          yield Token(type: TokenType.slash);
          break;
        case '<':
          if (nextChar() == '=') {
            consume();
            yield Token(type: TokenType.lessOrEqual);
            continue;
          }
          yield Token(type: TokenType.less);
          break;
        case '>':
          if (nextChar() == '=') {
            consume();
            yield Token(type: TokenType.greaterOrEqual);
            continue;
          }
          yield Token(type: TokenType.greater);
          break;
        case '=':
          if (nextChar() == '=') {
            consume();
            yield Token(type: TokenType.equalEqual);
            continue;
          }
          yield Token(type: TokenType.equal);
          break;
        case '!':
          if (nextChar() == '=') {
            consume();
            yield Token(type: TokenType.bangEqual);
            continue;
          }
          yield Token(type: TokenType.bang);
          break;
        case ' ':
        case '\r':
        case '\t':
        case '\n':
          // TODO: line number
          continue;
        case '"':
          consume();
          int startIndex = i;
          String? value;
          while (!isAtEnd()) {
            String char = content[i];
            ++i;
            if (char == '"') {
              value = content.substring(startIndex, i - 1);
              break;
            }
          }
          if (value != null) {
            yield Token(type: TokenType.string, value: value);
            break;
          } else {
            throw 'Unterminated string';
          }
        default:
          if (char.isDigit) {
            int startIndex = i;
            consume();

            while (!isAtEnd()) {
              final char = content[i];
              if (char.isDigit) {
                ++i;
                continue;
              }

              if (char == '.' && nextChar()?.isDigit == true) {
                ++i;
                ++i;
                continue;
              } else {
                break;
              }
            }
            final value = double.parse(content.substring(startIndex, i--));
            yield Token(type: TokenType.number, value: value);
            break;
          } else if (char.isAlpha) {
            int startIndex = i;
            consume();
            while (!isAtEnd()) {
              final char = content[i];
              if (char.isAlphaNumeric) {
                ++i;
                continue;
              }
              break;
            }

            final value = content.substring(startIndex, i--);
            final type = keywords[value];
            yield Token(type: type ?? TokenType.identifier, value: value);
            break;
          }
          throw 'Unexpected character';
      }
    }

    yield const Token(type: TokenType.eof);
  }
}
