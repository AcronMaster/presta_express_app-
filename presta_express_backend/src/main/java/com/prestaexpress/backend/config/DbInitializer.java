package com.prestaexpress.backend.config;

import com.prestaexpress.backend.repository.RolRepository;
import com.prestaexpress.backend.repository.UsuarioRepository;
import com.prestaexpress.backend.security.Roles;
import com.prestaexpress.backend.validation.ValidationService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

/** Ajustes a la BD al arrancar: teléfono único, rol administrador y admin inicial. */
@Component
public class DbInitializer implements CommandLineRunner {

    private static final Logger log = LoggerFactory.getLogger(DbInitializer.class);

    private final JdbcTemplate jdbc;
    private final RolRepository roles;
    private final UsuarioRepository usuarios;
    private final PasswordEncoder encoder;
    private final ValidationService validation;

    @Value("${app.admin.email}") private String adminEmail;
    @Value("${app.admin.password}") private String adminPassword;
    @Value("${app.admin.telefono}") private String adminTelefono;

    public DbInitializer(JdbcTemplate jdbc, RolRepository roles, UsuarioRepository usuarios,
                         PasswordEncoder encoder, ValidationService validation) {
        this.jdbc = jdbc;
        this.roles = roles;
        this.usuarios = usuarios;
        this.encoder = encoder;
        this.validation = validation;
    }

    @Override
    public void run(String... args) {
        try {
            jdbc.execute("CREATE UNIQUE INDEX IF NOT EXISTS idx_usuario_telefono ON usuario(telefonoUsuario)");
        } catch (Exception e) {
            log.warn("No se pudo crear el índice único de teléfono (¿hay teléfonos duplicados?): {}", e.getMessage());
        }

        jdbc.update("INSERT OR IGNORE INTO rol (nombreRol, descripcionRol) VALUES (?, ?)",
                Roles.ADMINISTRADOR, "Administrador: revisa y aprueba documentos");

        String correo = validation.normalizarCorreo(adminEmail);
        if (!usuarios.existeCorreo(correo)) {
            validation.validarRegistro(correo, adminPassword, adminTelefono); // el admin también cumple las reglas
            long idRol = roles.buscarIdPorNombre(Roles.ADMINISTRADOR).orElseThrow();
            usuarios.insertar(idRol, correo, encoder.encode(adminPassword), adminTelefono);
            log.info("Administrador inicial creado: {}", correo);
        }
    }
}
