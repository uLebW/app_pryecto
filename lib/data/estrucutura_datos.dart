
// Clase para definir una Tarea (para el progreso por actividad)
import 'dart:convert';

class Tarea {
  final int? id; // ID de la DB
  final String nombre;
  final bool completada;
  final int? notaId; // CLAVE FORÁNEA

  const Tarea({
    this.id,
    required this.nombre,
    this.completada = false, 
    this.notaId, // Puede ser nulo o incluido al crear
  });

  Map<String, dynamic> toJson() {
    return {
      // id, nota_id se incluyen solo si se necesitan para la actualización
      if (id != null) 'id': id, 
      'nombre': nombre,
      'completada': completada,
      if (notaId != null) 'nota_id': notaId, 
    };
  }

  factory Tarea.fromJson(Map<String, dynamic> json) {
    return Tarea(
      id: json['id'] as int?,
      nombre: json['nombre'] as String,
      completada: json['completada'] as bool? ?? false, 
      notaId: json['nota_id'] as int?,
    );
  }
}

// Clase para definir la estructura de una Nota
class Nota {
  final int? id;
  final String nombre;
  final String tipo;
  final String descripcion;
  final DateTime fechaLimite;
  final List<Tarea> tareas;
  double get porcentajeProgreso {
    if (tareas.isEmpty) return 0.0;
    int completadas = tareas.where((t) => t.completada).length;
    return completadas / tareas.length;
  }


  Nota({
    this.id,
    required this.nombre,
    required this.tipo,
    required this.descripcion,
    required this.fechaLimite,
    this.tareas = const [],
    
  });

 factory Nota.fromJson(Map<String, dynamic> json) {
    // regresa una lista de mapas bajo la clave 'tareas'
    final List<dynamic> tareasData = json['tareas'] as List<dynamic>? ?? [];

    final List<Tarea> tareasList = 
        tareasData.map((tareaJson) => Tarea.fromJson(tareaJson)).toList();

    return Nota(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      tipo: json['tipo'] as String,
      descripcion: json['descripcion'] as String,
      fechaLimite: DateTime.parse(json['fechaLimite'] as String), 
      tareas: tareasList,
    );
  }
  
  //  METODO TO JSON (SOLO NOTA) 
  // sin tareas ya que se guardan por separado
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id, 
      'nombre': nombre,
      'tipo': tipo,
      'descripcion': descripcion,
      'fechaLimite': fechaLimite.toIso8601String(),
    };
  }
}

List<Nota> listaDeNotas = [];

