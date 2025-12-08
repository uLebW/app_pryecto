import 'dart:convert';
import 'package:http/http.dart' as http;
import 'estrucutura_datos.dart';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';

const String _url = 'https://hzmajhilisgdunaouvwr.supabase.co';
const String _Anonkey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh6bWFqaGlsaXNnZHVuYW91dndyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA5Njg1OTAsImV4cCI6MjA3NjU0NDU5MH0.cYSgZ0buAzniR28ziOfR-d1jYN14JecgaTVbCKRLiwU';

const _baseUrl = '$_url/rest/v1';
const _authUrl = '$_url/auth/v1';

class NotaRepo {
  final http.Client httpClient;

  String? _token;

  NotaRepo._({required this.httpClient, String? loadedToken})
  : _token = loadedToken; 

  // 2. MÉTODO DE FÁBRICA ASÍNCRONO: Punto de entrada público
  static Future<NotaRepo> create({http.Client? httpClient}) async {
    final client = httpClient ?? http.Client();
    
    // Cargar el token de forma síncrona/esperada
    final String? loadedToken = await _loadTokenStatic(); 
    
    // Crear y devolver la instancia del Repo con el token ya cargado
    return NotaRepo._(httpClient: client, loadedToken: loadedToken);
  }
  
  // 3. Método estático y privado para la carga del token
  static Future<String?> _loadTokenStatic() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('supabase_auth_token');
    if (token != null) {
      print('[AUTH INIT] Token recuperado: ¡Usuario previamente logueado!');
    } else {
      print('[AUTH INIT] No se encontró token: Usuario en modo anónimo/deslogueado.');
    }
    return token;
  }
  
  // Tu método saveToken debe usar la variable _token de instancia
  Future<void> saveToken(String token) async {
    _token = token; // Actualiza la instancia
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('supabase_auth_token', token);
    print('[AUTH] Token guardado en almacenamiento persistente.');
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'apikey': _Anonkey,
    'Authorization': 'Bearer ${_token ?? _Anonkey}',
  };

  Future<String?> getCurrentID() async {
    print('[AUTH CHECK] Token antes de getCurrentID: ${_token != null ? "Válido" : "Nulo"}');
    if (_token == null) return null;

    try {
      final res = await httpClient.get(
        Uri.parse('$_authUrl/user'),
        headers: {
          'Content-Type': 'application/json',
          'apikey': _Anonkey,
          'Authorization': 'Bearer $_token',
        },
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        print('[AUTH] UID Obtenido: ${data['id']}'); // ⭐️ PRINT
        return data['id'] as String?;
      } else {
        print('[AUTH] Error al obtener UID (${res.statusCode}): ${res.body}');
        return null;
      }
    } catch (e) {
      print('[AUTH] Excepción al obtener UID: $e');
      return null;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final res = await httpClient.post(
        Uri.parse('$_authUrl/token?grant_type=password'),
        headers: {'Content-Type': 'application/json', 'apikey': _Anonkey},
        body: json.encode({'email': email, 'password': password}),
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final accessToken = data['access_token'];
        if (accessToken != null) {
          await saveToken(accessToken);
        }

        developer.log('Log exitoso', name: 'AUTH');
        print(data);
      } else {
        throw Exception('Error en login: ${res.body}');
      }
    } catch (e) {
      developer.log('Excepcion en login', error: e.toString());
      rethrow;
    }
  }

  Future<void> registro(String email, String password, String user) async {
    try {
      final res = await httpClient.post(
        Uri.parse('$_authUrl/signup'),
        headers: {'Content-Type': 'application/json', 'apikey': _Anonkey},
        body: json.encode({
          'email': email,
          'password': password,
          'data': {'user': user},
        }),
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final accessToken = data['access_token'];

        // ⭐️ CRÍTICO: Guarda el token después del registro
        if (accessToken != null) {
          await saveToken(accessToken);
        }

        developer.log('Registro exitoso', name: 'AUTH');
      } else {
        throw Exception('Error en el registro: ${res.body}');
      }
    } catch (e) {
      developer.log('Ex en el registro', error: e.toString());
      rethrow;
    }
  }

  Future<void> logiut() async{
    _token = null;
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('supabase_auth_token'); // ⭐️ ELIMINAR del almacenamiento
  print('[AUTH] Token eliminado de la sesión y almacenamiento.');
  }

  Future<List<Nota>> fetchNotas() async {
    try {
      const String selectQuery = '/notas?select=*,tareas(*)';
      final resp = await httpClient.get(
        Uri.parse('$_baseUrl$selectQuery'),
        headers: _headers,
      );

      if (resp.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(resp.body);
        print('[DEBUG FETCH] Respuesta JSON recibida: ${resp.body}');
        return jsonList.map((json) => Nota.fromJson(json)).toList();
      } else {
        developer.log(
          'Error fetching notas',
          name: 'ERROR_API',
          error: resp.body,
        );
        throw Exception('Fallo al cargar las notas');
      }
    } catch (e) {
      developer.log(
        'Excepción en fetchNotas',
        name: 'CRASH_NETWORK',
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<Nota> addNota(Nota nota) async {
    final String? userId = await getCurrentID();
    if (userId == null) {
      throw Exception('No se pudo cargar, Inicie sesion');
    }
    // Primero, preparamos el JSON de la NOTA (sin la lista de tareas)
    final Map<String, dynamic> notaJson = {
      'nombre': nota.nombre,
      'tipo': nota.tipo,
      'descripcion': nota.descripcion,
      'fechaLimite': nota.fechaLimite.toIso8601String(),
      'user_id': userId, // 'timestampz'
    };
    print('[CRUD] JSON de Nota a enviar: ${json.encode(notaJson)}'); // ⭐️ PRINT
    print('[CRUD] Header Auth: Bearer $_token');
    final response = await httpClient.post(
      Uri.parse('$_baseUrl/notas'),
      headers: {..._headers, 'Prefer': 'return=representation'},
      body: json.encode(notaJson),
    );

    if (response.statusCode == 201) {
      final List<dynamic> createdJsonList = json.decode(response.body);
      if (createdJsonList.isNotEmpty) {
        final createdNoteJson = json.decode(response.body)[0];
        final newNoteId = createdNoteJson['id'] as int;

        //  Guardar las Tareas usando el nuevo ID
        await _addTareasForNota(newNoteId, nota.tareas, userId);

        // Retornar la nota completa
        return Nota.fromJson({...createdNoteJson, 'tareas': []});
      }
      throw Exception('Fallo al obtener una nota creada');
    } else {
      print('Error al agregar nota: ${response.body}');
      throw Exception('Fallo al agregar la nota');
    }
  }

  // 3. Método para guardar las tareas
  Future<void> _addTareasForNota(
    int notaId,
    List<Tarea> tareas,
    String userId,
  ) async {
    if (tareas.isEmpty) return;

    // Mapear las tareas para incluir el 'nota_id'
    final List<Map<String, dynamic>> tareasToSend = tareas
        .map(
          (t) => {
            'nombre': t.nombre,
            'completada': t.completada,
            'nota_id': notaId,
            'user_id': userId, // CLAVE: Referencia a la tabla Notas
          },
        )
        .toList();

    final response = await httpClient.post(
      Uri.parse('$_baseUrl/tareas'),
      headers: _headers,
      body: json.encode(tareasToSend),
    );

    if (response.statusCode != 201) {
      print('Error al guardar tareas: ${response.body}');
      throw Exception('Fallo al guardar las tareas');
    }
  }

  // 4. ACTUALIZAR TAREA (PATCH)
  Future<void> updateTarea(Tarea tarea) async {
    final response = await httpClient.patch(
      Uri.parse('$_baseUrl/tareas?id=eq.${tarea.id}'),
      headers: _headers,
      body: json.encode({
        'completada': tarea.completada,
      }), // Solo actualizamos 'completada'
    );

    if (response.statusCode != 204) {
      throw Exception('Fallo al actualizar la tarea');
    }
  }

  Future<void> deleteNota(int? id) async {
    final response = await httpClient.delete(
      Uri.parse('$_baseUrl/notas?id=eq.$id'),
      headers: _headers,
    );

    if (response.statusCode != 204) {
      print('Error al eliminar la nota: {$response.body}');
      throw Exception('Fallo en elimianr');
    }
  }
}
