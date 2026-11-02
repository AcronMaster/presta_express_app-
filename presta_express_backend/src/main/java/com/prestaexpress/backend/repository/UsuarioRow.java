package com.prestaexpress.backend.repository;

public record UsuarioRow(long idUsuario, String correo, String passwordHash, String telefono, String rol) {}
