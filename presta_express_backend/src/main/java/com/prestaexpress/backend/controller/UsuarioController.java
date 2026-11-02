package com.prestaexpress.backend.controller;

import com.prestaexpress.backend.repository.UsuarioRepository;
import com.prestaexpress.backend.security.AuthUser;
import com.prestaexpress.backend.security.RequiresRole;
import com.prestaexpress.backend.security.Roles;
import java.util.List;
import java.util.Map;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/usuarios")
public class UsuarioController {

    private final UsuarioRepository usuarios;

    public UsuarioController(UsuarioRepository usuarios) {
        this.usuarios = usuarios;
    }

    /** Cualquier usuario autenticado puede ver su propio perfil. */
    @GetMapping("/me")
    public Map<String, Object> me(@RequestAttribute("authUser") AuthUser user) {
        return Map.of("idUsuario", user.idUsuario(), "correo", user.correo(), "rol", user.rol());
    }

    /** Solo administradores. */
    @GetMapping
    @RequiresRole(Roles.ADMINISTRADOR)
    public List<Map<String, Object>> listar() {
        return usuarios.listar();
    }
}
