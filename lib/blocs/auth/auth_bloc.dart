import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AuthCheckRequested>((event, emit) {
      final user = authRepository.currentUser;
      if (user != null) {
        print('[AuthBloc] AuthCheckRequested: user exists -> ${user.email}');
        emit(Authenticated(user));
      } else {
        print('[AuthBloc] AuthCheckRequested: no user');
        emit(Unauthenticated());
      }
    });

    on<SignInRequested>((event, emit) async {
      print('[AuthBloc] SignInRequested: received for email -> ${event.email}');
      emit(AuthLoading());
      try {
        final user = await authRepository.signIn(email: event.email, password: event.password);
        if (user != null) {
          print('[AuthBloc] SignInRequested: signIn success -> ${user.email}');
          emit(Authenticated(user));
        } else {
          print('[AuthBloc] SignInRequested: signIn returned null user');
          emit(AuthFailure('Unknown error'));
        }
      } catch (e) {
        print('[AuthBloc] SignInRequested: exception -> $e');
        emit(AuthFailure(e.toString()));
      }
    });

    // NEW: SignUp handler
    on<SignUpRequested>((event, emit) async {
      print('[AuthBloc] SignUpRequested: received for email -> ${event.email}');
      emit(AuthLoading());
      try {
        final user = await authRepository.signUp(email: event.email, password: event.password);
        if (user != null) {
          print('[AuthBloc] SignUpRequested: signUp success -> ${user.email}');
          emit(Authenticated(user));
        } else {
          print('[AuthBloc] SignUpRequested: signUp returned null user');
          emit(AuthFailure('Unknown error'));
        }
      } catch (e) {
        print('[AuthBloc] SignUpRequested: exception -> $e');
        emit(AuthFailure(e.toString()));
      }
    });

    on<SignOutRequested>((event, emit) async {
      print('[AuthBloc] SignOutRequested: signing out');
      await authRepository.signOut();
      emit(Unauthenticated());
    });
  }

  @override
  void onTransition(Transition<AuthEvent, AuthState> transition) {
    super.onTransition(transition);
    print('[AuthBloc] transition -> $transition');
  }
}
