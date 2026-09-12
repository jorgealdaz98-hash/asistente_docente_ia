# Asistente Docente IA (EDUAI DOCENTE)

App Flutter multiplataforma (foco en Windows escritorio) para docentes:
pase de lista inteligente por voz, métricas del aula, notas y un asistente
pedagógico con IA. Incluye sistema de licenciamiento (HWID + AES-256).

## ⚠️ Antes de compilar: por qué no vienen las carpetas `windows/`, `android/`, etc.

Este paquete contiene todo el **código fuente Dart** de la app (`lib/`),
completo y funcional, pero **no incluye las carpetas nativas de cada
plataforma** (`windows/`, `android/`, `linux/`, etc.). Esas carpetas las
genera automáticamente el propio Flutter SDK con `flutter create`, y no se
pueden preparar a mano de forma confiable sin tener el SDK instalado y
sin saber tu versión exacta de Flutter/Visual Studio.

Esto se resuelve en **un solo paso**, en tu máquina con Flutter instalado:

```bash
# 1) Descomprime este zip, entra a la carpeta
cd asistente_docente_ia

# 2) Genera las carpetas nativas necesarias (Windows en este caso)
flutter create --platforms=windows .

# 3) Instala las dependencias
flutter pub get

# 4) Ejecuta
flutter run -d windows
```

Si además quieres Android/Linux/macOS más adelante:
```bash
flutter create --platforms=windows,android,linux,macos .
```

### Requisitos en tu equipo Windows
- Flutter SDK instalado y `flutter doctor` sin errores para Windows
  (necesita Visual Studio 2022 con la carga de trabajo "Desarrollo de
  escritorio con C++").

## Estructura del proyecto

```
lib/
  core/
    theme/app_theme.dart        # Colores/tipografía tomados del diseño Stitch
    database/database_helper.dart  # SQLite (sqflite_common_ffi) para escritorio
  models/                        # Curso, Alumno, RegistroAsistencia, Calificacion
  repositories/                  # Acceso a datos (CRUD) por entidad
  services/
    license_service.dart         # HWID + licencia AES-256
    ai_service.dart               # Claude / OpenAI / Gemini (intercambiables)
    voice_service.dart            # speech_to_text + flutter_tts (locales)
  providers/                      # Estado (provider/ChangeNotifier)
  screens/                        # Inicio, Cursos, Alumnos, Asistencia, Notas, Ajustes, Licencia
  widgets/                        # Componentes reutilizables (roll card, chat IA, nav, etc.)
  main.dart                       # Arranque: DB, providers, chequeo de licencia

tools/license_generator/
  generar_licencia.dart          # Script tuyo (admin) para emitir licencias
```

## Configurar el Asistente Pedagógico IA

En **Ajustes**, dentro de la app, el docente elige el proveedor (Claude,
OpenAI o Gemini) y pega su propia API key. Cada proveedor se llama por
HTTP directo (`lib/services/ai_service.dart`), así que puedes agregar
otro proveedor implementando la interfaz `AiService` sin tocar el resto
de la app.

El reconocimiento y síntesis de voz del pase de lista (`voice_service.dart`)
son **100% locales** (usan el motor de voz del sistema operativo vía
`speech_to_text` y `flutter_tts`): no consumen la API de IA ni requieren
internet.

## Sistema de licencias

- Al primer arranque, la app muestra el **HWID** (huella del equipo) en
  la pantalla de activación.
- Tú generas la clave de licencia para ese HWID con el script:
  ```bash
  dart run tools/license_generator/generar_licencia.dart <HWID> <dias_validez>
  ```
  (ejecútalo desde la raíz del proyecto, después de `flutter pub get`,
  para que resuelva los paquetes `encrypt`/`crypto`).
- Le envías esa clave al docente y la pega en la pantalla de activación.

**Antes de distribuir la app**, cambia la constante `_claveSecreta` en
AMBOS archivos (deben quedar idénticas):
- `lib/services/license_service.dart`
- `tools/license_generator/generar_licencia.dart`

Debe medir exactamente 32 caracteres (AES-256). El `IV` (`EDUAI_IV_16BYTES`)
también debe coincidir en ambos archivos si decides cambiarlo (debe medir
16 caracteres).

## Notas de diseño

Los colores, tipografía (Plus Jakarta Sans) y estilos de componentes
(botones, chips, tarjetas) siguen el `DESIGN.md` de la maqueta Stitch que
generaste, adaptados a Flutter en `lib/core/theme/app_theme.dart`. Si
tienes la fuente Plus Jakarta Sans en `.ttf`, agrégala a `pubspec.yaml`
(sección `fonts:`) para que se use exactamente igual que en la maqueta;
si no, la app usa la fuente por defecto del sistema sin romper nada.

## Próximos pasos sugeridos

1. `flutter create --platforms=windows .` + `flutter pub get` + `flutter run -d windows`
2. Cambiar la clave secreta de licencias antes de distribuir
3. Configurar tu API key de IA en Ajustes para probar el asistente pedagógico
4. Cargar un curso y algunos alumnos de prueba, y probar el pase de lista por voz
