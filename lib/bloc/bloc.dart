// lib/bloc/nota_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'eventos.dart';
import 'estado.dart';
import '../data/estrucutura_datos.dart';
import '../data/nota_repo.dart';

class NotaBloc extends Bloc<NotaEvento, NotaEstado> {
  final NotaRepo repob;
  // Inicialización con el estado de carga
  NotaBloc({required this.repob}) : super(LoadingEstado()) {
    on<LoadNotas>(_onLoadNotas);
    on<AddNotaEvento>(_onAddNota);
    on<ActualizarTarea>(_ActualizarTarea);
    on<DeleteNotasEvento>(_onDeleteNota);
  }

  void _onAddNota(AddNotaEvento event, Emitter<NotaEstado> emit) async {
    try {
      // ⭐️ Guardar en Supabase
      await repob.addNota(event.note); 
      
      // ⭐️ Recargar la lista para obtener el estado actual con el nuevo ID
      add(LoadNotas()); 
    } catch (e) {
      // Manejar error
      // Si falla la adición, re-emitir el estado anterior o uno de error.
      if (state is LoadedEvento) {
        emit(LoadedEvento((state as LoadedEvento).notas));
      } else {
        emit(ErorNota('Fallo al agregar la nota.'));
      }
    }
  }

  void _ActualizarTarea(ActualizarTarea event, Emitter<NotaEstado> emit) async{
    try{
      await repob.updateTarea(event.tarea);
      add(LoadNotas());
    } catch (e){
      if(state is LoadedEvento){
        emit(LoadedEvento((state as LoadedEvento).notas));
      }else{
        emit(ErorNota('Fallo al actualizat la tarea'));
      }
    }
  }

  void _onDeleteNota(DeleteNotasEvento event, Emitter<NotaEstado> emit) async{
    try{
      await repob.deleteNota(event.nota.id);
      add(LoadNotas());
    } catch (e){
      if (state is LoadedEvento){
         emit(LoadedEvento((state as LoadedEvento).notas));
      }else{
        emit(ErorNota('Fallo al elimianr nota.'));
      }
    }
    }



  void _onLoadNotas(LoadNotas event, Emitter<NotaEstado> emit) async {
  try{
       final List<Nota> notas = await repob.fetchNotas();
       emit(LoadedEvento(notas));
    } catch (e){
       emit(ErorNota('Fallo al cargar nota: $e'));
    }
  }
}
