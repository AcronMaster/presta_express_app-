import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/mensajes.dart';
import '../widgets/app_logo.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import 'admin_screen.dart';
import 'signup_screen.dart';
import 'upload_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _correoCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool rememberMe = false;
  bool _cargando = false;

  @override
  void dispose() {
    _correoCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    final correo = _correoCtrl.text.trim();
    final pass = _passCtrl.text;

    if (correo.isEmpty || pass.isEmpty) {
      mostrarMensaje(context, 'Ingresa tu correo y contraseña', error: true);
      return;
    }

    setState(() => _cargando = true);
    try {
      final rol = await ApiService.login(correo, pass);
      if (!mounted) return;
      setState(() => _cargando = false);

      // La pantalla depende del rol que devuelve el backend
      final Widget destino = rol == 'administrador'
          ? const AdminScreen()
          : const UploadScreen();

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => destino),
      );

      // Al volver al login (por cualquier vía) se cierra la sesión
      ApiService.logout();
      if (!mounted) return;
      _passCtrl.clear();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _cargando = false);
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
              const SizedBox(height: 60),
              const AppLogo(height: 90),
              const SizedBox(height: 40),
              const Text(
                'Bienvenido de nuevo',
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
                label: 'Contraseña',
                controller: _passCtrl,
                obscureText: true,
              ),
              Row(
                children: [
                  Switch(
                    value: rememberMe,
                    onChanged: (value) {
                      setState(() {
                        rememberMe = value;
                      });
                    },
                    activeThumbColor: const Color(0xFF0A3B7C),
                  ),
                  const Text(
                    'Recordar correo',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              PrimaryButton(
                text: 'Iniciar sesión',
                isLoading: _cargando,
                onPressed: _iniciarSesion,
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '¿No tienes una cuenta? ',
                    style: TextStyle(fontSize: 16),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Registrate',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF158134), // Verde
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
