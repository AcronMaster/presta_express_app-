import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/api_service.dart';
import '../utils/mensajes.dart';
import '../widgets/app_logo.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _correoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool termsAccepted = false;
  bool _cargando = false;

  @override
  void dispose() {
    _correoCtrl.dispose();
    _telefonoCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    final correo = _correoCtrl.text.trim();
    final telefono = _telefonoCtrl.text.trim();
    final pass = _passCtrl.text;

    // Validaciones rápidas en la app (el backend vuelve a validar todo)
    if (correo.isEmpty || telefono.isEmpty || pass.isEmpty) {
      mostrarMensaje(context, 'Completa todos los campos', error: true);
      return;
    }
    if (pass != _confirmCtrl.text) {
      mostrarMensaje(context, 'Las contraseñas no coinciden', error: true);
      return;
    }
    if (!termsAccepted) {
      mostrarMensaje(
        context,
        'Debes aceptar los términos y la política de privacidad',
        error: true,
      );
      return;
    }

    setState(() => _cargando = true);
    try {
      await ApiService.registrar(
        correo: correo,
        password: pass,
        telefono: telefono,
      );
      if (!mounted) return;
      mostrarMensaje(context, '¡Cuenta creada con éxito! Por favor inicia sesión.');
      Navigator.pop(context); // regresa al Login
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _cargando = false);
      // Muestra los errores del backend: formato, duplicados, etc.
      mostrarMensaje(context, e.textoCompleto, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const AppLogo(height: 90),
              const SizedBox(height: 30),
              const Text(
                'Crear tu cuenta',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 40),
              CustomTextField(
                label: 'Correo electrónico',
                controller: _correoCtrl,
                keyboardType: TextInputType.emailAddress,
              ),
              CustomTextField(
                label: 'Teléfono',
                controller: _telefonoCtrl,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              CustomTextField(
                label: 'Contraseña',
                controller: _passCtrl,
                obscureText: true,
              ),
              CustomTextField(
                label: 'Confirmar contraseña',
                controller: _confirmCtrl,
                obscureText: true,
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'La contraseña debe tener de 8 a 64 caracteres, con mayúscula, '
                  'minúscula, número y un símbolo (!@#\$%^&*()_+-=.,?).',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: termsAccepted,
                    onChanged: (value) {
                      setState(() {
                        termsAccepted = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFF0A3B7C),
                    shape: const CircleBorder(),
                  ),
                  const Expanded(
                    child: Text.rich(
                      TextSpan(
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                        children: [
                          TextSpan(text: 'Acepto los '),
                          TextSpan(
                            text: 'términos y la política de privacidad',
                            style: TextStyle(
                              color: Color(0xFF158134),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              PrimaryButton(
                text: 'Registrarse',
                isLoading: _cargando,
                onPressed: _registrar,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
