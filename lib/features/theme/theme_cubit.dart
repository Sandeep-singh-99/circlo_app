import 'package:circlo_app/core/storage/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final SecureStorageService _storageService;

  ThemeCubit(this._storageService) : super(ThemeMode.dark) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final savedTheme = await _storageService.getTheme();
    if (savedTheme == 'light') {
      emit(ThemeMode.light);
    } else {
      emit(ThemeMode.dark);
    }
  }

  Future<void> toggleTheme() async {
    if (state == ThemeMode.dark) {
      emit(ThemeMode.light);
      await _storageService.saveTheme('light');
    } else {
      emit(ThemeMode.dark);
      await _storageService.saveTheme('dark');
    }
  }
}
