/// Functional Result type as defined in the project specification:
/// `typedef Result<T> = ({T? value, String? error});`
typedef Result<T> = ({T? value, String? error});

Result<T> success<T>(T value) => (value: value, error: null);

Result<T> failure<T>(String error) => (value: null, error: error);

extension ResultExtension<T> on Result<T> {
  bool get isSuccess => error == null;
  bool get isError => error != null;
}
