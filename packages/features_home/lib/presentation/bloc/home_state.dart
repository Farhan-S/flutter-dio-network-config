import 'package:equatable/equatable.dart';

/// States for HomeBloc
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class HomeInitial extends HomeState {
  const HomeInitial();
}

/// Loading state
class HomeLoading extends HomeState {
  const HomeLoading();
}

/// Loaded state with data
class HomeLoaded extends HomeState {
  final int lastUpdatedTimestamp;
  final int selectedIndex;

  const HomeLoaded({
    required this.lastUpdatedTimestamp,
    this.selectedIndex = 0,
  });

  HomeLoaded copyWith({int? lastUpdatedTimestamp, int? selectedIndex}) {
    return HomeLoaded(
      lastUpdatedTimestamp: lastUpdatedTimestamp ?? this.lastUpdatedTimestamp,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }

  @override
  List<Object?> get props => [lastUpdatedTimestamp, selectedIndex];
}

/// Error state
class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
