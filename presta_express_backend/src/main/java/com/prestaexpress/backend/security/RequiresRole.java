package com.prestaexpress.backend.security;

import java.lang.annotation.*;

/** Restringe un endpoint (o un controlador completo) a los roles indicados. */
@Target({ElementType.METHOD, ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
public @interface RequiresRole {
    String[] value();
}
