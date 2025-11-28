// lib/screens/home/nota_card.dart
import 'package:app_pryecto/bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/estrucutura_datos.dart';
import '../detalles/detalle_nota.dart';

class NotaCard extends StatelessWidget {
  final Nota nota;
  
  const NotaCard({super.key, required this.nota});

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  void _verDetalles(BuildContext context, Nota nota){
    final notaBloc =context.read<NotaBloc>();

    Navigator.of(context).push(
      MaterialPageRoute(builder: (routecontext){
        return BlocProvider.value(value: notaBloc,
        child: NotaDetalleScreen(notaInicla: nota),);
      })
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: GestureDetector(
        onTap: () {
          // Navegación al detalle de la nota
          _verDetalles(context, nota);
        },
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 151, 83, 165), // Color de ejemplo
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nota.nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Fecha: ${_formatearFecha(nota.fechaLimite)}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}