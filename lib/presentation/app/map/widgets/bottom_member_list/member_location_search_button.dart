import 'package:flutter/material.dart';
import 'package:mastercs_mobile/presentation/app/map/widgets/search/location_search_bottom_sheet.dart';

class MemberLocationSearchButton extends StatelessWidget {
  const MemberLocationSearchButton({super.key});

  void _openSearchBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      builder: (context) => const MapExtendedList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => _openSearchBottomSheet(context),
      child: SizedBox(
        width: 56,
        height: 56,
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(30),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.person_search,
            color: colorScheme.onSurface,
            size: 28,
          ),
        ),
      ),
    );
  }
}
