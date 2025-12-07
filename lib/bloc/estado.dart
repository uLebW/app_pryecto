import '../data/estrucutura_datos.dart';

abstract class AuthEstado {}
abstract class NotaEstado{}
//Estado inical y cuando esta cargando datos
class LoadingEstado extends NotaEstado{}
//Esatdo cuando la lista de notas  esta lista
class LoadedEvento extends NotaEstado{
  final List<Nota> notas;
  LoadedEvento(this.notas);
}

class ErorNota extends NotaEstado{
  final String mensaje;
  ErorNota(this.mensaje);
}

//ESTADOS login
class AuthIni  extends AuthEstado{}
class AuthCarg extends AuthEstado{}
class AuthExito extends AuthEstado{}
class AuthError extends AuthEstado{
  final String mensaje;
  AuthError(this.mensaje);
}