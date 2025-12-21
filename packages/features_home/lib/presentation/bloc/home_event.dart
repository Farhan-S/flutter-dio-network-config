import 'package:equatable/equatable.dart';

/// Events for HomeBloc
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load home data
class LoadHomeDataEvent extends HomeEvent {
  const LoadHomeDataEvent();
}

/// Event to refresh home data
class RefreshHomeDataEvent extends HomeEvent {
  const RefreshHomeDataEvent();
}

/// Event to change navigation index
class NavigationIndexChanged extends HomeEvent {
  final int index;

  const NavigationIndexChanged(this.index);

  @override
  List<Object?> get props => [index];
}
