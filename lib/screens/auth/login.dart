import 'package:app_pryecto/bloc/auth_bloc.dart';
import 'package:app_pryecto/bloc/eventos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  // Estado para saber si estamos en Login o Registro
  bool _isLogin = true;

  // Controladores de texto
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nombreController = TextEditingController(); // Solo para registro

  // Clave para el formulario
  final _formKey = GlobalKey<FormState>();

  // Función para alternar entre modos con animación
  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Dimensiones de la pantalla
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // Un fondo con degradado para que se vea moderno
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 71, 133, 196), // Tu color azul
              Color.fromARGB(255, 141, 91, 134), // Tu color morado
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. Título o Logo (Animado)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                  child: Text(
                    _isLogin ? 'Bienvenido de nuevo' : 'Crea tu cuenta',
                    key: ValueKey<bool>(_isLogin), // Importante para que detecte el cambio
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),

                // 2. Tarjeta del Formulario (Animada en tamaño)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutBack, // Efecto de rebote sutil
                  width: size.width * 0.85,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        
                        // --- CAMPO NOMBRE (Solo en Registro) ---
                        // AnimatedCrossFade hace que aparezca/desaparezca suavemente
                        AnimatedCrossFade(
                          firstChild: Container(), // Espacio vacío cuando es Login
                          secondChild: Column(
                            children: [
                              TextFormField(
                                controller: _nombreController,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.person_outline),
                                  labelText: 'Nombre de Usuario',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                validator: (value) {
                                  if (!_isLogin && (value == null || value.isEmpty)) {
                                    return 'Por favor ingresa tu nombre';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                          crossFadeState: _isLogin ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                          duration: const Duration(milliseconds: 300),
                        ),

                        // --- CAMPO EMAIL ---
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email_outlined),
                            labelText: 'Correo Electrónico',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || !value.contains('@')) {
                              return 'Email inválido';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 20),

                        // --- CAMPO PASSWORD ---
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline),
                            labelText: 'Contraseña',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return 'Mínimo 6 caracteres';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 30),

                        // --- BOTÓN DE ACCIÓN ---
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                final email = _emailController.text.trim();
                                final pass = _passwordController.text.trim();
                                final user = _nombreController.text.trim();
                                if(_isLogin){
                                  context.read<AuthBloc>().add(LoginEvento(email, pass));
                                }else{
                                  context.read<AuthBloc>().add(RegistroEvento(email, pass, user));
                                }
                                print("Formulario válido. Modo Login: $_isLogin");
                                print("Email: ${_emailController.text}");
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 71, 133, 196),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                            ),
                            child: Text(
                              _isLogin ? 'INGRESAR' : 'REGISTRARSE',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 3. Botón para cambiar de modo
                TextButton(
                  onPressed: _toggleAuthMode,
                  child: RichText(
                    text: TextSpan(
                      text: _isLogin ? '¿No tienes cuenta? ' : '¿Ya tienes cuenta? ',
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                      children: [
                        TextSpan(
                          text: _isLogin ? 'Regístrate aquí' : 'Inicia Sesión',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}