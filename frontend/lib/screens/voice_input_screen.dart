import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketa_expense_tracker/providers/voice_provider.dart';
import 'package:pocketa_expense_tracker/providers/expense_provider.dart';
import 'package:pocketa_expense_tracker/models/expense.dart';
import 'package:intl/intl.dart';

class VoiceInputScreen extends ConsumerWidget {
  const VoiceInputScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceState = ref.watch(voiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Input'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Microphone Button
            GestureDetector(
              onTap: () {
                if (voiceState.isListening) {
                  ref.read(voiceProvider.notifier).stopListening();
                } else {
                  ref.read(voiceProvider.notifier).startListening();
                }
              },
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: voiceState.isListening
                      ? Colors.red
                      : Theme.of(context).colorScheme.primary,
                ),
                child: Icon(
                  voiceState.isListening ? Icons.mic : Icons.mic_none,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Status Text
            Text(
              voiceState.isListening
                  ? 'Listening...'
                  : voiceState.isParsing
                      ? 'Parsing...'
                      : 'Tap to start recording',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            // Transcribed Text
            if (voiceState.transcribedText != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'You said:',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        voiceState.transcribedText!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            // Parsed Result
            if (voiceState.parsedResult != null)
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Parsed Expense:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Amount: ₹${voiceState.parsedResult!['amount']}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        'Category: ${voiceState.parsedResult!['category']}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (voiceState.parsedResult!['description'] != null)
                        Text(
                          'Description: ${voiceState.parsedResult!['description']}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                    ],
                  ),
                ),
              ),
            // Error Message
            if (voiceState.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  voiceState.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const Spacer(),
            // Action Buttons
            if (voiceState.parsedExpense != null)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref.read(voiceProvider.notifier).clear();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final expense = voiceState.parsedExpense!;
                        try {
                          await ref.read(expenseProvider.notifier).createExpense(
                                amount: expense.amount,
                                category: expense.category,
                                description: expense.description,
                              );
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Expense added successfully')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                      child: const Text('Confirm'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
