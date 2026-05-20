import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/models/member.dart';
import 'package:mastercs_mobile/models/roles.dart';
import 'package:mastercs_mobile/providers/data/camp_members_list_provider.dart';
import 'package:mastercs_mobile/providers/data/chats_list_provider.dart';
import 'package:mastercs_mobile/presentation/components/member_search/member_search_utils.dart';
import 'package:mastercs_mobile/presentation/components/user_profile/providers/user_profile_provider.dart';

/// Provider for the member search controller
final memberSearchControllerProvider =
    NotifierProvider<MemberSearchController, MemberSearchState>(() {
      return MemberSearchController();
    });

/// Controller that manages the member search state and filtering logic
class MemberSearchController extends Notifier<MemberSearchState> {
  String _searchQuery = '';

  @override
  MemberSearchState build() {
    // Watch the members list and chats list for filtering
    final membersAsync = ref.watch(campMembersListProvider);
    final chatsAsync = ref.watch(chatsListProvider);
    final myRole = ref.watch(myRoleProvider);

    // Combine both async values
    return membersAsync.when(
      data: (members) {
        return chatsAsync.when(
          data: (chats) {
            // Filter out pending members if user is not an owner
            final roleFilteredMembers = _filterByRole(members, myRole);

            // Apply search query filter
            final filteredMembers = MemberSearchUtils.filterMembers(
              roleFilteredMembers,
              _searchQuery,
              chats,
            );
            return MemberSearchState(
              searchQuery: _searchQuery,
              allMembers: roleFilteredMembers,
              allChats: chats,
              filteredMembers: filteredMembers,
              isLoading: false,
            );
          },
          loading: () => MemberSearchState(
            searchQuery: _searchQuery,
            allMembers: [],
            allChats: [],
            filteredMembers: [],
            isLoading: true,
          ),
          error: (error, _) => MemberSearchState(
            searchQuery: _searchQuery,
            allMembers: [],
            allChats: [],
            filteredMembers: [],
            isLoading: false,
            error: error.toString(),
          ),
        );
      },
      loading: () => MemberSearchState(
        searchQuery: _searchQuery,
        allMembers: [],
        allChats: [],
        filteredMembers: [],
        isLoading: true,
      ),
      error: (error, _) => MemberSearchState(
        searchQuery: _searchQuery,
        allMembers: [],
        allChats: [],
        filteredMembers: [],
        isLoading: false,
        error: error.toString(),
      ),
    );
  }

  /// Filter out pending members if user is not an owner
  List<Member> _filterByRole(List<Member> members, Role? myRole) {
    // Only owners can see pending members
    if (myRole == Role.owner) {
      return members;
    }

    // Staff and campers: exclude pending members
    return members
        .where((member) => member.role != Role.pending.toString())
        .toList();
  }

  /// Update the search query and trigger filtering
  void updateSearchQuery(String query) {
    _searchQuery = query.trim();
    final filteredMembers = MemberSearchUtils.filterMembers(
      state.allMembers,
      _searchQuery,
      state.allChats,
    );

    state = state.copyWith(
      searchQuery: _searchQuery,
      filteredMembers: filteredMembers,
    );
  }

  /// Clear the search query
  void clearSearch() {
    _searchQuery = '';
    state = state.copyWith(searchQuery: '', filteredMembers: state.allMembers);
  }
}

/// State class for member search
class MemberSearchState {
  final String searchQuery;
  final List<Member> allMembers;
  final List<Chat> allChats;
  final List<Member> filteredMembers;
  final bool isLoading;
  final String? error;

  const MemberSearchState({
    this.searchQuery = '',
    this.allMembers = const [],
    this.allChats = const [],
    this.filteredMembers = const [],
    this.isLoading = false,
    this.error,
  });

  MemberSearchState copyWith({
    String? searchQuery,
    List<Member>? allMembers,
    List<Chat>? allChats,
    List<Member>? filteredMembers,
    bool? isLoading,
    String? error,
  }) {
    return MemberSearchState(
      searchQuery: searchQuery ?? this.searchQuery,
      allMembers: allMembers ?? this.allMembers,
      allChats: allChats ?? this.allChats,
      filteredMembers: filteredMembers ?? this.filteredMembers,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
