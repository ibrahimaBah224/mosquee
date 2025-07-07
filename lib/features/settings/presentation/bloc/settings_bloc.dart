import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class LoadSettings extends SettingsEvent {}

class ToggleTheme extends SettingsEvent {}

class ChangeLanguage extends SettingsEvent {
  final String language;

  const ChangeLanguage({required this.language});

  @override
  List<Object> get props => [language];
}

class ToggleNotifications extends SettingsEvent {}

class TogglePrayerReminders extends SettingsEvent {}

// States
class SettingsState extends Equatable {
  final bool isDarkMode;
  final String language;
  final bool notificationsEnabled;
  final bool prayerRemindersEnabled;
  final bool isLoading;

  const SettingsState({
    this.isDarkMode = false,
    this.language = 'fr',
    this.notificationsEnabled = true,
    this.prayerRemindersEnabled = true,
    this.isLoading = false,
  });

  SettingsState copyWith({
    bool? isDarkMode,
    String? language,
    bool? notificationsEnabled,
    bool? prayerRemindersEnabled,
    bool? isLoading,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      prayerRemindersEnabled:
          prayerRemindersEnabled ?? this.prayerRemindersEnabled,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object> get props => [
    isDarkMode,
    language,
    notificationsEnabled,
    prayerRemindersEnabled,
    isLoading,
  ];
}

// Bloc
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<ToggleTheme>(_onToggleTheme);
    on<ChangeLanguage>(_onChangeLanguage);
    on<ToggleNotifications>(_onToggleNotifications);
    on<TogglePrayerReminders>(_onTogglePrayerReminders);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Load settings from SharedPreferences
      await Future.delayed(const Duration(milliseconds: 500));

      emit(
        state.copyWith(
          isLoading: false,
          isDarkMode: false,
          language: 'fr',
          notificationsEnabled: true,
          prayerRemindersEnabled: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onToggleTheme(
    ToggleTheme event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isDarkMode: !state.isDarkMode));
    // Save to SharedPreferences
  }

  Future<void> _onChangeLanguage(
    ChangeLanguage event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(language: event.language));
    // Save to SharedPreferences
  }

  Future<void> _onToggleNotifications(
    ToggleNotifications event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(notificationsEnabled: !state.notificationsEnabled));
    // Save to SharedPreferences
  }

  Future<void> _onTogglePrayerReminders(
    TogglePrayerReminders event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(prayerRemindersEnabled: !state.prayerRemindersEnabled));
    // Save to SharedPreferences
  }
}
