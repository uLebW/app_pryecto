// lib/screens/home/nota_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/bloc.dart';
import '../../bloc/estado.dart';
import 'nota_card.dart';

class NotaList extends StatelessWidget {
  const NotaList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotaBloc, NotaEstado>(
      builder: (context, state) {
        if (state is LoadingEstado) {
          return const Center(child: CircularProgressIndicator());
        } 
        else if (state is LoadedEvento) {
          final notas = state.notas;
          return ListView.builder(
            itemCount: notas.length,
            itemBuilder: (context, index) {
              return NotaCard(nota: notas[index]);
            },
          );
        }

        return const Center(child: Text("Algo salió mal al cargar las notas."));
      },
    );
  }
}