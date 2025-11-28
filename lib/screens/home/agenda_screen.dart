// lib/screens/home/agenda_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'nota_lista.dart';
import '../../bloc/bloc.dart';
import '../cuestionario/agregar_nota.dart';

class PantallaAgenda extends StatelessWidget {
  const PantallaAgenda({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const _AppBarAgenda(),
          const SizedBox(height: 20.0),

          const _BotonAgregarNota(),
          const SizedBox(height: 20.0),

          const Expanded(child: NotaList()), // Usamos NotaList
        ],
      ),
    );
  }
}

class _AppBarAgenda extends StatelessWidget {
  const _AppBarAgenda({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(height: 100.0, color: const Color.fromARGB(255, 162, 93, 172));
  }
}

class _BotonAgregarNota extends StatelessWidget {
  const _BotonAgregarNota({super.key});

  void _mostrarFormulario(BuildContext context) {
    final notaBloc = context.read<NotaBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (modelContext) {
        return BlocProvider.value(
          value: notaBloc,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(modelContext).viewInsets.bottom,
            ),
            child: const AgregarNotaPantalla(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => _mostrarFormulario(context),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 173, 100, 161),
            borderRadius: BorderRadius.circular(25),
          ),
          alignment: Alignment.center,
          child: const Text('AGREGAR NOTA'),
        ),
      ),
    );
  }
}
