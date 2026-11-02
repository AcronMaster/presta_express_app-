package com.prestaexpress.backend.service;

import com.prestaexpress.backend.exception.ApiException;
import com.prestaexpress.backend.repository.RolRepository;
import com.prestaexpress.backend.repository.UsuarioRepository;
import com.prestaexpress.backend.repository.UsuarioRow;
import com.prestaexpress.backend.security.JwtService;
import com.prestaexpress.backend.security.Roles;
import com.prestaexpress.backend.validation.ValidationService;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.dao.DataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

    private final ValidationService validation;
    private final UsuarioRepository usuarios;
    private final RolRepository roles;
    private final PasswordEncoder encoder;
    private final JwtService jwt;
    // Hash de relleno para que el login tarde parecido exista o no el correo
    private final String hashFalso;

    public AuthService(ValidationService validation, UsuarioRepository usuarios, RolRepository roles,
                       PasswordEncoder encoder, JwtService jwt) {
        this.validation = validation;
        this.usuarios = usuarios;
        this.roles = roles;
        this.encoder = encoder;
        this.jwt = jwt;
        this.hashFalso = encoder.encode("relleno-no-valido");
    }

    /** El rol NUNCA viene del cliente: todo registro público es "usuario". */
    public Map<String, Object> registrar(String correoRaw, String password, String telefonoRaw) {
        String correo = validation.normalizarCorreo(correoRaw);
        String telefono = telefonoRaw == null ? null : telefonoRaw.trim();

        // 1) Formato + sentencias SQL
        validation.validarRegistro(correo, password, telefono);

        // 2) Información no registrada previamente
        List<String> duplicados = new ArrayList<>();
        if (usuarios.existeCorreo(correo)) duplicados.add("El correo ya está registrado");
        if (usuarios.existeTelefono(telefono)) duplicados.add("El teléfono ya está registrado");
        if (!duplicados.isEmpty()) {
            throw new ApiException(HttpStatus.CONFLICT, "Información ya registrada", duplicados);
        }

        long idRol = roles.buscarIdPorNombre(Roles.USUARIO)
                .orElseThrow(() -> new IllegalStateException("Falta el rol 'usuario' en la BD"));

        // 3) Insertar con hash BCrypt. Los índices UNIQUE cubren condiciones de carrera.
        try {
            usuarios.insertar(idRol, correo, encoder.encode(password), telefono);
        } catch (DataAccessException e) {
            if (String.valueOf(e.getMessage()).contains("UNIQUE constraint failed")) {
                throw new ApiException(HttpStatus.CONFLICT, "Información ya registrada");
            }
            throw e;
        }

        Map<String, Object> out = new LinkedHashMap<>();
        out.put("mensaje", "Usuario registrado correctamente");
        return out;
    }

    public Map<String, Object> login(String correoRaw, String password) {
        String correo = validation.normalizarCorreo(correoRaw);
        validation.validarLogin(correo, password);

        var encontrado = usuarios.buscarPorCorreo(correo);
        boolean ok = encoder.matches(password, encontrado.map(UsuarioRow::passwordHash).orElse(hashFalso));
        if (encontrado.isEmpty() || !ok) {
            // Mensaje genérico: no revela si el correo existe
            throw new ApiException(HttpStatus.UNAUTHORIZED, "Credenciales inválidas");
        }

        UsuarioRow u = encontrado.get();
        Map<String, Object> usuario = new LinkedHashMap<>();
        usuario.put("idUsuario", u.idUsuario());
        usuario.put("correo", u.correo());
        usuario.put("rol", u.rol());

        Map<String, Object> out = new LinkedHashMap<>();
        out.put("token", jwt.generar(u.idUsuario(), u.rol()));
        out.put("tipo", "Bearer");
        out.put("usuario", usuario);
        return out;
    }
}
