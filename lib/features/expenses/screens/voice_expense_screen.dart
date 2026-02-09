import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/speech_service.dart';
import '../../../core/services/expense_parser.dart';
import '../providers/expenses_provider.dart';
import '../widgets/expense_validation_dialog.dart';

class VoiceExpenseScreen extends ConsumerStatefulWidget {
  const VoiceExpenseScreen({super.key});

  @override
  ConsumerState<VoiceExpenseScreen> createState() => _VoiceExpenseScreenState();
}

class _VoiceExpenseScreenState extends ConsumerState<VoiceExpenseScreen> {
  final SpeechService _speechService = SpeechService();
  String _text = 'Press the mic to start';
  bool _isListening = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    bool available = await _speechService.init();
    if (!available) {
      setState(() => _text = 'Speech recognition not available');
    }
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speechService.stopListening();
      setState(() => _isListening = false);

      if (_text == 'Listening...' || _text.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No speech detected. Please try again.'),
            ),
          );
        }
        setState(() => _text = 'Press the mic to start');
        return;
      }

      _processText(_text);
    } else {
      bool available = await _speechService.init();
      if (available) {
        setState(() {
          _isListening = true;
          _text = 'Listening...';
        });
        await _speechService.startListening(
          onResult: (result) {
            setState(() => _text = result);
          },
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Microphone permission denied or speech unavailable.',
              ),
            ),
          );
          setState(() => _text = 'Speech unavailable');
        }
      }
    }
  }

  Future<void> _processText(String text) async {
    setState(() => _isProcessing = true);

    final expense = ExpenseParser.parse(text);
    if (expense != null) {
      setState(() => _isProcessing = false);

      // Show validation dialog
      if (mounted) {
        final confirmed = await ExpenseValidationDialog.show(context, expense);

        if (confirmed == true) {
          // User confirmed, save the expense
          await ref.read(expensesProvider.notifier).addExpense(expense);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Added: ${expense.description} - ${expense.amount}',
                ),
              ),
            );
            context.go('/expenses');
          }
        } else if (confirmed == false) {
          // User wants to retry
          setState(() {
            _text = 'Press the mic to start';
            _isListening = false;
            _isProcessing = false;
          });
        }
        // If confirmed is null (dialog dismissed), do nothing
      }
    } else {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not understand expense. Try extracting amount and category.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Entry')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _text,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 48),
              if (_isProcessing)
                const CircularProgressIndicator()
              else
                FloatingActionButton.large(
                  onPressed: _toggleListening,
                  child: Icon(_isListening ? Icons.stop : Icons.mic),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
