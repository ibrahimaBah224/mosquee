import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/models/mosque_info.dart';
import '../../../../core/services/mosque_service.dart';

// Events
abstract class MosqueInfoEvent extends Equatable {
  const MosqueInfoEvent();

  @override
  List<Object> get props => [];
}

class MosqueInfoLoadRequested extends MosqueInfoEvent {
  const MosqueInfoLoadRequested();
}

class MosqueInfoUpdateRequested extends MosqueInfoEvent {
  final MosqueInfo mosqueInfo;

  const MosqueInfoUpdateRequested(this.mosqueInfo);

  @override
  List<Object> get props => [mosqueInfo];
}

class MosqueInfoRefreshRequested extends MosqueInfoEvent {
  const MosqueInfoRefreshRequested();
}

// States
abstract class MosqueInfoState extends Equatable {
  const MosqueInfoState();

  @override
  List<Object?> get props => [];
}

class MosqueInfoInitial extends MosqueInfoState {
  const MosqueInfoInitial();
}

class MosqueInfoLoading extends MosqueInfoState {
  const MosqueInfoLoading();
}

class MosqueInfoLoaded extends MosqueInfoState {
  final MosqueInfo mosqueInfo;

  const MosqueInfoLoaded(this.mosqueInfo);

  @override
  List<Object> get props => [mosqueInfo];
}

class MosqueInfoError extends MosqueInfoState {
  final String message;

  const MosqueInfoError(this.message);

  @override
  List<Object> get props => [message];
}

class MosqueInfoUpdating extends MosqueInfoState {
  final MosqueInfo mosqueInfo;

  const MosqueInfoUpdating(this.mosqueInfo);

  @override
  List<Object> get props => [mosqueInfo];
}

// BLoC
class MosqueInfoBloc extends Bloc<MosqueInfoEvent, MosqueInfoState> {
  final MosqueService _mosqueService;

  MosqueInfoBloc({MosqueService? mosqueService})
      : _mosqueService = mosqueService ?? MosqueService(),
        super(const MosqueInfoInitial()) {
    on<MosqueInfoLoadRequested>(_onLoadRequested);
    on<MosqueInfoUpdateRequested>(_onUpdateRequested);
    on<MosqueInfoRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadRequested(
    MosqueInfoLoadRequested event,
    Emitter<MosqueInfoState> emit,
  ) async {
    emit(const MosqueInfoLoading());

    try {
      final mosqueInfo = await _mosqueService.getMosqueInfo();
      if (mosqueInfo != null) {
        emit(MosqueInfoLoaded(mosqueInfo));
      } else {
        emit(const MosqueInfoError('Aucune information de mosquée trouvée'));
      }
    } catch (e) {
      emit(MosqueInfoError('Erreur lors du chargement: $e'));
    }
  }

  Future<void> _onUpdateRequested(
    MosqueInfoUpdateRequested event,
    Emitter<MosqueInfoState> emit,
  ) async {
    final currentState = state;
    if (currentState is MosqueInfoLoaded) {
      emit(MosqueInfoUpdating(currentState.mosqueInfo));
    }

    try {
      await _mosqueService.updateMosqueInfo(event.mosqueInfo);
      emit(MosqueInfoLoaded(event.mosqueInfo));
    } catch (e) {
      // Retourner à l'état précédent en cas d'erreur
      if (currentState is MosqueInfoLoaded) {
        emit(currentState);
      }
      emit(MosqueInfoError('Erreur lors de la mise à jour: $e'));
    }
  }

  Future<void> _onRefreshRequested(
    MosqueInfoRefreshRequested event,
    Emitter<MosqueInfoState> emit,
  ) async {
    try {
      _mosqueService.clearCache();
      final mosqueInfo = await _mosqueService.getMosqueInfo();
      if (mosqueInfo != null) {
        emit(MosqueInfoLoaded(mosqueInfo));
      } else {
        emit(const MosqueInfoError('Aucune information de mosquée trouvée'));
      }
    } catch (e) {
      emit(MosqueInfoError('Erreur lors du rafraîchissement: $e'));
    }
  }

  /// Stream pour écouter les changements en temps réel
  Stream<MosqueInfo?> watchMosqueInfo() {
    return _mosqueService.watchMosqueInfo();
  }
}
