# cv-pipeline

Genera `cv.typ` y `cv.pdf` para uno o varios perfiles usando Typst.

## Dependencia obligatoria

- `typst` en `PATH`

## Estructura

- `profiles/` -> datos reales (privado, ignorado por git)
- `profiles.example/` -> ejemplos con la misma estructura (comiteable)
- `templates/cv.typ` -> plantilla Typst editable
- `generated/` -> salida (`cv.typ`, `cv.pdf`)
- `scripts/build.sh` -> build de perfiles
- `scripts/init_profiles.sh` -> copia `profiles.example` a `profiles`

## Formato de cada perfil

Cada perfil es un directorio dentro de `profiles/`:

- `profiles/<perfil>/cv.json`
- `profiles/<perfil>/photo.jpg`

`photo.jpg` es obligatoria y siempre con ese nombre.

## Inicio rapido

```bash
./scripts/init_profiles.sh
```

Editar datos en `profiles/<perfil>/cv.json` y reemplazar `profiles/<perfil>/photo.jpg`.

Para mantener el CV compacto, la plantilla no renderiza una seccion separada de `publications`.
Si quieres mostrar una publicacion, agregala como un item dentro de `education[].details` usando `text`, `url` y `label`.

## Build

Todos los perfiles, bilingue:

```bash
./scripts/build.sh
```

Un perfil:

```bash
./scripts/build.sh data_engineer
```

Un perfil + idioma:

```bash
./scripts/build.sh data_engineer es
```

Idiomas: `es`, `en`, `bi`, `all`.

## Salida

Para cada perfil en `generated/<perfil>/`:

- `cv.typ` y `cv.pdf` si `lang=bi`
- `cv-es.typ` / `cv-es.pdf` si `lang=es`
- `cv-en.typ` / `cv-en.pdf` si `lang=en`

## Personalizacion visual

Modificar `templates/cv.typ`. La estructura/estilo del PDF se define ahi.
