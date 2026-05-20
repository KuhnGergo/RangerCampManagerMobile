import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Help & Support',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          // FAQ section
          _SectionHeader(
            title: 'Frequently Asked Questions',
            colorScheme: colorScheme,
          ),
          _HelpCard(
            colorScheme: colorScheme,
            children: [
              _FaqTile(
                question: 'How do I join a camp?',
                answer:
                    'You can join a camp by entering a join code or scanning a QR code '
                    'from the camp selection screen. Ask your camp organizer for the code.',
                colorScheme: colorScheme,
              ),
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: colorScheme.outlineVariant.withAlpha(80),
              ),

              _FaqTile(
                question: 'How can I leave my group or room?',
                answer:
                    'If you are staff or owner you don\'t have any. '
                    'As a camper you can manage your group and room by tapping on the chat long or pressing the three line icon.',
                colorScheme: colorScheme,
              ),
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: colorScheme.outlineVariant.withAlpha(80),
              ),
              _FaqTile(
                question: 'How do I reset my password?',
                answer:
                    'On the login screen, tap "Forgot Password" and enter your email. '
                    'You will receive instructions to reset your password.',
                colorScheme: colorScheme,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Contact section
          _SectionHeader(title: 'Contact Us', colorScheme: colorScheme),
          _HelpCard(
            colorScheme: colorScheme,
            children: [
              _ContactTile(
                icon: Icons.email_outlined,
                title: 'Email Support',
                subtitle: 'rangercampmanager@gmail.com',
                colorScheme: colorScheme,
                onTap: () => launchUrl(
                  Uri(
                    scheme: 'mailto',
                    path: 'rangercampmanager@gmail.com',
                    queryParameters: {'subject': 'MasterCS Support'},
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final ColorScheme colorScheme;

  const _SectionHeader({required this.title, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurfaceVariant,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  final ColorScheme colorScheme;
  final List<Widget> children;

  const _HelpCard({required this.colorScheme, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;
  final ColorScheme colorScheme;

  const _FaqTile({
    required this.question,
    required this.answer,
    required this.colorScheme,
  });

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: widget.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: widget.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    widget.answer,
                    style: TextStyle(
                      fontSize: 14,
                      color: widget.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ),
                crossFadeState: _expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final ColorScheme colorScheme;
  final VoidCallback? onTap;

  const _ContactTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colorScheme,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 22, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
