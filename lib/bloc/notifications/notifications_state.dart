import 'package:equatable/equatable.dart';

class NotificationsState extends Equatable {
  final bool isLoading;
  final String? errorMessage;

  const NotificationsState({this.isLoading = false, this.errorMessage});

  NotificationsState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, errorMessage];
}
