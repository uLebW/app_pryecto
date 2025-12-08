// lib/screens/details/nota_detalle_screen.dart
import 'package:app_pryecto/bloc/bloc.dart';
import 'package:app_pryecto/bloc/estado.dart';
import 'package:app_pryecto/bloc/eventos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/estrucutura_datos.dart';
import 'package:intl/intl.dart';

class NotaDetalleScreen extends StatelessWidget {
  final Nota notaInicla;

  const NotaDetalleScreen({Key? key, required this.notaInicla})
    : super(key: key);

  void _toggleTare(BuildContext context, Nota currentNOta, Tarea tarea) {
    context.read<NotaBloc>().add(
      ActualizarTarea(
        currentNOta,
        Tarea(
          id: tarea.id,
          nombre: tarea.nombre,
          completada: !tarea.completada,
          notaId: tarea.notaId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotaBloc, NotaEstado>(
      builder: (context, state) {
        Nota? currentNOta;

        if (state is LoadedEvento) {
          currentNOta = state.notas.firstWhere(
            (n) => n.nombre == notaInicla.nombre,
            orElse: () => notaInicla,
          );
        }

        if (currentNOta == null ||
            (state is LoadedEvento && !state.notas.contains(currentNOta))) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pop();
          });
          return Container();
        }

        return Scaffold(
          backgroundColor: Colors.teal,
          extendBodyBehindAppBar: true,


          appBar: AppBar(
          title: Text(currentNOta.nombre, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent, // Transparente para que se vea el fondo
          elevation: 0, // Sin sombra en el AppBar
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
              onPressed: () {
                // Mostrar diálogo de confirmación antes de eliminar
                _confirmarEliminacion(context, currentNOta!);
              },
            )
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            // Puedes colocar aquí un BoxDecoration con un LinearGradient si el Scaffold no lo tiene
            // Por ahora, asumimos que el widget superior lo provee.
          ),
          child: Column(
            children: [
              // Espacio ocupado por el AppBar transparente
              SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight), 
              
              Expanded(
                child: Container(
                  // ⭐️ Estilo de tarjeta flotante
                  margin: const EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 0),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white, // Fondo blanco para el contenido
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                      bottomLeft: Radius.circular(0), // Puedes ajustar si quieres la esquina inferior
                      bottomRight: Radius.circular(0),
                    ),
                    boxShadow: [ // Sombra sutil
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 5,
                        blurRadius: 15,
                        offset: const Offset(0, 3), 
                      ),
                    ],
                  ),
          child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- SECCIÓN 1: DETALLES ---
                        const Text('Descripción', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        const SizedBox(height: 5),
                        Text(currentNOta.nombre, style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text(currentNOta.descripcion, style: const TextStyle(color: Colors.black87, fontSize: 16)),
                        const SizedBox(height: 20),
                        
                        // Información de la Fecha
                        _buildInfoRow(
                            icon: Icons.calendar_today, 
                            label: 'Fecha Límite', 
                            value: DateFormat('dd MMM yyyy').format(currentNOta.fechaLimite) // Requiere intl package
                        ),
                        _buildInfoRow(
                            icon: Icons.label, 
                            label: 'Tipo', 
                            value: currentNOta.tipo
                        ),
                        
                        const Divider(height: 40, color: Colors.grey),

                        // --- SECCIÓN 2: PROGRESO ---
                        const Text('Progreso', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),
                        
                        // El widget de la gráfica de progreso con animación
                        _GraficoProgreso(nota: currentNOta),
                        const Divider(height: 40, color: Colors.grey),


                        // --- SECCIÓN 3: TAREAS ---
                        const Text('Tareas / Actividades', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),

                        // Lista Animada de Tareas (usando el nuevo widget estilizado)
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Column(
                            key: ValueKey(currentNOta.tareas.length),
                            children: currentNOta.tareas.map((tarea) => 
                              _TareaListItem(
                                key: ValueKey(tarea.id), 
                                nota: notaInicla,
                                tarea: tarea,
                                onToggle: (t) => _toggleTare(context, currentNOta!, t),
                              )
                            ).toList(),
                        ),
                      ),
                    ]),
                  ),
                ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Helper para mostrar información clave
  Widget _buildInfoRow({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 18),
          const SizedBox(width: 10),
          Text('$label: ', style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // Diálogo de confirmación para eliminar
  void _confirmarEliminacion(BuildContext context, Nota nota) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar Eliminación"),
          content: Text("¿Estás seguro de que quieres eliminar la nota '${nota.nombre}'?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
              onPressed: () {
                context.read<NotaBloc>().add(DeleteNotasEvento(nota));
                Navigator.of(context).pop(); // Cierra el diálogo
                Navigator.of(context).pop(); // Cierra la pantalla de detalles
              },
            ),
          ],
        );
      },
    );
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

    final tareasCompletadas = nota.tareas.where((t) => t.completada).length;

    return Column(
      children: [
        Center(
          child: SizedBox(
            width: 150,
            height: 150,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: progreso),
              duration: const Duration(milliseconds: 700),
              builder: (context, animatedProgress, child) {
                return Stack( // ⭐️ Usamos Stack para centrar el porcentaje en el gráfico
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      painter: _GraficoDonaPainter(progreso: animatedProgress),
                      size: const Size(150, 150),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${(animatedProgress * 100).toInt()}%',
                          style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        // Texto de subtítulo (Progreso por Tareas (3/4))
                        Text(
                          nota.tareas.isNotEmpty
                            ? 'Progreso (${tareasCompletadas}/${nota.tareas.length})'
                            : 'Progreso por Tiempo',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
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
      ..color =
          Colors.grey[200]! // Color de fondo gris claro
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Arco de progreso (el color turquesa)
    final paintProgreso = Paint()
      ..color =
          const Color.fromARGB(255, 62, 196, 230) // Color turquesa/azul claro
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap
          .round // Bordes redondeados
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

class _TareaListItem extends StatelessWidget {
  final Nota nota;
  final Tarea tarea;
  final Function(Tarea) onToggle;

  const _TareaListItem({
    Key? key,
    required this.nota,
    required this.tarea,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0), // Espacio entre tarjetas
      child: Card( // ⭐️ Usamos Card para el efecto de tarjeta individual
        elevation: 1, // Sombra sutil para la tarjeta de tarea
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: tarea.completada ? Colors.green.withOpacity(0.5) : Colors.grey[300]!, // Borde si está completada
            width: 1,
          ),
        ),
        child: ListTile(
          onTap: () => onToggle(tarea), // Permite tocar toda la fila para hacer toggle
          leading: Checkbox(
            value: tarea.completada,
            onChanged: (bool? newValue) {
              onToggle(tarea);
            },
            activeColor: Colors.green, // Color verde al marcar
            checkColor: Colors.white,
            side: const BorderSide(color: Colors.grey, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), // Checkbox cuadrado/redondeado
          ),
          title: Text(
            tarea.nombre,
            style: TextStyle(
              color: tarea.completada ? Colors.green : Colors.black, // Color más fuerte al completar
              decoration: tarea.completada ? TextDecoration.lineThrough : TextDecoration.none,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
