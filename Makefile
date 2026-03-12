.PHONY: build build-es build-en build-bi clean pdf-bi

build:
	python3 scripts/build_cv.py --lang bi --variant industrial_data

build-es:
	python3 scripts/build_cv.py --lang es --variant industrial_data

build-en:
	python3 scripts/build_cv.py --lang en --variant industrial_data

build-bi:
	python3 scripts/build_cv.py --lang bi --variant industrial_data

pdf-bi: build-bi
	typst compile --root . build/bi/industrial_data/cv.typ build/bi/industrial_data/cv.pdf

clean:
	rm -rf build
