import 'package:flutter/material.dart';

/// SnackBar reutilizable: verde para éxito, rojo para error.
void mostrarMensaje(BuildContext context, String texto, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: error ? Colors.redAccent : const Color(0xFF158134),
        duration: Duration(seconds: error ? 6 : 3),
      ),
    );
}
