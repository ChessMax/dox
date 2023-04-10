import 'package:dox/interpreter.dart';

class DoxInstance {
  final DoxClass klass;
  final Map<String, Object?> properties = {};

  DoxInstance({required this.klass});

  @override
  String toString() => '${klass.klass.name} instance';

  Object? getProperty(String name) {
    if (properties.containsKey(name)) {
      return properties[name];
    }

    final method = klass.findMethod(name);
    if (method != null) return method.bind(this);

    throw 'Runtime error: Undefined property "$name".';
  }

  Object? setProperty(String name, Object? value) => properties[name] = value;
}
