package com.prestaexpress.backend.validation;

import com.prestaexpress.backend.exception.ApiException;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.regex.Pattern;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

/**
 * Validaciones de formato y detección de sentencias sospechosas.
 * Es una capa EXTRA: la defensa real contra inyección SQL son las consultas parametrizadas.
 */
@Service
public class ValidationService {

    private static final Pattern EMAIL = Pattern.compile(
            "^[A-Za-z0-9._%+\\-]+@[A-Za-z0-9\\-]+(\\.[A-Za-z0-9\\-]+)*\\.[A-Za-z]{2,}$");
    private static final Pattern TELEFONO = Pattern.compile("^[0-9]{10}$");

    // Contraseña: solo estos caracteres (excluye ' " ; \ y espacios)
    private static final String ESPECIALES = "!@#$%^&*()_+\\-=.,?";
    private static final Pattern PASS_CHARSET = Pattern.compile("^[A-Za-z0-9" + ESPECIALES + "]+$");
    private static final Pattern PASS_MAYUS = Pattern.compile("[A-Z]");
    private static final Pattern PASS_MINUS = Pattern.compile("[a-z]");
    private static final Pattern PASS_DIGITO = Pattern.compile("[0-9]");
    private static final Pattern PASS_ESPECIAL = Pattern.compile("[" + ESPECIALES + "]");

    public static final int PASS_MIN = 8;
    public static final int PASS_MAX = 64;

    // Fragmentos típicos de sentencias SQL / comentarios / comillas
    private static final Pattern SQL_SOSPECHOSO = Pattern.compile(
            "(--|;|/\\*|\\*/|'|\"|\\\\|\\b(union|select|insert|update|delete|drop|alter|create|truncate|exec|execute|pragma|attach)\\b"
                    + "|\\b(or|and)\\b\\s+\\S+\\s*=\\s*\\S+)",
            Pattern.CASE_INSENSITIVE);

    private static final Pattern RUTA_SEGURA = Pattern.compile("^[A-Za-z0-9_\\-./ ]+$");

    public static final Set<String> TIPOS_DOCUMENTO = Set.of(
            "identificación oficial", "identificacion oficial",
            "comprobante de ingresos", "comprobante de domicilio");
    private static final Set<String> FORMATOS = Set.of("PDF", "JPG", "JPEG", "PNG");
    public static final long PESO_MAX = 3_145_728L; // 3 MB

    // ---------- API pública ----------

    public String normalizarCorreo(String correo) {
        return correo == null ? null : correo.trim().toLowerCase();
    }

    public void validarRegistro(String correo, String password, String telefono) {
        List<String> errores = new ArrayList<>();
        validarCorreo(correo, errores);
        validarPassword(password, errores);
        validarTelefono(telefono, errores);
        lanzarSiHayErrores(errores);
    }

    public void validarLogin(String correo, String password) {
        List<String> errores = new ArrayList<>();
        if (correo == null || correo.isBlank() || password == null || password.isEmpty()) {
            errores.add("Correo y contraseña son obligatorios");
        } else if (correo.length() > 255 || password.length() > PASS_MAX
                || contieneSql(correo)) {
            errores.add("Datos con formato inválido");
        }
        lanzarSiHayErrores(errores);
    }

    public void validarDocumento(String tipo, String ruta, String formato, Long peso) {
        List<String> errores = new ArrayList<>();

        if (tipo == null || !TIPOS_DOCUMENTO.contains(tipo.trim().toLowerCase())) {
            errores.add("Tipo de documento no válido (identificación oficial, comprobante de ingresos o comprobante de domicilio)");
        }
        if (formato == null || !FORMATOS.contains(formato.trim().toUpperCase())) {
            errores.add("Formato no permitido (PDF, JPG, JPEG o PNG)");
        } else if (tipo != null) {
            String t = tipo.trim().toLowerCase();
            boolean soloPdf = t.equals("comprobante de ingresos") || t.equals("comprobante de domicilio");
            if (soloPdf && !formato.trim().equalsIgnoreCase("PDF")) {
                errores.add("Los comprobantes de ingresos y domicilio solo aceptan PDF");
            }
        }
        if (peso == null || peso <= 0 || peso > PESO_MAX) {
            errores.add("El archivo debe pesar entre 1 byte y 3 MB");
        }
        if (ruta == null || ruta.isBlank() || ruta.length() > 500
                || !RUTA_SEGURA.matcher(ruta).matches() || ruta.contains("..")) {
            errores.add("Ruta de archivo no válida");
        }
        lanzarSiHayErrores(errores);
    }

    public boolean contieneSql(String valor) {
        return valor != null && SQL_SOSPECHOSO.matcher(valor).find();
    }

    // ---------- Internos ----------

    private void validarCorreo(String correo, List<String> errores) {
        if (correo == null || correo.isBlank()) {
            errores.add("El correo es obligatorio");
        } else if (correo.length() > 255 || !EMAIL.matcher(correo).matches()) {
            errores.add("El correo no tiene un formato válido");
        } else if (contieneSql(correo)) {
            errores.add("El correo contiene caracteres o sentencias no permitidas");
        }
    }

    private void validarTelefono(String telefono, List<String> errores) {
        if (telefono == null || !TELEFONO.matcher(telefono).matches()) {
            errores.add("El teléfono debe tener exactamente 10 dígitos numéricos");
        }
    }

    private void validarPassword(String password, List<String> errores) {
        if (password == null || password.isEmpty()) {
            errores.add("La contraseña es obligatoria");
            return;
        }
        if (password.length() < PASS_MIN || password.length() > PASS_MAX) {
            errores.add("La contraseña debe tener entre " + PASS_MIN + " y " + PASS_MAX + " caracteres");
        }
        if (!PASS_CHARSET.matcher(password).matches()) {
            errores.add("La contraseña solo puede usar letras, números y estos símbolos: !@#$%^&*()_+-=.,?");
            return;
        }
        if (password.contains("--") || password.contains("/*")) {
            errores.add("La contraseña contiene una secuencia no permitida");
        }
        if (!PASS_MAYUS.matcher(password).find()) errores.add("La contraseña necesita al menos una mayúscula");
        if (!PASS_MINUS.matcher(password).find()) errores.add("La contraseña necesita al menos una minúscula");
        if (!PASS_DIGITO.matcher(password).find()) errores.add("La contraseña necesita al menos un número");
        if (!PASS_ESPECIAL.matcher(password).find()) errores.add("La contraseña necesita al menos un símbolo especial");
    }

    private void lanzarSiHayErrores(List<String> errores) {
        if (!errores.isEmpty()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Datos inválidos", errores);
        }
    }
}
