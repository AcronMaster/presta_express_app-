# Presta Express – Backend (Java / Spring Boot + SQLite)

## Requisitos
- JDK 17+
- Maven 3.9+

## Ejecutar
```bash
mvn spring-boot:run
```
Servidor en `http://localhost:8080`. Usa la BD `data/DB_presta_expres.sqlite`.
Al arrancar crea el rol `administrador`, el índice único de teléfono y un admin inicial
(ver `application.properties`; en producción usa variables de entorno `JWT_SECRET` y `ADMIN_PASSWORD`).

Admin por defecto: `admin@prestaexpress.com` / `Admin#2026Pe`

## Endpoints
| Método | Ruta | Acceso |
|---|---|---|
| POST | /api/auth/register | Público |
| POST | /api/auth/login | Público |
| GET | /api/usuarios/me | Autenticado |
| GET | /api/usuarios | administrador |
| POST | /api/documentos | Autenticado |
| GET | /api/documentos | Autenticado (usuario: solo los suyos) |
| PUT | /api/documentos/{id}/estado | administrador |

Rutas protegidas: header `Authorization: Bearer <token>`.

## Pruebas rápidas (curl)
```bash
# Registro válido -> 201
curl -X POST localhost:8080/api/auth/register -H "Content-Type: application/json" \
  -d '{"correo":"ana@correo.com","password":"Clave#1234","telefono":"9991234567"}'

# Repetir el mismo registro -> 409 (correo y teléfono duplicados)
# Teléfono con letras o contraseña débil -> 400

# Inyección SQL en el correo -> 400
curl -X POST localhost:8080/api/auth/login -H "Content-Type: application/json" \
  -d '{"correo":"admin@x.com'"'"' OR 1=1 --","password":"x"}'

# Login
curl -X POST localhost:8080/api/auth/login -H "Content-Type: application/json" \
  -d '{"correo":"ana@correo.com","password":"Clave#1234"}'

# Usuario normal intentando listar usuarios -> 403
curl localhost:8080/api/usuarios -H "Authorization: Bearer <TOKEN_DE_ANA>"

# Intentar auto-asignarse rol admin al registrarse -> 400 (campo no permitido)
curl -X POST localhost:8080/api/auth/register -H "Content-Type: application/json" \
  -d '{"correo":"x@x.com","password":"Clave#1234","telefono":"9990000000","idRol":2}'
```

## Uso desde Flutter
- Emulador Android: `http://10.0.2.2:8080`
- Guardar el token tras el login (p. ej. `flutter_secure_storage`) y enviarlo en el header `Authorization`.
