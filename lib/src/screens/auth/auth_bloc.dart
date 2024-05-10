import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_chat/src/services/auth_service.dart';
part 'auth_event.dart';
part 'auth_state.dart';

final class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthUninitializedState()) {
    on<AuthStartedEvent>(_onStarted);
    on<AuthLoggedInEvent>(_onLoggedIn);
    on<AuthLoggedOutEvent>(_onLoggedOut);
  }

  void _onStarted(AuthEvent event, Emitter<AuthState> emit) {
    emit(AuthService.isLoggedIn() ?
      AuthAuthenticatedState() :
      AuthUnauthenticatedState());
  }

  void _onLoggedIn(AuthEvent event, Emitter<AuthState> emit) {
    emit(AuthAuthenticatedState());
  }

  void _onLoggedOut(AuthEvent event, Emitter<AuthState> emit) async {
    emit(AuthUnauthenticatedState());
    await AuthService.logout();
  }
}