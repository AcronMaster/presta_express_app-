package com.prestaexpress.backend.repository;

import java.util.List;
import java.util.Map;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class DocumentoRepository {

    private static final String COLS =
            "idDocumento, idUsuario, tipoDocumento, rutaArchivo, formatoArchivo, pesoArchivo, estadoAprobacion, fechaSubida";

    private final JdbcTemplate jdbc;

    public DocumentoRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public void insertar(long idUsuario, String tipo, String ruta, String formato, long peso) {
        jdbc.update(
                "INSERT INTO documento (idUsuario, tipoDocumento, rutaArchivo, formatoArchivo, pesoArchivo) "
                        + "VALUES (?, ?, ?, ?, ?)",
                idUsuario, tipo, ruta, formato, peso);
    }

    public List<Map<String, Object>> listarTodos() {
        return jdbc.queryForList("SELECT " + COLS + " FROM documento ORDER BY idDocumento");
    }

    public List<Map<String, Object>> listarPorUsuario(long idUsuario) {
        return jdbc.queryForList(
                "SELECT " + COLS + " FROM documento WHERE idUsuario = ? ORDER BY idDocumento", idUsuario);
    }

    public int actualizarEstado(long idDocumento, String estado) {
        return jdbc.update("UPDATE documento SET estadoAprobacion = ? WHERE idDocumento = ?",
                estado, idDocumento);
    }
}
