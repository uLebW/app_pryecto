import '../data/estrucutura_datos.dart';

abstract class NotaEvento{}

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