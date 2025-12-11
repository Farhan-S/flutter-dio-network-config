import 'package:equatable/equatable.dart';

import '../../domain/entities/app_locale.dart';

/// Base class for localization states
abstract class LocalizationState extends Equatable {
  const LocalizationState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class LocalizationInitial extends LocalizationState {
  const LocalizationInitial();
}

/// Loading saved locale
class LocalizationLoading extends LocalizationState {
  const LocalizationLoading();
}

/// Locale loaded successfully
class LocalizationLoaded extends LocalizationState {
  final AppLocale locale;
  final bool isSystemLocale;

  const LocalizationLoaded({required this.locale, this.isSystemLocale = false});

  @override
  List<Object?> get props => [locale, isSystemLocale];
}

/// Error loading/changing locale
class LocalizationError extends LocalizationState {
  final String message;

  const LocalizationError(this.message);

  @override
  List<Object?> get props => [message];
}
