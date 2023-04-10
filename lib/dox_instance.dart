import 'package:dox/statement.dart';

class DoxInstance {
  final Klass klass;

  DoxInstance({required this.klass});

  @override
  String toString() => '${klass.name} instance';
}
