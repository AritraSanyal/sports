import 'package:flutter/material.dart';
import 'package:flutter_app/theme/app_theme.dart';

class PolicySection {
  final String heading;
  final String body;

  const PolicySection({required this.heading, required this.body});
}

class PolicyScreen extends StatelessWidget {
  final String title;
  final List<PolicySection> sections;

  const PolicyScreen({super.key, required this.title, required this.sections});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Container(
        color: Colors.white,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final s = sections[index];
            return _PolicyCard(section: s);
          },
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: sections.length,
        ),
      ),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  final PolicySection section;

  const _PolicyCard({required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section.heading,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              section.body,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
