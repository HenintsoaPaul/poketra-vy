import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poketra_vy/features/settings/widgets/export_list_tile.dart';
import 'package:poketra_vy/features/settings/widgets/import_list_tile.dart';
import '../../../core/providers/onboarding_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:poketra_vy/features/settings/widgets/reminders_tile.dart';
import '../../expenses/providers/expense_list_provider.dart';
import '../widgets/profile_card.dart';
import '../../../core/widgets/glass_container.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              /// Profile Card
              const ProfileCard(),

              const SizedBox(height: 32),

              /// SETTINGS
              SettingsHeader(),
              const _SettingsContainer(),

              const SizedBox(height: 32),

              /// DAILY REMINDER
              const DailyReminderHeader(),
              const DailyReminderContainer(),

              /// DATA IMPORT & EXPORT
              const DataImportExportHeader(),
              const DataImportExportContainer(),
            ]),
          ),
        ),
      ],
    );
  }
}

class SettingsHeader extends StatelessWidget {
  const SettingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        'SETTINGS',
        style: TextStyle(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.6),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsContainer extends StatelessWidget {
  const _SettingsContainer();

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      opacity: 0.4,
      blur: 20,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          /// Onboarding
          const _OnboardingListTile(),

          /// Divider
          Divider(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            height: 1,
            indent: 64,
          ),

          /// Help
          const _HelpListTile(),
        ],
      ),
    );
  }
}

class _DeleteDataTile extends ConsumerWidget {
  const _DeleteDataTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(
        Icons.delete_forever_outlined,
        color: Colors.redAccent,
      ),
      title: const Text(
        'Delete All Records',
        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),
      ),
      subtitle: const Text(
        'This will delete all expense records but keep your categories and settings.',
        style: TextStyle(color: Colors.black45, fontSize: 13),
      ),
      onTap: () => _showDeleteConfirmation(context, ref),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Delete All Data?',
          style: TextStyle(color: Color(0xFF244B73)),
        ),
        content: const Text(
          'Are you sure you want to delete ALL expense records? This action cannot be undone. Your custom categories and settings will be preserved.',
          style: TextStyle(color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF244B73)),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(expenseListProvider.notifier).deleteAllExpenses();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All records have been deleted.')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}

class _OnboardingListTile extends ConsumerWidget {
  const _OnboardingListTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
      title: Text(
        'Onboarding',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: const Text(
        'Show Onboarding Tour',
        style: TextStyle(color: Colors.black54, fontSize: 13),
      ),
      onTap: () {
        ref.read(onboardingProvider.notifier).resetOnboarding();
        context.go('/onboarding');
      },
    );
  }
}

class _HelpListTile extends ConsumerWidget {
  const _HelpListTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Icon(Icons.help_outline, color: Theme.of(context).primaryColor),
      title: Text(
        'Help',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: const Text(
        'Read about how to use the app',
        style: TextStyle(color: Colors.black54, fontSize: 13),
      ),
      onTap: () {
        context.push('/help');
      },
    );
  }
}

class DailyReminderHeader extends StatelessWidget {
  const DailyReminderHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        'DAILY REMINDER',
        style: TextStyle(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.6),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class DailyReminderContainer extends StatelessWidget {
  const DailyReminderContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 30,
            spreadRadius: -5,
          ),
        ],
      ),
      child: const GlassContainer(
        opacity: 0.6,
        blur: 25,
        color: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 8),
        border: Border.fromBorderSide(
          BorderSide(color: Colors.white, width: 1.5),
        ),
        child: RemindersTile(),
      ),
    );
  }
}

class DataImportExportHeader extends StatelessWidget {
  const DataImportExportHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        'DATA IMPORT & EXPORT',
        style: TextStyle(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.6),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class DataImportExportContainer extends StatelessWidget {
  const DataImportExportContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      opacity: 0.4,
      blur: 20,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          /// Export
          const ExportListTile(),

          /// Divider
          Divider(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            height: 1,
            indent: 64,
          ),

          /// Import
          const ImportListTile(),

          /// Divider
          Divider(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            height: 1,
            indent: 64,
          ),

          /// Delete All Records
          const _DeleteDataTile(),
        ],
      ),
    );
  }
}
