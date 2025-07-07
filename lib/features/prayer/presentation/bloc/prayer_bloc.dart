import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/models/prayer_time.dart';
import '../../../../core/repositories/prayer_repository.dart';
import '../../../../core/di/dependency_injection.dart';

// Events
abstract class PrayerEvent extends Equatable {
  const PrayerEvent();

  @override
  List<Object> get props => [];
}

class LoadPrayerTimes extends PrayerEvent {
  final DateTime? date;

  const LoadPrayerTimes({this.date});

  @override
  List<Object> get props => [date ?? DateTime.now()];
}

class RefreshPrayerTimes extends PrayerEvent {}

class UpdatePrayerConfiguration extends PrayerEvent {
  final PrayerConfiguration configuration;

  const UpdatePrayerConfiguration(this.configuration);

  @override
  List<Object> get props => [configuration];
}

// States
abstract class PrayerState extends Equatable {
  const PrayerState();

  @override
  List<Object> get props => [];
}

class PrayerInitial extends PrayerState {}

class PrayerLoading extends PrayerState {}

class PrayerLoaded extends PrayerState {
  final List<PrayerTime> prayerTimes;
  final PrayerTime? nextPrayer;
  final PrayerConfiguration? configuration;

  const PrayerLoaded({
    required this.prayerTimes,
    this.nextPrayer,
    this.configuration,
  });

  @override
  List<Object> get props => [
        prayerTimes,
        nextPrayer ?? '',
        configuration ?? '',
      ];
}

class PrayerError extends PrayerState {
  final String message;

  const PrayerError({required this.message});

  @override
  List<Object> get props => [message];
}

// Bloc
class PrayerBloc extends Bloc<PrayerEvent, PrayerState> {
  final PrayerRepository _prayerRepository = getIt<PrayerRepository>();

  PrayerBloc() : super(PrayerInitial()) {
    on<LoadPrayerTimes>(_onLoadPrayerTimes);
    on<RefreshPrayerTimes>(_onRefreshPrayerTimes);
    on<UpdatePrayerConfiguration>(_onUpdatePrayerConfiguration);
  }

  Future<void> _onLoadPrayerTimes(
    LoadPrayerTimes event,
    Emitter<PrayerState> emit,
  ) async {
    emit(PrayerLoading());

    try {
      final date = event.date ?? DateTime.now();

      // Charger les données en parallèle
      final results = await Future.wait([
        _prayerRepository.getPrayerTimesForDate(date),
        _prayerRepository.getNextPrayer(),
        _prayerRepository.getConfiguration(),
      ]);

      final prayerTimes = results[0] as List<PrayerTime>;
      final nextPrayer = results[1] as PrayerTime?;
      final configuration = results[2] as PrayerConfiguration?;

      emit(PrayerLoaded(
        prayerTimes: prayerTimes,
        nextPrayer: nextPrayer,
        configuration: configuration,
      ));
    } catch (e) {
      emit(PrayerError(message: e.toString()));
    }
  }

  Future<void> _onRefreshPrayerTimes(
    RefreshPrayerTimes event,
    Emitter<PrayerState> emit,
  ) async {
    // Garder l'état actuel pendant le refresh
    final currentState = state;

    try {
      final date = DateTime.now();

      final results = await Future.wait([
        _prayerRepository.getPrayerTimesForDate(date),
        _prayerRepository.getNextPrayer(),
        _prayerRepository.getConfiguration(),
      ]);

      final prayerTimes = results[0] as List<PrayerTime>;
      final nextPrayer = results[1] as PrayerTime?;
      final configuration = results[2] as PrayerConfiguration?;

      emit(PrayerLoaded(
        prayerTimes: prayerTimes,
        nextPrayer: nextPrayer,
        configuration: configuration,
      ));
    } catch (e) {
      // En cas d'erreur, remettre l'état précédent si possible
      if (currentState is PrayerLoaded) {
        emit(currentState);
      } else {
        emit(PrayerError(message: e.toString()));
      }
    }
  }

  Future<void> _onUpdatePrayerConfiguration(
    UpdatePrayerConfiguration event,
    Emitter<PrayerState> emit,
  ) async {
    try {
      await _prayerRepository.updateConfiguration(event.configuration);

      // Recharger les données après mise à jour
      add(const LoadPrayerTimes());
    } catch (e) {
      emit(PrayerError(message: e.toString()));
    }
  }

  /// Stream pour écouter les changements en temps réel
  Stream<List<PrayerTime>> watchPrayerTimes({DateTime? date}) {
    return _prayerRepository.watchPrayerTimesForDate(date ?? DateTime.now());
  }

  /// Obtenir la prochaine prière
  Future<PrayerTime?> getNextPrayer() async {
    return await _prayerRepository.getNextPrayer();
  }

  /// Ajuster l'heure d'une prière
  Future<void> adjustPrayerTime(String prayerId, int adjustmentMinutes) async {
    try {
      await _prayerRepository.adjustPrayerTime(prayerId, adjustmentMinutes);
      add(RefreshPrayerTimes());
    } catch (e) {
      emit(PrayerError(message: e.toString()));
    }
  }
}
