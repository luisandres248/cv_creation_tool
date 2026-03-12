# CV Pipeline (programmatically friendly)

Pipeline simple para mantener un CV editable, versionable y ATS-friendly desde una fuente de datos única.

## Estructura

- `data/cv_master.json`: contenido base (ES + EN)
- `data/variants.json`: reglas por variante (actualmente `industrial_data`)
- `scripts/build_cv.py`: generador de salidas
- `build/<lang>/<variant>/cv.{md,txt,typ}`: artefactos generados

`<lang>` puede ser:
- `es`: solo español
- `en`: solo inglés
- `bi`: bilingue (ES+EN en un solo documento)

## Uso

```bash
make build
```

Comandos útiles:

```bash
make build-es
make build-en
make build-bi
make pdf-bi
```

Manual:

```bash
python3 scripts/build_cv.py --lang bi --variant industrial_data
```

## Objetivo ATS/IA

- contenido en texto plano estructurado
- formato de una columna
- secciones estándar
- variantes reproducibles por comando
- salida `cv.txt` para formularios de postulación

## Edición recomendada

1. Editar `data/cv_master.json`
2. Ajustar keywords/filtrado en `data/variants.json`
3. Ejecutar `make build`
4. Revisar `build/bi/industrial_data/cv.md` y `cv.pdf`
