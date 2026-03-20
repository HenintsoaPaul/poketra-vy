import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/glass_container.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Help & Information',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: primaryColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              title: 'HOW TO USE THE APP',
              icon: Icons.auto_awesome_rounded,
              content: [
                _buildSubSection(
                  'Making a Record',
                  'Tap the microphone button in the center of the navigation bar. Simply say what you spent and where. For example: "Lunch for 5000" or "Spent 10000 on groceries at the market".',
                ),
                _buildSubSection(
                  'Modifying a Record',
                  'Go to the "Expenses" tab, find the record you want to change, and tap the edit icon (pencil). You can update the amount, description, or category.',
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: 'PARSING LOGIC',
              icon: Icons.psychology_outlined,
              content: [
                _buildSubSection(
                  'Intelligent Extraction',
                  'Our advanced parser automatically identifies the amount, description, and category from your voice or text input. It looks for numbers and matching keywords in your expense history and category list.',
                ),
                _buildSubSection(
                  'Refining Results',
                  'If the parser isn\'t sure, it will show you a validation dialog where you can confirm or correct the extracted details before saving.',
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: 'DATA PRIVACY',
              icon: Icons.security_rounded,
              content: [
                _buildSubSection(
                  'Local Only Storage',
                  'Your financial data is private and sensitive. That\'s why Poketra Vy stores all your records exclusively on your device. We do not use any cloud servers for your expense data.',
                ),
                _buildSubSection(
                  'No Data Sync',
                  'Because your data stays on your phone, it will never be synced to a cloud account. This ensures you have full control over your information, with no risk of remote data breaches.',
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: 'TIPS',
              icon: Icons.tips_and_updates_outlined,
              content: [
                _buildSubSection(
                  'Check Your Daily Reminders',
                  'Keep your finances on track by setting a daily reminder in the Settings screen. It helps you remember to log your expenses before you forget!',
                ),
              ],
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'Poketra Vy v1.0.0',
                style: TextStyle(
                  color: primaryColor.withValues(alpha: 0.4),
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> content,
  }) {
    final primaryColor = Theme.of(context).primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: primaryColor.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: primaryColor.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.05),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: GlassContainer(
            opacity: 0.4,
            blur: 20,
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.8),
              width: 1,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: content,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubSection(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF244B73),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
