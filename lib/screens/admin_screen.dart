import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/mensajes.dart';

/// Pantalla solo para el rol "administrador".
/// Aunque alguien lograra abrirla, el backend responde 403 a otros roles.
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  static const _azul = Color(0xFF0A3B7C);
  static const _verde = Color(0xFF158134);

  bool _cargando = true;
  List<Map<String, dynamic>> _docs = [];
  List<Map<String, dynamic>> _usuarios = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final docs = await ApiService.listarDocumentos();
      final usuarios = await ApiService.listarUsuarios();
      if (!mounted) return;
      setState(() {
        _docs = docs;
        _usuarios = usuarios;
        _cargando = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _cargando = false);
      mostrarMensaje(context, e.textoCompleto, error: true);
    }
  }

  Future<void> _cambiarEstado(int id, String estado) async {
    try {
      await ApiService.cambiarEstado(id, estado);
      if (!mounted) return;
      mostrarMensaje(context, 'Documento $id: $estado');
      await _cargar();
    } on ApiException catch (e) {
      if (!mounted) return;
      mostrarMensaje(context, e.textoCompleto, error: true);
    }
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'Aprobado':
        return _verde;
      case 'Rechazado':
        return Colors.redAccent;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Panel de administración'),
          backgroundColor: _azul,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: _cargar,
              icon: const Icon(Icons.refresh),
              tooltip: 'Actualizar',
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.logout),
              tooltip: 'Cerrar sesión',
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [Tab(text: 'Documentos'), Tab(text: 'Usuarios')],
          ),
        ),
        body: _cargando
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(children: [_listaDocumentos(), _listaUsuarios()]),
      ),
    );
  }

  Widget _listaDocumentos() {
    if (_docs.isEmpty) {
      return const Center(child: Text('No hay documentos registrados'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _docs.length,
      itemBuilder: (context, i) {
        final d = _docs[i];
        final id = (d['idDocumento'] as num).toInt();
        final estado = d['estadoAprobacion'] as String;
        final kb = ((d['pesoArchivo'] as num) / 1024).toStringAsFixed(0);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        d['tipoDocumento'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _colorEstado(estado),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        estado,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Usuario #${d['idUsuario']} · ${d['formatoArchivo']} · $kb KB',
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  d['rutaArchivo'] as String,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () => _cambiarEstado(id, 'Aprobado'),
                      child: const Text('Aprobar'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => _cambiarEstado(id, 'Rechazado'),
                      child: const Text('Rechazar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _listaUsuarios() {
    if (_usuarios.isEmpty) {
      return const Center(child: Text('No hay usuarios registrados'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _usuarios.length,
      separatorBuilder: (context, i) => const Divider(),
      itemBuilder: (context, i) {
        final u = _usuarios[i];
        return ListTile(
          leading: const Icon(Icons.person, color: _azul),
          title: Text(u['correo'] as String),
          subtitle: Text('${u['telefono']} · ${u['rol']}'),
        );
      },
    );
  }
}
