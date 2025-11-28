// lib/screens/forms/agregar_nota_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/bloc.dart';
import '../../bloc/eventos.dart';
import '../../data/estrucutura_datos.dart';

class AgregarNotaPantalla extends StatefulWidget {
  const AgregarNotaPantalla({super.key});

  @override
  State<AgregarNotaPantalla> createState() => _AgregarNotaPantallaState();
}

class _AgregarNotaPantallaState extends State<AgregarNotaPantalla> {
  final _nombreControlador = TextEditingController();
  final _descripcionControler = TextEditingController();
  String _tipoSeleccionado = 'Personal';
  DateTime _fechaSelec = DateTime.now();
  final List<String> _tipoDeNota = [
    'Personal',
    'Trabajo',
    'Estudio',
    'Recordatorio',
  ];

  ThemeData get theme => Theme.of(context);
  bool _isGuardar = false;

  //Variables para errores
  String? _nombreError;
  String? _descError;
  String? _fechaError;

  //Lista para las tareas de un actividad
  final List<TextEditingController> _controladorTarea = [
    TextEditingController(),
  ];

  void _agregarCampoTarea() {
    setState(() {
      _controladorTarea.add(TextEditingController());
    });
  }

  void _eliminarTarea(int index) {
    if (_controladorTarea.length > 1) {
      setState(() {
        _controladorTarea.removeAt(index);
      });
    }
  }

  void _guardarNpta() {
    // 1. Ocultar el teclado y validar
    FocusScope.of(context).unfocus();
    if (_isGuardar) return;

    bool hayErorr = false;
    setState(() {
      if (_nombreControlador.text.trim().isEmpty) {
        _nombreError = "El nombre de la nota es obligatoria.";
        hayErorr = true;
      } else {
        _nombreError = null;
      }

      if (_descripcionControler.text.trim().isEmpty) {
        _descError =
            "La descripción para la tarea es necesaria, no quieras olvidar que tenías que hacer";
        hayErorr = true;
      } else {
        _descError = null;
      }

      final hoy = DateTime.now();
      final fechaHoySinHora = DateTime(hoy.year, hoy.month, hoy.day);
      final fechaSelecSinHora = DateTime(
        _fechaSelec.year,
        _fechaSelec.month,
        _fechaSelec.day,
      );

      if (_fechaSelec.isBefore(fechaHoySinHora)) {
        _fechaError = "No puedes recordarle al pasado";
        hayErorr = true;
      } else {
        _fechaError = null;
      }
    });

    if (hayErorr) return;

    final List<Tarea> tareasTabla = _controladorTarea
        .map((controller) {
          if (controller.text.trim().isNotEmpty) {
            return Tarea(nombre: controller.text.trim());
          }
          return null;
        })
        .whereType<Tarea>() //Evita nulos
        .toList();

    setState(() {
      _isGuardar = true;
    });

    final nuevaNota = Nota(
      nombre: _nombreControlador.text,
      tipo: _tipoSeleccionado,
      descripcion: _descripcionControler.text,
      fechaLimite: _fechaSelec,
      tareas: tareasTabla, // Se inicializan sin tareas
    );

    // 2. Disparar el Evento BLoC
    context.read<NotaBloc>().add(AddNotaEvento(nuevaNota));

    // 3. Cerrar el modal
    Navigator.of(context).pop();
  }

  Future<void> _selecFecha() async {
    // ... (Lógica para mostrar el DatePicker)
    final DateTime? fechaEleg = await showDatePicker(
      context: context,
      initialDate: _fechaSelec,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (fechaEleg != null && fechaEleg != _fechaSelec) {
      setState(() {
        _fechaSelec = fechaEleg;
        _fechaError = null;
      });
    }
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 158, 81, 154),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Titulo
          const Text(
            "Agregar Nota",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            //Campo nombre
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(10),
              border: _nombreError != null
                  ? Border.all(color: Colors.red)
                  : null,
            ),
            child: TextField(
              controller: _nombreControlador,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(10),
                hintText: "Nombre de la Nota",
                hintStyle: const TextStyle(color: Colors.white54),
                errorText: _nombreError,
                errorStyle: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Campo Tipo de nota (Dropdown)
          const Text('Tipo de nota', style: TextStyle(color: Colors.white70)),
          DropdownButtonFormField<String>(
            value: _tipoSeleccionado,
            items: _tipoDeNota.map((String tipo) {
              return DropdownMenuItem<String>(value: tipo, child: Text(tipo));
            }).toList(),
            onChanged: (String? nuevoValor) {
              if (nuevoValor != null) {
                setState(() {
                  _tipoSeleccionado = nuevoValor;
                });
              }
            },
            dropdownColor: Colors.grey[800],
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white38),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Campo Descripción
          const Text('Descripcion', style: TextStyle(color: Colors.white70)),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(10),
              border: _descError != null
                  ? Border.all(color: Colors.redAccent)
                  : null,
            ),
            child: TextField(
              controller: _descripcionControler,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(10),
                errorText: _descError,
                errorStyle: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Campo Fecha con botón de reloj
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50, // Simulación del campo de fecha
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(10),
                        border: _fechaError != null
                            ? Border.all(color: Colors.redAccent)
                            : null,
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        'Fecha: ${_formatearFecha(_fechaSelec)}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _selecFecha,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.access_time, color: Colors.white),
                    ),
                  ),
                ],
              ),
              if (_fechaError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 5),
                  child: Text(
                    _fechaError!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 30),
          Text("Lista de tareas", style: TextStyle(color: Colors.white70)),
          ..._controladorTarea.asMap().entries.map((entry) {
            int index = entry.key;
            TextEditingController controller = entry.value;

            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: _CampoTarea(
                controller: controller,
                onDelete: _controladorTarea.length > 1
                    ? () => _eliminarTarea(index)
                    : null,
              ),
            );
          }),

          GestureDetector(
            onTap: _agregarCampoTarea,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 141, 91, 134),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.green),
                  Text("Agregar Tarea", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
          // Botón Guardar
          GestureDetector(
            onTap: _isGuardar ? null : _guardarNpta,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: _isGuardar
                    ? Colors.greenAccent
                    : const Color.fromARGB(255, 71, 133, 196),
                borderRadius: BorderRadius.circular(25),
              ),
              alignment: Alignment.center,
              child: const Text(
                'GUARDAR',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _CampoTarea extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onDelete;

  const _CampoTarea({required this.controller, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 94, 94, 94),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: const InputDecoration(
                hintStyle: TextStyle(color: Colors.white),
                hintText: "Nombre de tarea",
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(10),
              ),
            ),
          ),
        ),
        if (onDelete != null)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: GestureDetector(
              onTap: onDelete,
              child: Icon(Icons.delete_sweep, color: Colors.redAccent),
            ),
          ),
      ],
    );
  }
}
