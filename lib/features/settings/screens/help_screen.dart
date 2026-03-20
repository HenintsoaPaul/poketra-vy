import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../core/widgets/glass_container.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'auto_awesome_rounded':
        return Icons.auto_awesome_rounded;
      case 'psychology_outlined':
        return Icons.psychology_outlined;
      case 'security_rounded':
        return Icons.security_rounded;
      case 'tips_and_updates_outlined':
        return Icons.tips_and_updates_outlined;
      default:
        return Icons.help_outline;
    }
  }

  Future<Map<String, dynamic>> _loadHelpData() async {
    final String response = await rootBundle.loadString(
      'assets/data/help_content.json',
    );
    return json.decode(response);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Help & Information',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: primaryColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadHelpData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading help data: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!['sections'] == null) {
            return const Center(child: Text('No help data found.'));
          }

          final sections = snapshot.data!['sections'] as List<dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...sections.map((section) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: _buildSection(
                      context,
                      title: section['title'],
                      icon: _getIconData(section['icon']),
                      content: (section['subsections'] as List<dynamic>).map((
                        sub,
                      ) {
                        return _buildSubSection(
                          sub['title'],
                          sub['description'],
                        );
                      }).toList(),
                    ),
                  );
                }),
                const SizedBox(height: 16),

                /// Footer
                ..._buildFooter(context),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildFooter(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return [
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
    ];
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
              Icon(icon, size: 18, color: primaryColor.withValues(alpha: 0.7)),
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
