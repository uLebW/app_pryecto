import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Importaciones del Bloc, Repositorio, y Pantallas
import 'bloc/auth_bloc.dart';
import 'bloc/estado.dart';
import 'data/nota_repo.dart';
import 'bloc/bloc.dart';
import 'bloc/eventos.dart';
import 'screens/home/agenda_screen.dart';
import 'screens/auth/login.dart';

void main() {
  // Asegura que Flutter esté inicializado antes de llamar a async
  WidgetsFlutterBinding.ensureInitialized(); 
  runApp(const AppInitializer()); // Llama al nuevo Widget Inicializador
}

// --- NUEVO WIDGET: MANEJA LA CARGA ASÍNCRONA DEL REPOSITORIO ---
class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  //  Método para inicializar el Repo y la app
  Future<NotaRepo> _initializeRepo() async {
    // Aquí, usamos el método estático create() de NotaRepo que espera la carga del token
    final NotaRepo repo = await NotaRepo.create();
    return repo;
  }

  @override
  Widget build(BuildContext context) {
    // Usamos FutureBuilder para esperar a que el Repo esté listo
    return FutureBuilder<NotaRepo>(
      future: _initializeRepo(), // Espera a que el token se cargue
      builder: (context, snapshot) {
        
        // 1. Mostrar pantalla de carga
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Puedes usar un CircularProgressIndicator o una pantalla de Splash
          return const MaterialApp(
            home: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Manejar Errores
        if (snapshot.hasError) {
          // En caso de error crítico (ej: SharedPreferences falló)
          return MaterialApp(
            home: Center(child: Text('Error de inicialización de datos: ${snapshot.error}')),
          );
        }

        // 3. Inicialización Exitosa: Obtener el Repo y montar el BLoC
        final NotaRepo initializedRepo = snapshot.data!;

        return MultiBlocProvider(
          providers: [
            // Ambos BLoCs usan la misma instancia del Repo que ya tiene el token cargado.
            BlocProvider<AuthBloc>(
              // Nota: Se asume que AuthBloc también usa NotaRepo para login/logout
              create: (context) => AuthBloc(repo: initializedRepo),
            ),
            BlocProvider<NotaBloc>(
              create: (context) => NotaBloc(repob: initializedRepo)..add(LoadNotas()),
              // LoadNotas ahora será seguro, pues el token ya está en el Repo
            ),
          ],
          child: const MyAppWrapper(), // Pasa el control al wrapper principal
        );
      },
    );
  }
}

// --- WIDGET ENVOLTORIO PRINCIPAL (Reemplazo de MyApp) ---
class MyAppWrapper extends StatelessWidget {
  const MyAppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda Suoa',
      home: const RootAppWidget(),
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
          
          return const PantallaAgenda();
        }

        // 2. Si es el estado inicial o hubo un error (AuthInicial o AuthError), muestra el Login
        // Esto incluye si el usuario cerró sesión (el Bloc regresa a AuthInicial)
        return const AuthScreen();
      },
    );
  }
}