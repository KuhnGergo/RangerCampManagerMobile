import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/models/chat_types.dart';

final chatFilterProvider =
    NotifierProvider<ChatFilterProvider, ChatFilterState>(
      () => ChatFilterProvider(),
    );

class ChatFilterProvider extends Notifier<ChatFilterState> {
  @override
  ChatFilterState build() {
    return ChatFilterState();
  }

  void setFilter(ChatType? type) {
    state = state.copyWith(filterType: type);
  }

  void setOrderBy(List<OrderSubject> orderBy) {
    state = state.copyWith(orderBy: orderBy);
  }

  void toggleGroupByType() {
    state = state.copyWith(groupByType: !state.groupByType);
  }

  void toggleShowArchived() {
    state = state.copyWith(showArchived: !state.showArchived);
  }

  void promoteOrder(OrderSubject order) {
    final currentOrder = List<OrderSubject>.from(state.orderBy);
    final currentIndex = currentOrder.indexOf(order);

    if (currentIndex > 0) {
      currentOrder.removeAt(currentIndex);
      currentOrder.insert(currentIndex - 1, order);
      state = state.copyWith(orderBy: currentOrder);
    }
  }

  void demoteOrder(OrderSubject order) {
    final currentOrder = List<OrderSubject>.from(state.orderBy);
    final currentIndex = currentOrder.indexOf(order);

    if (currentIndex < currentOrder.length - 1) {
      currentOrder.removeAt(currentIndex);
      currentOrder.insert(currentIndex + 1, order);
      state = state.copyWith(orderBy: currentOrder);
    }
  }
}

enum OrderSubject {
  lastMessage,
  name,
  createdAt;

  String get getLabel {
    switch (this) {
      case OrderSubject.lastMessage:
        return 'Last Message';
      case OrderSubject.name:
        return 'Name';
      case OrderSubject.createdAt:
        return 'Created At';
    }
  }

  IconData get getIcon {
    switch (this) {
      case OrderSubject.lastMessage:
        return Icons.schedule;
      case OrderSubject.name:
        return Icons.sort_by_alpha;
      case OrderSubject.createdAt:
        return Icons.calendar_today;
    }
  }
}

class ChatFilterState {
  final bool groupByType;
  final bool showArchived;
  final List<OrderSubject> orderBy;
  final ChatType? filterType;

  ChatFilterState({
    this.groupByType = false,
    this.showArchived = true,
    this.orderBy = const [
      OrderSubject.lastMessage,
      OrderSubject.name,
      OrderSubject.createdAt,
    ],
    this.filterType,
  });

  ChatFilterState copyWith({
    bool? groupByType,
    bool? showArchived,
    List<OrderSubject>? orderBy,
    ChatType? filterType,
  }) {
    return ChatFilterState(
      groupByType: groupByType ?? this.groupByType,
      showArchived: showArchived ?? this.showArchived,
      orderBy: orderBy ?? this.orderBy,
      filterType: filterType ?? this.filterType,
    );
  }
}
