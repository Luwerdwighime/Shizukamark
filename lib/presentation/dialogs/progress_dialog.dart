import 'package:flutter/material.dart';
import '../../domain/models/progress_state.dart';
import '../../l10n/app_localizations.dart';

class ProgressDialogWidget extends StatelessWidget {
  final ProgressDialogState state;
  final VoidCallback onCancel;

  const ProgressDialogWidget({
    super.key,
    required this.state,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          onCancel();
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. List of operations
              ...state.steps.map((step) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        step.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: step.isRunning ? FontWeight.bold : FontWeight.normal,
                          color: step.isRunning ? Colors.black87 : Colors.black54,
                        ),
                      ),
                      if (step.isCompleted)
                        const Text(
                          '✓',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // black UTF checkmark on light background
                          ),
                        )
                      else if (step.isRunning)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        const SizedBox(width: 16),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 24),

              // 2. LinearProgressIndicator (0.0…1.0)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: state.progress.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: const Color(0xFFE4E7EC),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueGrey),
                ),
              ),

              const SizedBox(height: 12),

              // 3. Text "Выполняется " + toLowerCase(operation)
              Text(
                state.currentOperation.isNotEmpty
                    ? (l10n != null
                        ? l10n.progressRunning(state.currentOperation.toLowerCase())
                        : 'Выполняется ${state.currentOperation.toLowerCase()}')
                    : '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF475467),
                ),
              ),

              const SizedBox(height: 24),

              // 4. Кнопка «Отмена»
              OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFD32F2F),
                  side: const BorderSide(color: Color(0xFFD32F2F)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(l10n?.cancelButton ?? 'Отмена', style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
