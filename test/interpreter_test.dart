import 'package:dox/interpreter.dart';
import 'package:dox/lexer.dart';
import 'package:dox/output.dart';
import 'package:dox/parser.dart';
import 'package:dox/resolver.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  final output = TestOutput();
  final interpreter = Interpreter(output);

  test('Should parse expressions', () {
    final inputs = <String, Object?>{
      '(2 + 3)': 5.0,
      '-5 * (-1)': 5.0,
      '!true': false,
      '!!!!(true)': true,
      '8 - 3 * 2': 2.0,
      '(8 - 3) * 2': 10.0,
      '5 + 4 > 4': true,
      '8 * 2 == 4 + 4 + 4 + 4': true,
      '6 / 3 != 2': false,
      '(5 - (3 - 1)) + -1': 2.0,
      '"hello " + "world"': 'hello world',
      'true and true': true,
      'true and false': false,
      'false and true': false,
      'true or false': true,
      'true or true': true,
      'false or true': true,
      'false or false': false,
      '5 > 6 or 6 > 4': true,
      '5 > 0 and 6 < 4 or true != false': true,
      'true or a > 4': true,
      'false and a > 4': false,
    };

    for (final kv in inputs.entries) {
      output.clear();

      final input = kv.key;
      final expected = kv.value;

      final tokens = Lexer.enumerate(input);
      final parser = Parser(tokens: tokens.toList());
      final expr = parser.parseExpression();
      final resolver = Resolver(interpreter: interpreter);
      resolver.resolveExpression(expr);
      final actual = interpreter.evaluate(expr);

      expect(actual, expected, reason: input);
    }
  });

  test('Should evaluate statements', () {
    final inputs = <String, Object?>{
      'print nil;': 'nil',
      'print !(5 > 3);': 'false',
      'print 5 + 4;': '9',
      'print (2 + 3);': '5',
      'print -5 * (-1);': '5',
      'print !true;': 'false',
      'print !!!!(true);': 'true',
      'print 8 - 3 * 2;': '2',
      'print (8 - 3) * 2;': '10',
      'print 5 + 4 > 4;': 'true',
      'print 8 * 2 == 4 + 4 + 4 + 4;': 'true',
      'print 6 / 3 != 2;': 'false',
      'print (5 - (3 - 1)) + -1;': '2',
      'print 2.3 + 3.2;': '5.5',
      'print "one";': 'one',
      'print true;': 'true',
      'print 2 + 1;': '3',
    };

    for (final kv in inputs.entries) {
      output.clear();

      final input = kv.key;
      final expected = kv.value;

      final tokens = Lexer.enumerate(input);
      final parser = Parser(tokens: tokens.toList());
      final statement = parser.parse();
      final resolver = Resolver(interpreter: interpreter);
      resolver.resolveStatement(statement);
      interpreter.execute(statement);

      expect(output.output, expected, reason: input);
    }
  });

  test('Should execute blocks', () {
    final inputs = <String, Object?>{
      '''var a = 5;
       {
        var a = 4;
        a = a + 1;
       }
       print a;
       ''': '5'
    };

    for (final kv in inputs.entries) {
      output.clear();

      final input = kv.key;
      final expected = kv.value;

      final tokens = Lexer.enumerate(input);
      final parser = Parser(tokens: tokens.toList());
      final statement = parser.parse();
      final resolver = Resolver(interpreter: interpreter);
      resolver.resolveStatement(statement);
      interpreter.execute(statement);

      expect(output.output, expected, reason: input);
    }
  });

  test('Should execute conditions', () {
    final inputs = <String, Object?>{
      '''var a = 5;
       if (a == 5) {
        print true;
       }
       else print false;
       ''': 'true',
      '''var a = 6;
       if (a == 5) {
        print true;
       }
       else print false;
       ''': 'false',
      '''var a = 6;
       if (true) 
        if (false) print true;
        else print false;
       ''': 'false',
    };

    for (final kv in inputs.entries) {
      output.clear();

      final input = kv.key;
      final expected = kv.value;

      final tokens = Lexer.enumerate(input);
      final parser = Parser(tokens: tokens.toList());
      final statement = parser.parse();
      final resolver = Resolver(interpreter: interpreter);
      resolver.resolveStatement(statement);
      interpreter.execute(statement);

      expect(output.output, expected, reason: input);
    }
  });

  test('Should execute loops', () {
    final inputs = <String, Object?>{
      '''var a = 5;
       while (a < 10) {
        a = a + 2;
       }
       print a;
       ''': '11',
      '''
       var a = 0;
       for (var i = 0; i < 10; i = i + 1) {
        a = a + 2;
       }
       print a;
       ''': '20',
      '''
       var a = 0;
       var i;
       for (i = 0; i < 10; i = i + 1) {
        a = a + 2;
       }
       print a;
       ''': '20',
    };

    for (final kv in inputs.entries) {
      output.clear();

      final input = kv.key;
      final expected = kv.value;

      final tokens = Lexer.enumerate(input);
      final parser = Parser(tokens: tokens.toList());
      final statement = parser.parse();
      final resolver = Resolver(interpreter: interpreter);
      resolver.resolveStatement(statement);
      interpreter.execute(statement);

      expect(output.output, expected, reason: input);
    }
  });

  test('Should define and evaluate functions', () {
    final inputs = <String, Object?>{
      '''fun add(a, b) {
        return a + b;
      }
      print add(5, 6);
      ''': '11',
      '''fun add(a, b) {
        if (a > b) return a;
        return b;
      }
      print add(5, 6);
      ''': '6',
      // TODO: nice to be able to return value here
      '''fun add2(a, b) {
        return a + b;
      }
      add2(5, 6);
      ''': '',
      '''fun printMin(a, b) {
        if (a < b) {
          print a;
          return;
        }
        print b;
        return;
      }
      printMin(5, 6);
      ''': '5',
    };

    for (final kv in inputs.entries) {
      output.clear();

      final input = kv.key;
      final expected = kv.value;

      final tokens = Lexer.enumerate(input);
      final parser = Parser(tokens: tokens.toList());
      final statement = parser.parse();
      final resolver = Resolver(interpreter: interpreter);
      resolver.resolveStatement(statement);
      interpreter.execute(statement);

      expect(output.output, expected, reason: input);
    }
  });

  test('Closures should work', () {
    final inputs = <String, Object?>{
      '''fun makeCounter() {
        var i = 0;
        fun count() {
          i = i + 1;
          print i;
        }
        return count;
      }
      
      var counter = makeCounter();
      counter();
      counter();
      ''': '1\n2',
      '''
      var a = "global";
      {
       fun showA() {
       print a;
       }
       showA();
       var a = "block";
       showA();
      }
      ''': 'global\nglobal',
    };

    for (final kv in inputs.entries) {
      output.clear();

      final input = kv.key;
      final expected = kv.value;

      final tokens = Lexer.enumerate(input);
      final parser = Parser(tokens: tokens.toList());
      final statement = parser.parse();
      final resolver = Resolver(interpreter: interpreter);
      resolver.resolveStatement(statement);
      interpreter.execute(statement);

      expect(output.output, expected, reason: input);
    }
  });

  test('Should initialize variables', () {
    final inputs = <String, Object?>{
      'var name;': '',
      'var surname = "Ivanov";': '',
      'var age = 5 + 9 * 10;': '',
      'var middleName; var id;': '',
      'var movie = "Sweet Home"; print movie;': 'Sweet Home',
      'var a = 1; var b = 2; var c = a + b; print c;': '3',
      'var variable; print variable;': 'nil',
    };

    for (final kv in inputs.entries) {
      output.clear();

      final input = kv.key;
      final expected = kv.value;

      final tokens = Lexer.enumerate(input);
      final parser = Parser(tokens: tokens.toList());
      final statement = parser.parse();
      final resolver = Resolver(interpreter: interpreter);
      resolver.resolveStatement(statement);
      interpreter.execute(statement);

      expect(output.output, expected, reason: input);
    }
  });

  test('Should assign variable', () {
    final inputs = <String, Object?>{
      'var name; name = "Ivan"; print name;': 'Ivan',
      'var a = 5; var b = 6; var c; c = a + b; print c;': '11',
      'var a = 5; a = 6; a = 7; print a;': '7',
      'var a = 5; a = true; print a;': 'true',
      'var a = false; a = nil; print a;': 'nil',
    };

    for (final kv in inputs.entries) {
      output.clear();

      final input = kv.key;
      final expected = kv.value;

      final tokens = Lexer.enumerate(input);
      final parser = Parser(tokens: tokens.toList());
      final statement = parser.parse();
      final resolver = Resolver(interpreter: interpreter);
      resolver.resolveStatement(statement);
      interpreter.execute(statement);

      expect(output.output, expected, reason: input);
    }
  });

  test('Classes should work', () {
    final inputs = <String, Object?>{
      '''class DevonshireCream {
        serveOn() {
          return "Scones";
        }
      }
      print DevonshireCream;
      ''': 'DevonshireCream',
      '''class Bagel {}
      var bagel = Bagel();
      print bagel;
      ''': 'Bagel instance',
      '''
      class User {}
      var user = User();
      user.name = "Ivan";
      print user.name;
      ''': 'Ivan',
      '''
      class Bacon {
        eat() {
          print "Crunch crunch crunch!";
        }
      }
      
      Bacon().eat();
      ''': 'Crunch crunch crunch!',
      '''
      class Egotist {
        speak() {
          print this;
        }
      }
      var method = Egotist().speak;
      method();
      ''': 'Egotist instance',
      '''
      class Cake {
       taste() {
        var adjective = "delicious";
        print "The " + this.flavor + " cake is " + adjective + "!";
       }
      }
      var cake = Cake();
      cake.flavor = "German chocolate";
      cake.taste();
      ''': 'The German chocolate cake is delicious!',
      '''
      class Thing {
       getCallback() {
        fun localFunction() {
          print this;
        }
        return localFunction;
       }
      }
      var callback = Thing().getCallback();
      callback();
      ''': 'Thing instance',
      '''
      class Foo {
        init() {
          print this;
        }
      }
      var foo = Foo();
      ''': 'Foo instance',
      '''
      class Foo {
        init() {
          print this;
        }
      }
      var foo = Foo();
      foo.init();
      ''': 'Foo instance\nFoo instance',
    };

    for (final kv in inputs.entries) {
      output.clear();

      final input = kv.key;
      final expected = kv.value;

      final tokens = Lexer.enumerate(input);
      final parser = Parser(tokens: tokens.toList());
      final statement = parser.parse();
      final resolver = Resolver(interpreter: interpreter);
      resolver.resolveStatement(statement);
      interpreter.execute(statement);

      expect(output.output, expected, reason: input);
    }
  });

  test('Class inheritance should work', () {
    final inputs = <String, Object?>{
      '''
      class Doughnut {}
      class BosonCream < Doughnut {}
      ''': '',
      '''
      class Doughnut {
       cook() {
        print "Fry until golden brown.";
       }
      }
      class BostonCream < Doughnut {}
      BostonCream().cook();
      ''': 'Fry until golden brown.',
      '''
      class Doughnut {
       cook() {
        print "Fry until golden brown.";
       }
      }
      class BostonCream < Doughnut {
       cook() {
         super.cook();
         print "Pipe full of custard and coat with chocolate.";
       }
      }
      BostonCream().cook();
      ''': 'Fry until golden brown.\n'
              'Pipe full of custard and coat with chocolate.',
      '''
      class A {
       method() {
        print "Method A";
       }
      }
      class B < A {
       method() {
        print "Method B";
       }
       test() {
        super.method();
       }
      }
      class C < B {}
      C().test();
      ''': 'Method A',
    };

    for (final kv in inputs.entries) {
      output.clear();

      final input = kv.key;
      final expected = kv.value;

      final tokens = Lexer.enumerate(input);
      final parser = Parser(tokens: tokens.toList());
      final statement = parser.parse();
      final resolver = Resolver(interpreter: interpreter);
      resolver.resolveStatement(statement);
      interpreter.execute(statement);

      expect(output.output, expected, reason: input);
    }
  });
}
