import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Services
import '../../../core/services/speech_service.dart';
import '../../../core/services/expense_parser.dart';

// Providers
import '../../category/providers/categories_provider.dart';
import '../providers/expense_list_provider.dart';

// Widgets
import '../../../core/widgets/glass_container.dart';
import '../widgets/expense_form_dialog.dart';
import '../widgets/voice_recording/voice_visualizer.dart';

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
  double _soundLevel = 0;

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

      await _processText(_text);
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
          onSoundLevelChange: (level) {
            setState(() => _soundLevel = level);
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

    final categories = ref.read(categoriesProvider);
    final expense = ExpenseParser.parse(text, categories);
    if (expense != null) {
      setState(() => _isProcessing = false);

      // Show validation dialog
      if (mounted) {
        final editedExpense = await ExpenseFormDialog.show(
          context,
          expense,
          title: 'Confirm Expense',
          subtitle: 'Please review the parsed expense:',
        );

        if (editedExpense != null) {
          // User confirmed, save the expense
          await ref
              .read(expenseListProvider.notifier)
              .addExpense(editedExpense);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Added: ${editedExpense.description} - ${editedExpense.amount}',
                ),
              ),
            );
            context.go('/expenses');
          }
        } else {
          // User cancelled or wants to retry
          setState(() {
            _text = 'Press the mic to start';
            _isListening = false;
            _isProcessing = false;
          });
        }
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// Text + Voice visualizer
          Expanded(
            child: GlassContainer(
              width: double.infinity,
              opacity: 0.1,
              blur: 15,
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _text,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  VoiceVisualizer(
                    soundLevel: _soundLevel,
                    isListening: _isListening,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          if (_isProcessing)
            const CircularProgressIndicator()
          else
            /// IconButton
            GestureDetector(
              onTap: _toggleListening,
              child: GlassContainer(
                width: 120,
                height: 120,
                borderRadius: 60,
                color: Theme.of(context).primaryColor,
                opacity: 0.9,
                blur: 10,
                padding: EdgeInsets.zero,
                child: Center(
                  child: Icon(
                    _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                    color: Colors.white,
                    size: 56,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
