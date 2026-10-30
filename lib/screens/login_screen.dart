import 'package:flutter/material.dart';
import 'package:presta_expres/screens/upload_screen.dart';

import '../widgets/app_logo.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool rememberMe = false;

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
              const CustomTextField(label: 'Correo electrónico'),
              const CustomTextField(label: 'Contraseña', obscureText: true),
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
                onPressed: () {
                  // Acción de login
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UploadScreen()),
                  );
                },
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
                      // Navegar a registro
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
