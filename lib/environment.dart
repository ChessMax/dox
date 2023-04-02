class Environment {
  final Environment? parent;
  final _state = <String, Object?>{};

  Environment({this.parent});

  void define(String name, Object? value) => _state[name] = value;

  void setValue(String name, Object? value) {
    if (_state.containsKey(name)) {
      _state[name] = value;
      return;
    }
    final parent = this.parent;
    if (parent != null) {
      parent.setValue(name, value);
    } else {
      throw 'Runtime error: undefined variable "$name".';
    }
  }

  Object? getValue(String name) {
    if (_state.containsKey(name)) {
      return _state[name];
    }

    final parent = this.parent;
    if (parent != null) return parent.getValue(name);

    throw 'Runtime error: undefined variable "$name".';
  }
}
