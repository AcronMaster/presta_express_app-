import 'package:flutter/material.dart';

import '../widgets/app_logo.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool termsAccepted = false;

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
              const CustomTextField(label: 'Correo electrónico'),
              const CustomTextField(label: 'Teléfono'),
              const CustomTextField(label: 'Contraseña', obscureText: true),
              const CustomTextField(
                label: 'Confirmar contraseña',
                obscureText: true,
              ),
              const SizedBox(height: 10),
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

              // BOTÓN PARA VOLVER AL LOGIN
              PrimaryButton(
                text: 'Registrarse',
                onPressed: () {
                  // 1. Aquí iría tu lógica para guardar el usuario en Firebase/Backend

                  // 2. Mostramos un mensaje de éxito
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        '¡Cuenta creada con éxito! Por favor inicia sesión.',
                      ),
                      backgroundColor: Color(0xFF158134),
                    ),
                  );

                  // 3. Regresamos a la pantalla de Login
                  Navigator.pop(context);

                  /* 
                  NOTA: Si en lugar de regresar al login quisieras 
                  reiniciar la pila de navegación, podrías usar:
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                  */
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
