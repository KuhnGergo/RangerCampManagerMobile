import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/providers/actions/camp_actions_provider.dart';
import 'package:mastercs_mobile/utils/validators.dart';

final createCampControllerProvider =
    NotifierProvider<CreateCampController, CreateCampState>(() {
      return CreateCampController();
    });

class CreateCampController extends Notifier<CreateCampState> {
  late final _campActionsProvider = ref.read(campActionsProvider.notifier);

  static const int campNameMaxLength = 50;
  static const int campNameMinLength = 3;
  static const int joinCodeMaxLength = 12;
  static const int minGroupSizeMin = 0;
  static const int minGroupSizeMax = 5;

  @override
  CreateCampState build() {
    return CreateCampState(
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 7)),
    );
  }

  void updateName(String name) {
    state = state.copyWith(name: name, nameError: null, error: null);
  }

  void updateJoinCode(String joinCode) {
    state = state.copyWith(
      joinCode: joinCode,
      joinCodeError: null,
      error: null,
    );
  }

  void updateMinGroupSize(int? size) {
    state = state.copyWith(
      minGroupSize: size,
      minGroupSizeError: null,
      error: null,
    );
  }

  void updateStartDate(DateTime date) {
    state = state.copyWith(startDate: date, startDateError: null, error: null);
    // Ensure end date is after start date
    if (state.endDate.isBefore(date) || state.endDate.isAtSameMomentAs(date)) {
      state = state.copyWith(
        endDate: date.add(const Duration(days: 1)),
        endDateError: null,
      );
    }
  }

  void updateEndDate(DateTime date) {
    state = state.copyWith(endDate: date, endDateError: null, error: null);
  }

  bool validate() {
    final trimmedName = state.name.trim();
    final trimmedJoinCode = state.joinCode.trim();

    final nameError = trimmedName.isEmpty
        ? 'Camp name is required'
        : trimmedName.length < campNameMinLength
        ? 'Camp name must be at least $campNameMinLength characters'
        : trimmedName.length > campNameMaxLength
        ? 'Camp name must be $campNameMaxLength characters or less'
        : null;

    final joinCodeError = trimmedJoinCode.isNotEmpty
        ? Validators.joinCode(trimmedJoinCode)
        : null;

    final minGroupSizeError =
        state.minGroupSize != null &&
            (state.minGroupSize! < minGroupSizeMin ||
                state.minGroupSize! > minGroupSizeMax)
        ? 'Min group size must be between $minGroupSizeMin and $minGroupSizeMax'
        : null;

    final startDateError = state.startDate.isAfter(state.endDate)
        ? 'Start date must be before end date'
        : null;
    final endDateError =
        state.endDate.isBefore(state.startDate) ||
            state.endDate.isAtSameMomentAs(state.startDate)
        ? 'End date must be after start date'
        : null;

    state = state.copyWith(
      nameError: nameError,
      joinCodeError: joinCodeError,
      minGroupSizeError: minGroupSizeError,
      startDateError: startDateError,
      endDateError: endDateError,
    );

    return nameError == null &&
        joinCodeError == null &&
        minGroupSizeError == null &&
        startDateError == null &&
        endDateError == null;
  }

  Future<void> createCamp() async {
    if (state.isCreating || !validate()) return;

    state = state.copyWith(isCreating: true, error: null);

    try {
      await _campActionsProvider.createNewCamp(
        name: state.name.trim(),
        startDate: state.startDate,
        endDate: state.endDate,
        minGroupSize: state.minGroupSize,
        joinCode: state.joinCode.trim().isEmpty ? null : state.joinCode.trim(),
      );
      state = CreateCampState(
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        minGroupSize: null,
        success: true,
      );
    } catch (e, stack) {
      state = state.copyWith(
        isCreating: false,
        error: e.toString(),
        success: false,
        stackTrace: stack,
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearSuccess() {
    state = state.copyWith(success: false, error: null);
  }

  void reset() {
    state = CreateCampState(
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 7)),
    );
  }
}

class CreateCampState {
  final String name;
  final String joinCode;
  final DateTime startDate;
  final DateTime endDate;
  final int? minGroupSize;
  final bool isCreating;
  final bool success;
  final String? nameError;
  final String? joinCodeError;
  final String? minGroupSizeError;
  final String? startDateError;
  final String? endDateError;
  final String? error;
  final StackTrace? stackTrace;

  const CreateCampState({
    this.name = '',
    this.joinCode = '',
    required this.startDate,
    required this.endDate,
    this.minGroupSize,
    this.isCreating = false,
    this.success = false,
    this.nameError,
    this.joinCodeError,
    this.minGroupSizeError,
    this.startDateError,
    this.endDateError,
    this.error,
    this.stackTrace,
  });

  static const _unset = Object();

  CreateCampState copyWith({
    String? name,
    String? joinCode,
    DateTime? startDate,
    DateTime? endDate,
    Object? minGroupSize = _unset,
    bool? isCreating,
    bool? success,
    Object? nameError = _unset,
    Object? joinCodeError = _unset,
    Object? minGroupSizeError = _unset,
    Object? startDateError = _unset,
    Object? endDateError = _unset,
    Object? error = _unset,
    Object? stackTrace = _unset,
  }) {
    return CreateCampState(
      name: name ?? this.name,
      joinCode: joinCode ?? this.joinCode,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      minGroupSize: identical(minGroupSize, _unset)
          ? this.minGroupSize
          : minGroupSize as int?,
      isCreating: isCreating ?? this.isCreating,
      success: success ?? this.success,
      nameError: identical(nameError, _unset)
          ? this.nameError
          : nameError as String?,
      joinCodeError: identical(joinCodeError, _unset)
          ? this.joinCodeError
          : joinCodeError as String?,
      minGroupSizeError: identical(minGroupSizeError, _unset)
          ? this.minGroupSizeError
          : minGroupSizeError as String?,
      startDateError: identical(startDateError, _unset)
          ? this.startDateError
          : startDateError as String?,
      endDateError: identical(endDateError, _unset)
          ? this.endDateError
          : endDateError as String?,
      error: identical(error, _unset) ? this.error : error as String?,
      stackTrace: identical(stackTrace, _unset)
          ? this.stackTrace
          : stackTrace as StackTrace?,
    );
  }
}
