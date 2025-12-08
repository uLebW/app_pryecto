// lib/screens/home/agenda_screen.dart
import 'package:app_pryecto/bloc/auth_bloc.dart';
import 'package:app_pryecto/bloc/eventos.dart';
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
      backgroundColor: Colors.teal,
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          const SafeArea(child: _AppBarAgenda()),
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
    final authBloc = context.read<AuthBloc>();
    final notaBloc = context.read<NotaBloc>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              authBloc.add(LougOutEvento());
            },
            icon: const Icon(
              Icons.logout,
              color: Color.fromARGB(255, 228, 226, 228),
              size: 30,
            ),
          ),
          const Text(
            'Mi agenda',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 231, 230, 231),
            ),
          ),

          IconButton(onPressed: (){
            notaBloc.add(LoadNotas());
          }, icon: const Icon(Icons.refresh, color: Color.fromARGB(255, 226, 223, 226), size: 30))
        ],
      ),
    );
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
            color: const Color.fromARGB(255, 226, 231, 227),
            borderRadius: BorderRadius.circular(25),
          ),
          alignment: Alignment.center,
          child: const Text('AGREGAR NOTA'),
        ),
      ),
    );
  }
}
