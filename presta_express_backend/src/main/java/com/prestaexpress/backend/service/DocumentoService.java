package com.prestaexpress.backend.service;

import com.prestaexpress.backend.exception.ApiException;
import com.prestaexpress.backend.repository.DocumentoRepository;
import com.prestaexpress.backend.security.AuthUser;
import com.prestaexpress.backend.security.Roles;
import com.prestaexpress.backend.validation.ValidationService;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

@Service
public class DocumentoService {

    private static final Set<String> ESTADOS = Set.of("Pendiente", "Aprobado", "Rechazado");

    private final DocumentoRepository docs;
    private final ValidationService validation;

    public DocumentoService(DocumentoRepository docs, ValidationService validation) {
        this.docs = docs;
        this.validation = validation;
    }

    public void subir(AuthUser user, String tipo, String ruta, String formato, Long peso) {
        validation.validarDocumento(tipo, ruta, formato, peso);
        // El documento siempre se asigna al usuario autenticado, no al que diga el cliente
        docs.insertar(user.idUsuario(), tipo.trim(), ruta.trim(), formato.trim().toUpperCase(), peso);
    }

    public List<Map<String, Object>> listar(AuthUser user) {
        return Roles.ADMINISTRADOR.equals(user.rol())
                ? docs.listarTodos()
                : docs.listarPorUsuario(user.idUsuario());
    }

    public void cambiarEstado(long idDocumento, String estado) {
        if (estado == null || !ESTADOS.contains(estado)) {
            throw new ApiException(HttpStatus.BAD_REQUEST,
                    "Estado inválido (Pendiente, Aprobado o Rechazado)");
        }
        if (docs.actualizarEstado(idDocumento, estado) == 0) {
            throw new ApiException(HttpStatus.NOT_FOUND, "Documento no encontrado");
        }
    }
}
