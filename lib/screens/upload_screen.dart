import 'package:flutter/material.dart';

import '../widgets/app_logo.dart';
import '../widgets/primary_button.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  bool termsAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // Volvemos a la estructura simple de SingleChildScrollView
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
                title: 'Identificación oficial',
                subtitle: 'INE, Pasaporte o Cédula(PDF o Imagen)',
                allowedFormat: 'Formato PDF, JPG o PNG',
              ),
              const SizedBox(height: 20),

              _buildDocumentBox(
                title: 'Comprobante de Ingresos',
                subtitle: 'Recibo de nómina(Solo PDF)',
                allowedFormat: 'Formato PDF',
              ),
              const SizedBox(height: 20),

              _buildDocumentBox(
                title: 'Comprobante de Domicilio',
                subtitle: 'Luz, agua o teléfono menos a 3 meses(Solo PDF)',
                allowedFormat: 'Formato PDF',
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

              // BOTÓN FINAL: Único encargado de regresar al Login
              PrimaryButton(
                text: 'Enviar documentos',
                icon: Icons.arrow_forward,
                onPressed: () {
                  // 1. Validar que se acepten los términos
                  if (!termsAccepted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Debes aceptar los términos y condiciones',
                        ),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }

                  // 2. Aquí iría la lógica para subir los archivos al servidor...

                  // 3. Mostrar mensaje de éxito
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('¡Documentos enviados con éxito!'),
                      backgroundColor: Color(0xFF158134),
                    ),
                  );

                  // 4. Regresar al Login
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentBox({
    required String title,
    required String subtitle,
    required String allowedFormat,
  }) {
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

          CustomPaint(
            painter: DashedRectPainter(
              color: const Color(0xFF0A3B7C),
              strokeWidth: 1.2,
              gap: 5.0,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
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
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
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
