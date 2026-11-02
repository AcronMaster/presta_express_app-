import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;


class ApiException implements Exception {
  final int status; 
  final String mensaje;
  final List<String> detalles;

  ApiException(this.status, this.mensaje, [this.detalles = const []]);

  String get textoCompleto {
    if (detalles.isEmpty) return mensaje;
    return '$mensaje\n${detalles.map((d) => '• $d').join('\n')}';
  }

  @override
  String toString() => textoCompleto;
}

class Sesion {
  static String? token;
  static String? rol;
  static String? correo;

  static void limpiar() {
    token = null;
    rol = null;
    correo = null;
  }
}

class ApiService {
  /// Ejemplo: 'http://192.168.1.50:8080'
  static const String _urlManual = '';

  static const Duration _timeout = Duration(seconds: 10);

  static String get baseUrl {
    if (_urlManual.isNotEmpty) return _urlManual;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }
    // Windows, web, iOS simulator
    return 'http://localhost:8080';
  }

  static Map<String, String> _headers({bool auth = false}) {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (auth && Sesion.token != null) {
      h['Authorization'] = 'Bearer ${Sesion.token}';
    }
    return h;
  }

  /// Ejecuta la petición y traduce errores de red / HTTP a ApiException.
  static Future<dynamic> _enviar(
    Future<http.Response> Function() peticion,
  ) async {
    http.Response r;
    try {
      r = await peticion().timeout(_timeout);
    } on TimeoutException {
      throw ApiException(0, 'El servidor tardó demasiado en responder');
    } on http.ClientException {
      throw ApiException(
        0,
        'No se pudo conectar con el servidor. Verifica que el backend esté encendido.',
      );
    }

    dynamic body;
    try {
      body = r.body.isEmpty ? null : jsonDecode(utf8.decode(r.bodyBytes));
    } catch (_) {
      body = null;
    }

    if (r.statusCode >= 200 && r.statusCode < 300) return body;

    final Map m = body is Map ? body : {};
    final detalles = m['detalles'] is List
        ? (m['detalles'] as List).map((e) => e.toString()).toList()
        : <String>[];
    throw ApiException(
      r.statusCode,
      (m['error'] ?? 'Error inesperado (${r.statusCode})').toString(),
      detalles,
    );
  }

  static Future<void> registrar({
    required String correo,
    required String password,
    required String telefono,
  }) async {
    await _enviar(
      () => http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: _headers(),
        body: jsonEncode({
          'correo': correo,
          'password': password,
          'telefono': telefono,
        }),
      ),
    );
  }


  static Future<String> login(String correo, String password) async {
    final data = await _enviar(
      () => http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: _headers(),
        body: jsonEncode({'correo': correo, 'password': password}),
      ),
    ) as Map<String, dynamic>;

    final u = data['usuario'] as Map<String, dynamic>;
    Sesion.token = data['token'] as String;
    Sesion.rol = u['rol'] as String;
    Sesion.correo = u['correo'] as String;
    return Sesion.rol!;
  }

  static void logout() => Sesion.limpiar();

  static Future<void> subirDocumento({
    required String tipo,
    required String ruta,
    required String formato,
    required int peso,
  }) async {
    await _enviar(
      () => http.post(
        Uri.parse('$baseUrl/api/documentos'),
        headers: _headers(auth: true),
        body: jsonEncode({
          'tipoDocumento': tipo,
          'rutaArchivo': ruta,
          'formatoArchivo': formato,
          'pesoArchivo': peso,
        }),
      ),
    );
  }

  static Future<List<Map<String, dynamic>>> listarDocumentos() async {
    final data = await _enviar(
      () => http.get(
        Uri.parse('$baseUrl/api/documentos'),
        headers: _headers(auth: true),
      ),
    );
    return List<Map<String, dynamic>>.from(data as List);
  }

  /// Solo administrador (el backend responde 403 a cualquier otro rol).
  static Future<void> cambiarEstado(int idDocumento, String estado) async {
    await _enviar(
      () => http.put(
        Uri.parse('$baseUrl/api/documentos/$idDocumento/estado'),
        headers: _headers(auth: true),
        body: jsonEncode({'estado': estado}),
      ),
    );
  }

  /// Solo administrador.
  static Future<List<Map<String, dynamic>>> listarUsuarios() async {
    final data = await _enviar(
      () => http.get(
        Uri.parse('$baseUrl/api/usuarios'),
        headers: _headers(auth: true),
      ),
    );
    return List<Map<String, dynamic>>.from(data as List);
  }
}
