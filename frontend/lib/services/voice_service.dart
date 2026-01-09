import 'dart:io';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:pocketa_expense_tracker/services/api_service.dart';
import 'package:flutter/foundation.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isAvailable = false;

  Future<bool> initialize() async {
    try {
      // Check microphone permission first
      final micStatus = await Permission.microphone.status;
      if (!micStatus.isGranted) {
        print('Requesting microphone permission...');
        final requested = await Permission.microphone.request();
        if (!requested.isGranted) {
          print('Microphone permission denied');
          return false;
        }
      }
      print('Microphone permission granted');

      // Initialize speech recognition
      _isAvailable = await _speech.initialize(
        onStatus: (status) {
          print('Speech recognition status: $status');
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
          }
        },
        onError: (error) {
          print('Speech recognition error: ${error.errorMsg}');
          _isListening = false;
        },
      );

      if (!_isAvailable) {
        print('Speech recognition initialization failed');
        if (Platform.isIOS && !kIsWeb && kDebugMode) {
          print('⚠️ IMPORTANT: Speech recognition does NOT work on iOS Simulator.');
          print('Please test on a physical iOS device.');
        }
      } else {
        print('Speech recognition initialized successfully');
      }

      return _isAvailable;
    } catch (e) {
      print('Error initializing speech recognition: $e');
      _isAvailable = false;
      return false;
    }
  }

  bool get isAvailable => _isAvailable;
  bool get isListening => _isListening;

  Future<void> startListening({
    required Function(String text) onResult,
    Function(String error)? onError,
  }) async {
    try {
      // Check if speech recognition is available
      if (!_isAvailable) {
        print('Speech recognition not initialized, attempting to initialize...');
        final initialized = await initialize();
        if (!initialized) {
          // Check microphone permission
          final micStatus = await Permission.microphone.status;
          if (!micStatus.isGranted) {
            onError?.call('Microphone permission is required. Please grant microphone access in Settings > Privacy & Security > Microphone.');
            return;
          }
          
          String errorMsg = 'Speech recognition initialization failed.';
          if (Platform.isIOS && !kIsWeb) {
            errorMsg += '\n\n⚠️ IMPORTANT: Speech recognition does NOT work on iOS Simulator.\n'
                'Please test on a physical iOS device.\n\n'
                'If you are on a physical device, please ensure:\n'
                '1. Microphone permission is granted in Settings\n'
                '2. Speech recognition is enabled in Settings > Privacy & Security\n'
                '3. Your device supports speech recognition';
          } else {
            errorMsg += '\n\nPlease ensure:\n'
                '1. Microphone permission is granted\n'
                '2. Speech recognition is enabled in device settings\n'
                '3. Your device supports speech recognition';
          }
          onError?.call(errorMsg);
          return;
        }
      }

      if (_isListening) {
        print('Already listening, ignoring start request');
        return;
      }

      // Check microphone permission before starting
      final micStatus = await Permission.microphone.status;
      if (!micStatus.isGranted) {
        final requested = await Permission.microphone.request();
        if (!requested.isGranted) {
          onError?.call('Microphone permission is required. Please grant microphone access in Settings.');
          return;
        }
      }

      _isListening = true;
      print('Starting speech recognition...');
      
      final available = await _speech.listen(
        onResult: (result) {
          print('Speech result: ${result.recognizedWords} (final: ${result.finalResult})');
          if (result.finalResult) {
            _isListening = false;
            onResult(result.recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        localeId: 'en_US', // Specify locale for better recognition
        cancelOnError: false,
        partialResults: true,
      );

      if (!available) {
        _isListening = false;
        onError?.call('Failed to start listening. Please check microphone permissions and try again.');
      }
    } catch (e) {
      print('Error starting speech recognition: $e');
      _isListening = false;
      onError?.call('Error starting speech recognition: $e');
    }
  }

  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
  }

  Future<void> cancelListening() async {
    if (_isListening) {
      await _speech.cancel();
      _isListening = false;
    }
  }

  Future<Map<String, dynamic>> parseText(String text) async {
    try {
      return await ApiService().parseVoiceInput(text);
    } catch (e) {
      throw Exception('Failed to parse voice input: $e');
    }
  }
}
