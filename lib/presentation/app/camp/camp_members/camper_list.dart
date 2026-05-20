import 'package:flutter/material.dart';
import 'package:mastercs_mobile/models/member.dart';
import 'package:mastercs_mobile/presentation/components/member/member_info_item.dart';

class CamperList extends StatefulWidget {
  final List<Member> campers;

  const CamperList({super.key, required this.campers});

  @override
  State<CamperList> createState() => _CamperListState();
}

class _CamperListState extends State<CamperList> {
  bool _expanded = false;
  static const int _collapsedCount = 5;

  bool get _hasMore => widget.campers.length > _collapsedCount;

  List<Member> get _displayedMembers {
    if (!_expanded && _hasMore) {
      return widget.campers.take(_collapsedCount).toList();
    }
    return widget.campers;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (widget.campers.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Campers',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Spacer(),
            Text(
              '${widget.campers.length}',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),

        AnimatedSize(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Column(
            children: _displayedMembers.map((member) {
              return Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: MemberInfoItem(
                  member: member,
                  showRole: false,
                  showGroup: true,
                  showRoom: true,
                ),
              );
            }).toList(),
          ),
        ),

        if (_hasMore) ...[
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
