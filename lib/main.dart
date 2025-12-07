// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/estado.dart';
import 'data/nota_repo.dart';
import 'bloc/bloc.dart';
import 'bloc/eventos.dart';
import 'screens/home/agenda_screen.dart';
import 'screens/auth/login.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda Suoa',
      home: MultiBlocProvider(providers:[
        BlocProvider<AuthBloc>(create: (context) =>AuthBloc(repo: NotaRepo())),

        BlocProvider<NotaBloc>(create: (context) =>NotaBloc(repob: NotaRepo()))
      ],child: const RootAppWidget()
      ,
      ),
    );
  }
}


// --- WIDGET DE ENRUTAMIENTO BASADO EN EL ESTADO DE AUTH ---

class RootAppWidget extends StatelessWidget {
  const RootAppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Escucha los cambios del AuthBloc para decidir qué pantalla mostrar
    return BlocConsumer<AuthBloc, AuthEstado>(
      listener: (context, state) {
        // Opcional: Manejar errores de Auth aquí (mostrar un SnackBar)
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error de autenticación: ${state.mensaje}')),
          );
        }
        
        // Cargar las notas solo si el Login fue exitoso.
        // Esto previene que se carguen datos si no hay usuario logueado.
        if (state is AuthExito) {
          context.read<NotaBloc>().add(LoadNotas());
        }
      },
      builder: (context, state) {
        
        // 1. Si el usuario se autenticó (AuthExito), muestra la Agenda
        if (state is AuthExito || state is AuthCarg) {
          // Si estamos cargando o ya estamos dentro, mostramos la Agenda.
          // Nota: AuthCargando dentro de AuthExito puede ser un splash screen.
          return const PantallaAgenda();
        }

        // 2. Si es el estado inicial o hubo un error (AuthInicial o AuthError), muestra el Login
        // Esto incluye si el usuario cerró sesión (el Bloc regresa a AuthInicial)
        return const AuthScreen();
      },
    );
  }
}