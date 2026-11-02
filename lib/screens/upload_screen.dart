import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/mensajes.dart';
import '../widgets/app_logo.dart';
import '../widgets/primary_button.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  // Nombres de tipo que reconoce el backend
  static const _tipoId = 'Identificación oficial';
  static const _tipoIngresos = 'Comprobante de ingresos';
  static const _tipoDomicilio = 'Comprobante de domicilio';

  static const _extImagenYPdf = ['pdf', 'jpg', 'jpeg', 'png'];
  static const _extSoloPdf = ['pdf'];
  static const int _pesoMax = 3 * 1024 * 1024; // 3 MB

  bool termsAccepted = false;
  bool _enviando = false;
  final Map<String, PlatformFile> _archivos = {};
  final Map<String, int> _pesos = {}; // peso en bytes de cada archivo

  Future<void> _seleccionar(String tipo, List<String> permitidas) async {
    // file_picker 13: se llama directo y pickFile devuelve un solo archivo
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: permitidas,
    );
    if (file == null) return; // canceló
    if (!mounted) return;

    final ext = (file.extension ?? '').toLowerCase();
    if (!permitidas.contains(ext)) {
      mostrarMensaje(
        context,
        'Formato no permitido. Usa: ${permitidas.map((e) => e.toUpperCase()).join(', ')}',
        error: true,
      );
      return;
    }

    // En la versión 13 el peso se obtiene con length() / lengthSync()
    final peso = file.lengthSync() ?? await file.length();
    if (!mounted) return;
    if (peso == null) {
      mostrarMensaje(context, 'No se pudo leer el tamaño del archivo',
          error: true);
      return;
    }
    if (peso > _pesoMax) {
      mostrarMensaje(context, 'El archivo supera el máximo de 3 MB', error: true);
      return;
    }

    setState(() {
      _archivos[tipo] = file;
      _pesos[tipo] = peso;
    });
  }

  /// El backend solo acepta letras, números, _ - . / en la ruta.
  String _rutaSegura(String nombre) {
    var limpio = nombre
        .replaceAll(RegExp(r'[^A-Za-z0-9_.\-]'), '_')
        .replaceAll(RegExp(r'\.{2,}'), '.');
    if (limpio.length > 100) limpio = limpio.substring(limpio.length - 100);
    return 'uploads/${DateTime.now().millisecondsSinceEpoch}_$limpio';
  }

  String _formatoPeso(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  Future<void> _enviar() async {
    if (!termsAccepted) {
      mostrarMensaje(context, 'Debes aceptar los términos y condiciones',
          error: true);
      return;
    }

    final faltan = [_tipoId, _tipoIngresos, _tipoDomicilio]
        .where((t) => !_archivos.containsKey(t))
        .toList();
    if (faltan.isNotEmpty) {
      mostrarMensaje(context, 'Falta adjuntar: ${faltan.join(', ')}',
          error: true);
      return;
    }

    setState(() => _enviando = true);
    try {
      for (final entry in _archivos.entries) {
        final f = entry.value;
        await ApiService.subirDocumento(
          tipo: entry.key,
          ruta: _rutaSegura(f.name),
          formato: (f.extension ?? '').toLowerCase(),
          peso: _pesos[entry.key]!,
        );
      }
      if (!mounted) return;
      mostrarMensaje(context, '¡Documentos enviados con éxito!');
      Navigator.pop(context); // regresa al Login (cierra sesión)
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _enviando = false);
      mostrarMensaje(context, e.textoCompleto, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const AppLogo(height: 70),
              const SizedBox(height: 20),
              const Text(
                'Cargar documentos',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Sube tus documentos legibles para validar\ntu solicitud de credito',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              _buildDocumentBox(
                tipo: _tipoId,
                title: 'Identificación oficial',
                subtitle: 'INE, Pasaporte o Cédula(PDF o Imagen)',
                allowedFormat: 'Formato PDF, JPG o PNG',
                permitidas: _extImagenYPdf,
              ),
              const SizedBox(height: 20),

              _buildDocumentBox(
                tipo: _tipoIngresos,
                title: 'Comprobante de Ingresos',
                subtitle: 'Recibo de nómina(Solo PDF)',
                allowedFormat: 'Formato PDF',
                permitidas: _extSoloPdf,
              ),
              const SizedBox(height: 20),

              _buildDocumentBox(
                tipo: _tipoDomicilio,
                title: 'Comprobante de Domicilio',
                subtitle: 'Luz, agua o teléfono menos a 3 meses(Solo PDF)',
                allowedFormat: 'Formato PDF',
                permitidas: _extSoloPdf,
              ),
              const SizedBox(height: 30),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: termsAccepted,
                      onChanged: (value) {
                        setState(() {
                          termsAccepted = value ?? false;
                        });
                      },
                      activeColor: const Color(0xFF0A3B7C),
                      shape: const CircleBorder(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(text: 'He leído y acepto los '),
                          TextSpan(
                            text: 'términos,condiciones\ny la política de privacidad',
                            style: TextStyle(
                              color: Color(0xFF158134),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: ' acerca del tratamiento de los documentos subidos.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              PrimaryButton(
                text: 'Enviar documentos',
                icon: Icons.arrow_forward,
                isLoading: _enviando,
                onPressed: _enviar,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentBox({
    required String tipo,
    required String title,
    required String subtitle,
    required String allowedFormat,
    required List<String> permitidas,
  }) {
    final archivo = _archivos[tipo];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF0A3B7C), width: 1.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const TextSpan(
                        text: '*',
                        style: TextStyle(fontSize: 18, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Max 3MB',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 16),

          // Toda la zona punteada es tocable para elegir el archivo
          GestureDetector(
            onTap: _enviando ? null : () => _seleccionar(tipo, permitidas),
            child: CustomPaint(
              painter: DashedRectPainter(
                color: const Color(0xFF0A3B7C),
                strokeWidth: 1.2,
                gap: 5.0,
              ),
              child: Container(
                width: double.infinity,
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: archivo == null
                    ? Column(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              const Icon(
                                Icons.insert_drive_file,
                                color: Color(0xFF158134),
                                size: 40,
                              ),
                              Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xFF158134),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Toca para adjuntar archivo',
                            style: TextStyle(
                              color: Color(0xFF0A3B7C),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            allowedFormat,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFF158134),
                              size: 40,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              archivo.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF0A3B7C),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_formatoPeso(_pesos[tipo] ?? 0)} · toca para cambiar',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Clase para dibujar el borde punteado sin paquetes externos
class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(12),
        ),
      );

    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + 5.0),
          Offset.zero,
        );
        distance += 5.0 + gap;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
