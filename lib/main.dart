// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/bloc.dart';
import 'bloc/eventos.dart';
import 'screens/home/agenda_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Se establece el BlocProvider aquí para que toda la app tenga acceso al BLoC
      home: BlocProvider(
        create: (context) => NotaBloc()..add(LoadNotas()), // Inicia cargando las notas
        child: PantallaAgenda(),
      ),
    );
  }
}