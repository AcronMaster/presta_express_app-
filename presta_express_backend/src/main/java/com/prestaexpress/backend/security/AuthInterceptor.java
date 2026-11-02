package com.prestaexpress.backend.security;

import com.prestaexpress.backend.exception.ApiException;
import com.prestaexpress.backend.repository.UsuarioRepository;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.Arrays;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.method.HandlerMethod;
import org.springframework.web.servlet.HandlerInterceptor;

/**
 * Política "denegar por defecto": toda ruta /api/** exige token válido,
 * salvo las excluidas en WebConfig (registro y login).
 * El rol se consulta en la BD en cada petición, no se confía solo en el token.
 */
@Component
public class AuthInterceptor implements HandlerInterceptor {

    public static final String ATTR_USER = "authUser";

    private final JwtService jwtService;
    private final UsuarioRepository usuarioRepository;

    public AuthInterceptor(JwtService jwtService, UsuarioRepository usuarioRepository) {
        this.jwtService = jwtService;
        this.usuarioRepository = usuarioRepository;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) return true;

        String header = request.getHeader("Authorization");
        if (header == null || !header.startsWith("Bearer ")) {
            throw new ApiException(HttpStatus.UNAUTHORIZED, "Se requiere autenticación");
        }

        long id = jwtService.obtenerIdUsuario(header.substring(7).trim());
        var u = usuarioRepository.buscarPorId(id)
                .orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, "Usuario no válido"));

        if (handler instanceof HandlerMethod hm) {
            RequiresRole req = hm.getMethodAnnotation(RequiresRole.class);
            if (req == null) req = hm.getBeanType().getAnnotation(RequiresRole.class);
            if (req != null && !Arrays.asList(req.value()).contains(u.rol())) {
                throw new ApiException(HttpStatus.FORBIDDEN, "No tienes permisos para esta acción");
            }
        }

        request.setAttribute(ATTR_USER, new AuthUser(u.idUsuario(), u.correo(), u.rol()));
        return true;
    }
}
