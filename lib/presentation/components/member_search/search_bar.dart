import 'package:flutter/material.dart';

/// A search bar widget for searching members
/// Automatically triggers search on text change without requiring manual submit
class MemberSearchBar extends StatefulWidget {
  final String initialQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final bool autofocus;

  const MemberSearchBar({
    super.key,
    this.initialQuery = '',
    required this.onChanged,
    this.onClear,
    this.autofocus = false,
  });

  @override
  State<MemberSearchBar> createState() => _MemberSearchBarState();
}

class _MemberSearchBarState extends State<MemberSearchBar> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleClear() {
    _controller.clear();
    setState(() {}); // Update UI to remove clear button
    widget.onChanged('');
    widget.onClear?.call();
  }

  void _handleChanged(String value) {
    setState(() {}); // Update UI to show/hide clear button
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      onChanged: _handleChanged,
      decoration: InputDecoration(
        hintText: 'Search for members...',
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant.withAlpha(179),
        ),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, color: colorScheme.onSurfaceVariant),
                onPressed: _handleClear,
              )
            : Icon(Icons.search, color: colorScheme.onSurfaceVariant),
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      textInputAction: TextInputAction.search,
    );
  }
}
