import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsState {
  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final bool appointmentReminders;
  final bool soundEnabled;
  final bool biometricEnabled;
  final String userName;
  final String userEmail;
  final String userPhone;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.notificationsEnabled = true,
    this.appointmentReminders = true,
    this.soundEnabled = true,
    this.biometricEnabled = false,
    this.userName = 'Usuario',
    this.userEmail = 'usuario@email.com',
    this.userPhone = '+54 9 11 4567-8901',
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    bool? appointmentReminders,
    bool? soundEnabled,
    bool? biometricEnabled,
    String? userName,
    String? userEmail,
    String? userPhone,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      appointmentReminders: appointmentReminders ?? this.appointmentReminders,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    return const SettingsState();
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  void toggleNotifications(bool value) {
    state = state.copyWith(
      notificationsEnabled: value,
      // Si se desactivan las notificaciones, desactivar también recordatorios secundarios
      appointmentReminders: value ? state.appointmentReminders : false,
      soundEnabled: value ? state.soundEnabled : false,
    );
  }

  void toggleAppointmentReminders(bool value) {
    state = state.copyWith(appointmentReminders: value);
  }

  void toggleSound(bool value) {
    state = state.copyWith(soundEnabled: value);
  }

  void toggleBiometric(bool value) {
    state = state.copyWith(biometricEnabled: value);
  }

  void updateProfile({String? name, String? email, String? phone}) {
    state = state.copyWith(
      userName: name,
      userEmail: email,
      userPhone: phone,
    );
  }

  void resetSettings() {
    state = const SettingsState();
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(() {
  return SettingsNotifier();
});
