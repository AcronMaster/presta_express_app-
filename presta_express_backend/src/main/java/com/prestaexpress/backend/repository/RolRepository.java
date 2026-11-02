package com.prestaexpress.backend.repository;

import java.util.Optional;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class RolRepository {

    private final JdbcTemplate jdbc;

    public RolRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public Optional<Long> buscarIdPorNombre(String nombre) {
        return jdbc.queryForList("SELECT idRol FROM rol WHERE nombreRol = ?", Long.class, nombre)
                .stream().findFirst();
    }
}
