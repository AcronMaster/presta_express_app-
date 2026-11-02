package com.prestaexpress.backend.controller;

import com.prestaexpress.backend.security.AuthUser;
import com.prestaexpress.backend.security.RequiresRole;
import com.prestaexpress.backend.security.Roles;
import com.prestaexpress.backend.service.DocumentoService;
import java.util.List;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/documentos")
public class DocumentoController {

    public record DocumentoRequest(String tipoDocumento, String rutaArchivo, String formatoArchivo, Long pesoArchivo) {}
    public record EstadoRequest(String estado) {}

    private final DocumentoService service;

    public DocumentoController(DocumentoService service) {
        this.service = service;
    }

    /** Usuario o administrador: registra un documento propio. */
    @PostMapping
    public ResponseEntity<Map<String, String>> subir(@RequestAttribute("authUser") AuthUser user,
                                                     @RequestBody DocumentoRequest req) {
        service.subir(user, req.tipoDocumento(), req.rutaArchivo(), req.formatoArchivo(), req.pesoArchivo());
        return ResponseEntity.status(HttpStatus.CREATED).body(Map.of("mensaje", "Documento registrado"));
    }

    /** El usuario ve solo los suyos; el administrador ve todos. */
    @GetMapping
    public List<Map<String, Object>> listar(@RequestAttribute("authUser") AuthUser user) {
        return service.listar(user);
    }

    /** Solo administradores aprueban o rechazan. */
    @PutMapping("/{id}/estado")
    @RequiresRole(Roles.ADMINISTRADOR)
    public Map<String, String> cambiarEstado(@PathVariable long id, @RequestBody EstadoRequest req) {
        service.cambiarEstado(id, req.estado());
        return Map.of("mensaje", "Estado actualizado");
    }
}
