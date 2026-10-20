# Shardot — Soul Shards & Combo Points

Versión 0.6.0. Destino: WoW Forever 1.60.1, Interface 16001.
Implementado íntegramente en Lua, sin dependencias.

Incluye `Media/ShardotIcon.tga`, el icono propio configurado en el manifiesto para
la lista de addons del juego. El panel de apoyo conserva su tamaño compacto con
un fondo tenue y acentos violetas para mejorar su visibilidad.

## Instalación

Con WoW cerrado, extraer el ZIP dentro de `Interface/AddOns` de la instalación
de Forever. Debe quedar `Interface/AddOns/Shardot/Shardot.toc`.
Activar **Shardot** en la lista de addons del personaje.

Si venís de Forever Resources, desactivá o retirá su carpeta anterior antes de
activar Shardot para evitar dos indicadores. La carpeta, los archivos, los comandos
y las variables guardadas ahora usan Shardot. Esta instalación crea un perfil nuevo;
los ajustes anteriores no se importan automáticamente.

## Recursos

- Brujo: cantidad de Soul Shards (objeto 6265) en las bolsas, incluidas bolsas de almas.
  Excluye banco, banco de componentes y banco de cuenta.
- Pícaro: puntos de combo sobre el objetivo actual.
- Druida: puntos de combo en forma felina; se oculta en otras formas.
- Otras clases: no muestra recursos. `/shardot test` permite previsualizar el diseño.

Rogue y druida pueden mostrar cinco segmentos sobre la nameplate del objetivo actual.
La pestaña **Nameplate** permite activarlos, ubicarlos arriba o abajo y ajustar sus
offsets X/Y y escala. Reutilizan la forma, separación, borde y colores del indicador
principal. Requiere nameplates activadas y un objetivo visible.

Shards: contador numérico y barra horizontal opcional, o icono del objeto con el
contador superpuesto en la esquina inferior derecha. Combos: cinco segmentos que
se rellenan individualmente, con número opcional. La barra de shards representa un objetivo
configurable, inicialmente 20; no representa capacidad libre de bolsas. El número
siempre muestra el total, aunque supere ese objetivo. Los combos muestran cinco puntos
fijos para rogue y feral. No incluye mana, energía, ira, cooldowns ni alertas.

## Personalización

Para el contador de shards, `/shardot` incluye **Fuente del contador** (clic para alternar
entre predeterminada, Arial, Morpheus y Skurri) y **Color del número (RRGGBB)**.
Ingresar seis dígitos y pulsar Aplicar o Enter. El color del número es independiente
de la barra; por defecto es blanco. Se aplica tanto sobre el icono como al contador
sin icono. Las fuentes son del cliente, sin descargas ni librerías adicionales.

Por defecto: sin fondo ni etiqueta, con segmentos cuadrados de borde fino e interior
oscuro. Los segmentos usan colores sólidos, sin estirar texturas decorativas.
Al actualizar a 0.4.0 se seleccionan cuadrados con separación de 2; después se respetan
los ajustes. Al actualizar desde una versión anterior a 0.3 se desactivan fondo
y etiqueta una sola vez; después se respetan los cambios del panel.

En combos, **Estilo** permite elegir segmentos cuadrados/rectangulares o círculos.
La separación puede ser cero para unir los segmentos. Se puede cambiar ancho,
alto/diámetro, grosor y color del borde, reflejo y color de los segmentos vacíos.
**Dorado → rojo por combos** cambia todos los puntos encendidos de dorado a rojo según el
total de combos. Si WoW restringe el valor en combate, se usa un color fijo por
posición (primero dorado, último rojo), sin inspeccionar valores secretos.
Aplicar un color hexadecimal desactiva la progresión y utiliza ese color fijo.
Tamaño, separación, opacidad y vista previa siguen disponibles en `/shardot`.

`/shardot` abre el panel de configuración con casillas marcadas al activar una opción.
Se puede hacer clic en toda la fila, incluida su etiqueta. Incluye tres pestañas:

- **General:** visibilidad, posición, escala, opacidad y prueba de cero a cinco combos.
  Al final aparece una fila discreta para apoyar el desarrollo por PayPal.
- **Diseño:** forma, ancho, alto, separación, borde y reflejo; para brujo, icono,
  barra, objetivo y fuente del contador.
- **Colores:** muestras de color y campos hexadecimales para relleno, vacío y borde;
  para brujo, barra y texto independientes. Aplicar con el botón o Enter.

En **Apoyar el desarrollo / Support development**, pulsar **PayPal** para mostrar y seleccionar el enlace,
copiarlo con Ctrl+C (Cmd+C en Mac) y abrirlo en el navegador:
https://www.paypal.com/paypalme/sebiten

Los cambios se aplican al momento. Restablecer todo requiere un segundo clic.
El panel se puede arrastrar desde su encabezado y se ajusta a pantallas más pequeñas.
La opción **Icono con contador** cambia la presentación de shards. Para mostrar solo
el icono con el número, desactivar fondo, etiqueta y barra. La escala ajusta su tamaño.
Cerrar el panel desactiva la vista previa. El panel se crea solo al abrirlo.

| Comando | Acción |
| --- | --- |
| `/shardot` o `/shardot config` | Panel de configuración |
| `/shardot help` | Ayuda de comandos |
| `/shardot unlock` | Permite arrastrar con clic izquierdo |
| `/shardot lock` | Bloquea posición y termina la previsualización |
| `/shardot test` | Activa/desactiva valores de ejemplo |
| `/shardot scale 1.2` | Escala entre 0.5 y 3 |
| `/shardot alpha 0.8` | Opacidad entre 0.1 y 1 |
| `/shardot color A970FF` | Color fijo del combo o barra de shards; texto de shards independiente |
| `/shardot color default` | Restaura color por recurso |
| `/shardot bar off` | Oculta la barra; `on` la muestra |
| `/shardot icon on` | Muestra shards como icono con contador; `off` vuelve al número |
| `/shardot label off` | Oculta la etiqueta; `on` la muestra |
| `/shardot background off` | Oculta fondo; `on` lo muestra |
| `/shardot hidezero on` | Oculta al llegar a cero; `off` siempre muestra |
| `/shardot goal 30` | Objetivo visual de shards, entre 1 y 200 |
| `/shardot reset` | Restaura opciones y posición |

Comando principal: `/shardot`. Alias corto: `/sd`. Opciones guardadas por personaje mediante
SavedVariablesPerCharacter. La persistencia depende del soporte del cliente beta.
Durante desbloqueo no se aplica ocultar al llegar a cero. El fondo puede desactivarse
también al mover el indicador; el área del indicador sigue permitiendo arrastrarlo.

## Rendimiento y restricciones

Actualizaciones por eventos, sin OnUpdate, polling, timers, escaneo de slots,
combat log ni librerías. El brujo consulta el contador nativo tras BAG_UPDATE_DELAYED;
los usuarios de combo solo escuchan eventos relevantes del jugador y del objetivo.
Los elementos visuales se crean una sola vez. Los valores públicos que no cambian
no provocan un nuevo repintado. Los combos no consultan el máximo en cada evento:
cada segmento usa una barra nativa con un intervalo fijo de un punto. Solo los círculos
usan máscaras; cambiar de forma reutiliza los elementos existentes.

Los valores secretos se envían directamente a los controles nativos; no se comparan
ni convierten en Lua. Si el cliente restringe el valor, ocultar al llegar a cero
no se aplica. No se intenta eludir las restricciones del cliente.

## Prueba dentro de WoW

Esta versión requiere validación real en Forever; no se ha ejecutado dentro del juego.

1. `/shardot`: activar vista previa, quitar fondo, desbloquear, mover y cambiar escala.
   Probar cada valor de cero a cinco: deben verse exactamente tantos segmentos llenos.
   Alternar cuadrados y círculos varias veces. Probar separación cero, borde 0 y 3,
   ancho/alto mínimo y máximo, colores y número opcional. Cerrar: vuelve al valor real.
2. Brujo: crear, consumir y mover shards entre bolsas; depositar y retirar del banco.
   Verificar que solo cuenta los que lleva el personaje y que incluye bolsas de almas.
3. Pícaro: generar y gastar puntos; cambiar o perder objetivo, dentro y fuera de combate.
4. Druida: repetir en gato y cambiar a oso / humano; comprobar visibilidad.
5. Probar `hidezero`, cambiar escala después de mover y hacer `/reload` para comprobar guardado.
6. Para reportar un problema: habilitar `/console scriptErrors 1`, reproducirlo y
   copiar el error junto al resultado de `/dump {GetBuildInfo()}`.

La interfaz 16001 es el objetivo de este paquete. Si tu cliente tiene otra versión,
comunica GetBuildInfo antes de asumir compatibilidad por marcar “addons antiguos”.
