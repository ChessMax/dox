class RuntimeError {}

class ReturnError extends RuntimeError {
  final Object? value;

  ReturnError({required this.value});
}
