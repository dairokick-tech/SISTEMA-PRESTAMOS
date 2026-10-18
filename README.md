# SISTEMA-PRESTAMOS

Portal web de clientes para financieras, con un enlace independiente por empresa.

## Funciones iniciales
- Página pública por financiera: información de contacto y campañas publicadas.
- Formulario público de interés/solicitud de crédito, sin acceso a información privada.
- Simulador referencial de crédito con tasas periódicas o TEA y cuatro métodos de amortización.
- Inicio de sesión con Supabase Auth para clientes.
- Consulta de créditos y cuotas propios, condicionada a que la financiera vincule la cuenta de acceso con su ficha de cliente.
- Diseño adaptable a móvil y computadora.\n- Panel de financieras para solicitar registro, configurar el portal público, publicar campañas y revisar solicitudes entrantes (según permisos de la cuenta).

## Tecnología
- HTML, CSS y JavaScript.
- Supabase Auth y PostgreSQL con Row Level Security (RLS).
- La clave publishable/anon usada en el navegador es una clave pública; nunca se debe colocar una clave `service_role` en el frontend.

## Enlace de cada financiera
Una vez creado y configurado el portal, el enlace tendrá este formato:

`https://TU-SITIO/?empresa=slug-de-la-financiera`

La base de datos crea automáticamente un registro de portal al registrar una financiera. El portal comienza sin publicar: primero debe verificarse/aprobarse la financiera y luego completar contacto y publicar el portal. El identificador del enlace incluye un sufijo para evitar duplicados de nombres.

## Importante
- Este repositorio contiene la primera interfaz del portal, no todo el sistema de operaciones de crédito.
- Las solicitudes recibidas desde la página son solicitudes preliminares, no créditos aprobados.
- La simulación es estimada y no reemplaza la evaluación, el contrato ni el cronograma definitivo.
- No se debe activar el acceso a créditos de un cliente hasta verificar su identidad y asociar su cuenta de Supabase al registro correcto.
- El repositorio incluye un flujo de GitHub Actions para publicar los archivos estáticos en GitHub Pages al actualizar `main`. Revisa la pestaña **Actions** y, cuando termine correctamente, la dirección publicada aparecerá en el registro del flujo. Si GitHub solicita habilitar Pages, ve a **Settings → Pages** y selecciona la publicación mediante GitHub Actions.\n- El panel de financieras está en `panel.html`. Las solicitudes de registro quedan en estado pendiente; el panel no permite autoaprobar una financiera.\n- La página individual de cada financiera debe configurarse y publicarse desde el panel después de que la cuenta tenga permisos.\n- El sistema completo de operaciones de préstamos (originación, evaluación, aprobación, desembolso, cobranzas, caja y reportes) aún requiere completar sus pantallas y pruebas; este portal/panel no debe considerarse todavía una solución financiera lista para producción.
