import 'package:flutter/material.dart';
import 'package:mastercs_mobile/models/member.dart';
import 'package:mastercs_mobile/presentation/app/camp/camp_members/member_small_list_item.dart';

class StaffList extends StatefulWidget {
  final Member owner;
  final List<Member> staff;

  const StaffList({super.key, required this.owner, required this.staff});

  @override
  State<StaffList> createState() => _StaffListState();
}

class _StaffListState extends State<StaffList> {
  bool _expanded = false;
  static const int _collapsedCount = 6;

  bool get _hasMore => (widget.staff.length + 1) > _collapsedCount;

  List<Member> get _displayedMembers {
    final allMembers = [widget.owner, ...widget.staff];
    if (!_expanded && _hasMore) {
      return allMembers.take(_collapsedCount).toList();
    }
    return allMembers;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Owner & Staff',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 6),

        AnimatedSize(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 4,
            ),
            itemCount: _displayedMembers.length,
            itemBuilder: (context, index) {
              return MemberSmallListItem(
                member: _displayedMembers[index],
                backgroundColor: colorScheme.surfaceContainer,
              );
            },
          ),
        ),

        if (_hasMore) ...[
          SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
              icon: Icon(
                _expanded ? Icons.expand_less : Icons.expand_more,
                size: 18,
              ),
              label: Text(_expanded ? 'See Less' : 'See More'),
              style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
            ),
          ),
        ],
      ],
    );
  }
}
