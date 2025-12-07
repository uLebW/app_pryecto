import 'package:flutter_bloc/flutter_bloc.dart';
import 'eventos.dart';
import 'estado.dart';
import '../data/estrucutura_datos.dart'; // Tu repo está aquí o en conexiones.dart?
import '../data/nota_repo.dart'; // Importa NotaRepo

class AuthBloc extends Bloc<AuthEvento, AuthEstado> {
  final NotaRepo repo;

  AuthBloc({required this.repo}) : super(AuthIni()) {
    on<LoginEvento>(_onLogin);
    on<RegistroEvento>(_onRegistro);
    on<LougOutEvento>(_onLogout);
  }

  void _onLogin(LoginEvento event, Emitter<AuthEstado> emit) async {
    emit(AuthCarg());
    try {
      await repo.login(event.email, event.password);
      emit(AuthExito());
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception:', '')));
    }
  }

  void _onRegistro(RegistroEvento event, Emitter<AuthEstado> emit) async {
    emit(AuthCarg());
    try {
      await repo.registro(event.email, event.password, event.user);
      emit(AuthExito());
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception:', '')));
    }
  }

  void _onLogout(LougOutEvento event, Emitter<AuthEstado> emit) {
    repo.logiut();
    emit(AuthIni());
  }
}