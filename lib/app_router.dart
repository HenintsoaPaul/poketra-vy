import 'package:go_router/go_router.dart';
import 'features/expenses/screens/expenses_list_screen.dart';
import 'features/expenses/screens/voice_expense_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const ExpensesListScreen(),
    ),
    GoRoute(
      path: '/voice',
      builder: (context, state) => const VoiceExpenseScreen(),
    ),
  ],
);
