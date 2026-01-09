import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketa_expense_tracker/services/voice_service.dart';
import 'package:pocketa_expense_tracker/models/expense.dart';

class VoiceState {
  final bool isListening;
  final String? transcribedText;
  final Map<String, dynamic>? parsedResult;
  final bool isParsing;
  final String? error;

  VoiceState({
    this.isListening = false,
    this.transcribedText,
    this.parsedResult,
    this.isParsing = false,
    this.error,
  });

  VoiceState copyWith({
    bool? isListening,
    String? transcribedText,
    Map<String, dynamic>? parsedResult,
    bool? isParsing,
    String? error,
  }) {
    return VoiceState(
      isListening: isListening ?? this.isListening,
      transcribedText: transcribedText ?? this.transcribedText,
      parsedResult: parsedResult ?? this.parsedResult,
      isParsing: isParsing ?? this.isParsing,
      error: error,
    );
  }

  Expense? get parsedExpense {
    if (parsedResult == null) return null;
    return Expense(
      id: '',
      userId: '',
      amount: (parsedResult!['amount'] as num).toDouble(),
      category: Category.fromString(parsedResult!['category'] as String),
      description: parsedResult!['description'] as String?,
      date: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

class VoiceNotifier extends StateNotifier<VoiceState> {
  VoiceNotifier() : super(VoiceState()) {
    _init();
  }

  final _voiceService = VoiceService();
  bool _isInitializing = false;

  Future<void> _init() async {
    try {
      _isInitializing = true;
      final initialized = await _voiceService.initialize();
      if (!initialized) {
        state = state.copyWith(
          error: 'Speech recognition initialization failed. Please check permissions and try again.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to initialize speech recognition: $e',
      );
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> startListening() async {
    // Clear any previous errors
    state = state.copyWith(error: null);

    // Try to initialize if not available
    if (!_voiceService.isAvailable && !_isInitializing) {
      await _init();
    }

    // If still not available after initialization attempt, show error
    if (!_voiceService.isAvailable) {
      state = state.copyWith(
        error: 'Speech recognition is not available. Please:\n'
            '1. Check microphone permissions in Settings\n'
            '2. Ensure speech recognition is enabled\n'
            '3. Try again',
      );
      return;
    }

    state = state.copyWith(
      isListening: true,
      transcribedText: null,
      parsedResult: null,
      error: null,
    );

    await _voiceService.startListening(
      onResult: (text) async {
        if (text.isNotEmpty) {
          state = state.copyWith(transcribedText: text);
          await _parseText(text);
        }
      },
      onError: (error) {
        state = state.copyWith(
          isListening: false,
          error: error,
        );
      },
    );
  }

  Future<void> stopListening() async {
    await _voiceService.stopListening();
    state = state.copyWith(isListening: false);
  }

  Future<void> cancelListening() async {
    await _voiceService.cancelListening();
    state = VoiceState();
  }

  Future<void> _parseText(String text) async {
    state = state.copyWith(isParsing: true, error: null);
    try {
      final result = await _voiceService.parseText(text);
      state = state.copyWith(
        parsedResult: result,
        isParsing: false,
      );
    } catch (e) {
      state = state.copyWith(
        isParsing: false,
        error: e.toString(),
      );
    }
  }

  void clear() {
    state = VoiceState();
  }
}

final voiceProvider = StateNotifierProvider<VoiceNotifier, VoiceState>((ref) {
  return VoiceNotifier();
});
