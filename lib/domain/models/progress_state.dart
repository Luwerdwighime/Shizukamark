class OperationStep {
  final String title;
  final bool isCompleted;
  final bool isRunning;

  const OperationStep({
    required this.title,
    this.isCompleted = false,
    this.isRunning = false,
  });

  OperationStep copyWith({
    String? title,
    bool? isCompleted,
    bool? isRunning,
  }) {
    return OperationStep(
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}

class ProgressDialogState {
  final List<OperationStep> steps;
  final double progress;
  final String currentOperation;
  final bool isCancelled;

  const ProgressDialogState({
    required this.steps,
    this.progress = 0.0,
    this.currentOperation = '',
    this.isCancelled = false,
  });

  ProgressDialogState copyWith({
    List<OperationStep>? steps,
    double? progress,
    String? currentOperation,
    bool? isCancelled,
  }) {
    return ProgressDialogState(
      steps: steps ?? this.steps,
      progress: progress ?? this.progress,
      currentOperation: currentOperation ?? this.currentOperation,
      isCancelled: isCancelled ?? this.isCancelled,
    );
  }
}
