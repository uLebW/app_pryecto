// lib/screens/details/nota_detalle_screen.dart
import 'package:app_pryecto/bloc/bloc.dart';
import 'package:app_pryecto/bloc/estado.dart';
import 'package:app_pryecto/bloc/eventos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/estrucutura_datos.dart';

class NotaDetalleScreen extends StatelessWidget {
 final Nota notaInicla;


  const NotaDetalleScreen({
    Key? key,
    required this.notaInicla,
  }) : super(key: key);

  void _toggleTare(BuildContext context, Nota currentNOta, Tarea tarea){
    context.read<NotaBloc>().add(ActualizarTarea(currentNOta, Tarea(
      id: tarea.id,
      nombre: tarea.nombre,
      completada: tarea.completada,
      notaId: tarea.notaId
    )));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotaBloc, NotaEstado>(
      builder: (context, state) {
        Nota? currentNOta;

        if(state is LoadedEvento){
          currentNOta = state.notas.firstWhere(
            (n) => n.nombre == notaInicla.nombre,
            orElse: () => notaInicla
          );
        }

        if(currentNOta == null || (state is LoadedEvento && !state.notas.contains(currentNOta))){
          WidgetsBinding.instance.addPostFrameCallback((_){
            Navigator.of(context).pop();
          });
          return Container();
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(currentNOta.nombre),
            backgroundColor: Colors.grey[700],
            actions: [
              IconButton( icon: Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
              onPressed: (){
                context.read<NotaBloc>().add(DeleteNotasEvento(currentNOta!));
                Navigator.of(context).pop();
              },)
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Descripcioon', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 10),
                      const Text('Detalles', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text(
                        currentNOta.descripcion,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const Divider(height: 40, color: Colors.white38),
        
                      const Text('Progreso', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      
                      // El widget de la gráfica de progreso
                      _GraficoProgreso(nota: currentNOta),
                      const SizedBox(height: 30),
        
                      const Text('Tareas / Actividades', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      ...currentNOta.tareas.map((tarea) => Row(
                        children: [
                          Checkbox(value: tarea.completada,
                           onChanged: (bool? newValue) {
                             _toggleTare(context, currentNOta!, tarea);
                           },
                           activeColor: Colors.green
                           )
                           ,
                           Expanded(child: Text(
                            tarea.nombre,
                            style: TextStyle(
                              color: tarea.completada ? Colors.greenAccent : Colors.white,
                              decoration: tarea.completada ? TextDecoration.lineThrough: TextDecoration.none
                            )
                           )
                           ),
                    
                        ],
                        
                      ))
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}

class _GraficoProgreso extends StatelessWidget {
  final Nota nota;
  
  const _GraficoProgreso({super.key, required this.nota});

  // Lógica de cálculo del progreso
  double _calcularProgreso() {
    // Cálculo 1: Progreso basado en tareas (Prioridad)
    if (nota.tareas.isNotEmpty) {
      final completadas = nota.tareas.where((t) => t.completada).length;
      return completadas / nota.tareas.length; // Devuelve un valor de 0.0 a 1.0
    } 
    
    // Cálculo 2: Progreso basado en el tiempo (Si no hay tareas)
    final ahora = DateTime.now();
    final fechaLimite = nota.fechaLimite;
    
    // Si la fecha límite ya pasó, el progreso es 100% (o 1.0)
    if (ahora.isAfter(fechaLimite)) {
      return 1.0;
    }

    // Días totales entre la creación y la fecha límite (simplificado)
    const int totalDias = 10; 
    final diasFaltantes = fechaLimite.difference(ahora).inDays;
    
    // El progreso es cuánto tiempo ha pasado.
    final progreso = 1.0 - (diasFaltantes / totalDias).clamp(0.0, 1.0);
    
    return progreso; // Devuelve un valor de 0.0 a 1.0
  }

  @override
  Widget build(BuildContext context) {
    final progreso = _calcularProgreso(); // Valor entre 0.0 y 1.0
    final porcentaje = (progreso * 100).toInt();

    return Column(
      children: [
        Text(
          '$porcentaje%',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 10),
        Center(
          child: SizedBox(
            width: 150,
            height: 150,
            child: CustomPaint(
              painter: _GraficoDonaPainter(progreso: progreso),
              child: Container(),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          nota.tareas.isNotEmpty 
            ? 'Progreso por Tareas (${nota.tareas.where((t) => t.completada).length}/${nota.tareas.length})'
            : 'Progreso por Tiempo Restante',
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }
}

// CustomPainter para dibujar la gráfica de dona (el círculo de progreso)
class _GraficoDonaPainter extends CustomPainter {
  final double progreso; // Valor de 0.0 a 1.0

  _GraficoDonaPainter({required this.progreso});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 15.0;

    // Fondo gris del círculo (el 100% del espacio)
    final paintFondo = Paint()
      ..color = Colors.grey[500]! // Color de fondo gris claro
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Arco de progreso (el color turquesa)
    final paintProgreso = Paint()
      ..color = const Color.fromARGB(255, 62, 196, 230) // Color turquesa/azul claro
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round // Bordes redondeados
      ..strokeWidth = strokeWidth;

    // Dibujar el círculo de fondo
    canvas.drawCircle(center, radius - strokeWidth / 2, paintFondo);

    // Dibujar el arco de progreso
    double sweepAngle = 2 * 3.1415926535 * progreso;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -3.1415926535 / 2, // Empezar arriba (posición de 12 en un reloj)
      sweepAngle,
      false,
      paintProgreso,
    );
  }

  @override
  bool shouldRepaint(covariant _GraficoDonaPainter oldDelegate) {
    return oldDelegate.progreso != progreso;
  }
}