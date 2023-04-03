import 'package:dox/interpreter.dart';

abstract class Callable {
  int get arity;

  Object? invoke(Interpreter interpreter, List<Object?> arguments);
}
