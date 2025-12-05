import 'package:flutter_test/flutter_test.dart';
import 'package:app_pryecto/data/estrucutura_datos.dart';

void main(){
  group('Pruebas de modelo', (){
    test('Verificacion para una nota valida a partir de un JSON', (){
      final jsonSimulado = {
        'id': 1,
        'nombre': 'Prueba de Nota',
        'tipo': 'Personal',
        'descripcion': 'Probando unit test',
        'fechaLimite': '2025-12-31T12:00:00Z',
        // Simulamos que Supabase nos devuelve las tareas anidadas
        'tareas': [
          {'nombre': 'Tarea 1', 'completada': false},
          {'nombre': 'Tarea 2', 'completada': true}
        ]
      };

      // Llamamos al método que queremos probar
      final nota = Nota.fromJson(jsonSimulado);

      //  Comprobamos que el resultado sea el esperado
      expect(nota.nombre, 'Prueba de Nota'); 
      expect(nota.tareas.length, 2);        
      expect(nota.tareas[1].completada, true); 
    });
    

    test('Probar calculo de avance', (){
      final tareasPrueba = [
        Tarea(nombre: 'A', completada: true),  
        Tarea(nombre: 'B', completada: true),  
        Tarea(nombre: 'C', completada: false), 
        Tarea(nombre: 'D', completada: false), 
      ];
      
      // Creamos una nota con esas tareas (los demás datos no importan para esta prueba)
      final nota = Nota(
        nombre: 'X', 
        tipo: 'X', 
        descripcion: 'X', 
        fechaLimite: DateTime.now(), 
        tareas: tareasPrueba
      );

      // 2. EJECUCIÓN
      final progreso = nota.porcentajeProgreso;

      // 3. VERIFICACIÓN
      // 2 completadas de 4 totales = 0.5 (50%)
      expect(progreso, 0.5);
    });
  });
}