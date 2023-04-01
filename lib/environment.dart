class Environment {
  final Environment? parent;
  final _environment = <String, Object?>{};

  Environment({this.parent});

  void define(String name, Object? value) => _environment[name] = value;

  void setValue(String name, Object? value) {
    if (_environment.containsKey(name)) {
      _environment[name] = value;
    }
    final parent = this.parent;
    if (parent != null) {
      setValue(name, value);
    } else {
      throw 'Runtime error: undefined variable "$name".';
    }
  }

  Object? getValue(String name) {
    if (_environment.containsKey(name)) {
      return _environment[name];
    }

    final parent = this.parent;
    if (parent != null) return parent.getValue(name);

    throw 'Runtime error: undefined variable "$name".';
  }
}
