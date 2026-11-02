package com.prestaexpress.backend.exception;

import java.util.List;
import org.springframework.http.HttpStatus;

public class ApiException extends RuntimeException {
    private final HttpStatus status;
    private final List<String> detalles;

    public ApiException(HttpStatus status, String message) {
        this(status, message, List.of());
    }

    public ApiException(HttpStatus status, String message, List<String> detalles) {
        super(message);
        this.status = status;
        this.detalles = detalles;
    }

    public HttpStatus getStatus() { return status; }
    public List<String> getDetalles() { return detalles; }
}
