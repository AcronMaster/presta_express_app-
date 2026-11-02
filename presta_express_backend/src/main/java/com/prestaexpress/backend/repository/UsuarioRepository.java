package com.prestaexpress.backend.repository;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

/** TODAS las consultas usan parámetros (?) — nunca se concatenan datos del usuario. */
@Repository
public class UsuarioRepository {

    private static final String SELECT_BASE =
            "SELECT u.idUsuario, u.correoUsuario, u.passwordUsuario, u.telefonoUsuario, r.nombreRol "
                    + "FROM usuario u JOIN rol r ON r.idRol = u.idRol ";

    private static final RowMapper<UsuarioRow> MAPPER = (rs, i) -> new UsuarioRow(
            rs.getLong("idUsuario"),
            rs.getString("correoUsuario"),
            rs.getString("passwordUsuario"),
            rs.getString("telefonoUsuario"),
            rs.getString("nombreRol"));

    private final JdbcTemplate jdbc;

    public UsuarioRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public boolean existeCorreo(String correo) {
        Integer n = jdbc.queryForObject(
                "SELECT COUNT(*) FROM usuario WHERE correoUsuario = ?", Integer.class, correo);
        return n != null && n > 0;
    }

    public boolean existeTelefono(String telefono) {
        Integer n = jdbc.queryForObject(
                "SELECT COUNT(*) FROM usuario WHERE telefonoUsuario = ?", Integer.class, telefono);
        return n != null && n > 0;
    }

    public void insertar(long idRol, String correo, String passwordHash, String telefono) {
        jdbc.update(
                "INSERT INTO usuario (idRol, correoUsuario, passwordUsuario, telefonoUsuario) VALUES (?, ?, ?, ?)",
                idRol, correo, passwordHash, telefono);
    }

    public Optional<UsuarioRow> buscarPorCorreo(String correo) {
        return jdbc.query(SELECT_BASE + "WHERE u.correoUsuario = ?", MAPPER, correo).stream().findFirst();
    }

    public Optional<UsuarioRow> buscarPorId(long id) {
        return jdbc.query(SELECT_BASE + "WHERE u.idUsuario = ?", MAPPER, id).stream().findFirst();
    }

    /** Listado sin el hash de la contraseña. */
    public List<Map<String, Object>> listar() {
        return jdbc.queryForList(
                "SELECT u.idUsuario, u.correoUsuario AS correo, u.telefonoUsuario AS telefono, "
                        + "r.nombreRol AS rol, u.fechaRegistro "
                        + "FROM usuario u JOIN rol r ON r.idRol = u.idRol ORDER BY u.idUsuario");
    }
}
