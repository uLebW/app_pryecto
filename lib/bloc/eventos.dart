import '../data/estrucutura_datos.dart';

abstract class NotaEvento{}
abstract class AuthEvento{}

class AddNotaEvento extends NotaEvento{
  final Nota note;
  AddNotaEvento(this.note);
}

class LoadNotas extends NotaEvento{}

class ActualizarTarea extends NotaEvento{
  final Nota nota;
  final Tarea tarea;
  ActualizarTarea(this.nota, this.tarea);
}

class DeleteNotasEvento extends NotaEvento{
  final Nota nota;
  DeleteNotasEvento(this.nota);
}

//Eventos de login
class LoginEvento extends AuthEvento{
  final String email;
  final String password;
  LoginEvento(this.email, this.password);
}

class RegistroEvento extends AuthEvento{
  final String email;
  final String password;
  final String user;
  RegistroEvento(this.email, this.password, this.user);
}

class LougOutEvento extends AuthEvento{}