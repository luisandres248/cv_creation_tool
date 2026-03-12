#!/usr/bin/env python3
import argparse
import json
import re
from copy import deepcopy
from datetime import UTC, datetime
from pathlib import Path


LABELS = {
    "es": {
        "contact": "Contacto",
        "summary": "Perfil",
        "experience": "Experiencia",
        "skills": "Habilidades",
        "education": "Formación",
        "publications": "Publicaciones",
        "keywords": "Keywords objetivo",
    },
    "en": {
        "contact": "Contact",
        "summary": "Profile",
        "experience": "Experience",
        "skills": "Skills",
        "education": "Education",
        "publications": "Publications",
        "keywords": "Target keywords",
    },
}


def load_json(path: Path):
    with path.open("r", encoding="utf-8") as f:
        return json.load(f)


def month_label(period: dict, lang: str) -> str:
    months_es = {
        "01": "Ene", "02": "Feb", "03": "Mar", "04": "Abr", "05": "May", "06": "Jun",
        "07": "Jul", "08": "Ago", "09": "Sep", "10": "Oct", "11": "Nov", "12": "Dic",
    }
    months_en = {
        "01": "Jan", "02": "Feb", "03": "Mar", "04": "Apr", "05": "May", "06": "Jun",
        "07": "Jul", "08": "Aug", "09": "Sep", "10": "Oct", "11": "Nov", "12": "Dec",
    }
    months = months_es if lang == "es" else months_en

    def fmt(value: str) -> str:
        year, month = value.split("-")
        return f"{months[month]} {year}"

    start = fmt(period["start"])
    end = period["end"]
    if end == "present":
        end_label = "Actualidad" if lang == "es" else "Present"
    else:
        end_label = fmt(end)
    return f"{start} - {end_label}"


def normalize_text(text: str) -> str:
    return re.sub(r"\s+", " ", text).strip()


def typst_escape(text: str) -> str:
    return text.replace("@", "\\@")


def markdown_to_txt(md: str) -> str:
    txt = md
    txt = re.sub(r"^#{1,6}\s*", "", txt, flags=re.MULTILINE)
    txt = txt.replace("**", "")
    txt = txt.replace("`", "")
    txt = txt.replace("_", "")
    txt = re.sub(r"\n{3,}", "\n\n", txt)
    return txt.strip() + "\n"


def filter_items(items, variant_cfg):
    include_tags = set(variant_cfg.get("include_tags", []))
    if not include_tags:
        return items
    filtered = []
    for item in items:
        tags = set(item.get("tags", []))
        if not tags or tags & include_tags:
            filtered.append(item)
    return filtered or items


def apply_variant(base: dict, variant_cfg: dict) -> dict:
    cv = deepcopy(base)
    cv["_variant_title"] = variant_cfg["title"]
    cv["_keyword_focus"] = variant_cfg.get("keyword_focus", [])

    cv["experience"] = filter_items(cv["experience"], variant_cfg)
    for exp in cv["experience"]:
        exp["bullets"] = filter_items(exp.get("bullets", []), variant_cfg)

    cv["skills"] = filter_items(cv["skills"], variant_cfg)
    return cv


def render_markdown_single_lang(cv: dict, lang: str, variant_key: str) -> str:
    l = LABELS[lang]
    out = []

    out.append(f"# {cv['person']['name']}")
    out.append("")
    out.append(f"**{cv['person']['title'][lang]}**")
    out.append("")
    out.append(f"_{cv['_variant_title'][lang]}_")
    out.append("")

    out.append(f"## {l['contact']}")
    out.append(f"- {cv['contact']['email']}")
    out.append(f"- {cv['contact']['phone']}")
    out.append(f"- {cv['contact']['location'][lang]}")
    if cv["contact"].get("linkedin"):
        out.append(f"- {cv['contact']['linkedin']}")
    if cv["contact"].get("github"):
        out.append(f"- {cv['contact']['github']}")
    out.append("")

    out.append(f"## {l['summary']}")
    out.append(cv["summary"][lang])
    out.append("")

    if cv.get("_keyword_focus"):
        out.append(f"## {l['keywords']}")
        out.append(", ".join(cv["_keyword_focus"]))
        out.append("")

    out.append(f"## {l['experience']}")
    for exp in cv["experience"]:
        out.append(f"### {exp['role'][lang]}")
        out.append(f"**{exp['company']}** | {exp['location'][lang]} | {month_label(exp['period'], lang)}")
        for bullet in exp.get("bullets", []):
            out.append(f"- {normalize_text(bullet['text'][lang])}")
        out.append("")

    out.append(f"## {l['skills']}")
    for skill in cv["skills"]:
        items = ", ".join(skill["items"]) if skill.get("items") else ""
        out.append(f"- **{skill['name'][lang]}**: {items}")
    out.append("")

    out.append(f"## {l['education']}")
    for edu in cv["education"]:
        out.append(f"- **{edu['degree'][lang]}** - {edu['institution']} ({month_label(edu['period'], lang)})")
        if edu.get("notes"):
            out.append(f"  - {edu['notes'][lang]}")
    out.append("")

    if cv.get("publications"):
        out.append(f"## {l['publications']}")
        for pub in cv["publications"]:
            out.append(f"- {pub['citation'][lang]}")
            if pub.get("url"):
                out.append(f"  - {pub['url']}")
        out.append("")

    out.append(f"<!-- generated: {datetime.now(UTC).isoformat()} | lang={lang} | variant={variant_key} -->")
    out.append("")
    return "\n".join(out)


def render_markdown_bilingual(cv: dict, variant_key: str) -> str:
    es = render_markdown_single_lang(cv, "es", variant_key).strip()
    en = render_markdown_single_lang(cv, "en", variant_key).strip()
    return (
        "# CV Bilingue / Bilingual CV\n\n"
        "## ES\n\n"
        f"{es}\n\n"
        "---\n\n"
        "## EN\n\n"
        f"{en}\n"
    )


def render_typst_single_lang(cv: dict, lang: str, variant_key: str) -> str:
    lines = []
    lines.append("#set page(margin: 1.4cm)")
    lines.append("#set text(font: \"Liberation Sans\", size: 9.8pt)")
    lines.append("#set heading(numbering: none)")
    lines.append("")
    photo_path = cv.get("person", {}).get("photo_relpath", "").strip()
    if photo_path:
        lines.append(f"#align(right, image(\"{photo_path}\", width: 2.4cm))")
        lines.append("")
    lines.append(f"= {cv['person']['name']}")
    lines.append(f"*{cv['person']['title'][lang]}*")
    lines.append("")

    contact = [cv["contact"]["email"], cv["contact"]["phone"], cv["contact"]["location"][lang]]
    if cv["contact"].get("linkedin"):
        contact.append(cv["contact"]["linkedin"])
    lines.append(typst_escape(" | ".join(contact)))
    lines.append("")

    lines.append("== Summary" if lang == "en" else "== Perfil")
    lines.append(cv["summary"][lang])
    lines.append("")

    lines.append("== Experience" if lang == "en" else "== Experiencia")
    for exp in cv["experience"]:
        lines.append(f"=== {exp['role'][lang]}")
        lines.append(f"*{exp['company']}* | {exp['location'][lang]} | {month_label(exp['period'], lang)}")
        for bullet in exp.get("bullets", []):
            lines.append(f"- {normalize_text(bullet['text'][lang])}")
        lines.append("")

    lines.append("== Skills" if lang == "en" else "== Habilidades")
    for skill in cv["skills"]:
        lines.append(f"- *{skill['name'][lang]}*: {', '.join(skill['items'])}")
    lines.append("")

    lines.append("== Education" if lang == "en" else "== Formacion")
    for edu in cv["education"]:
        lines.append(f"- *{edu['degree'][lang]}* - {edu['institution']} ({month_label(edu['period'], lang)})")
    lines.append("")

    if cv.get("publications"):
        lines.append("== Publications" if lang == "en" else "== Publicaciones")
        for pub in cv["publications"]:
            lines.append(f"- {pub['citation'][lang]}")
            if pub.get("url"):
                lines.append(f"- {pub['url']}")
        lines.append("")

    lines.append(f"// generated lang={lang} variant={variant_key}")
    return "\n".join(lines) + "\n"


def render_typst_bilingual(cv: dict, variant_key: str) -> str:
    es = render_typst_single_lang(cv, "es", variant_key).strip()
    en = render_typst_single_lang(cv, "en", variant_key).strip()
    return f"{es}\n\n#pagebreak()\n\n{en}\n"


def main():
    parser = argparse.ArgumentParser(description="Build ATS-friendly CV variants")
    parser.add_argument("--data", default="data/cv_master.json")
    parser.add_argument("--variants", default="data/variants.json")
    parser.add_argument("--lang", choices=["es", "en", "bi", "all"], default="all")
    parser.add_argument("--variant", default="all")
    parser.add_argument("--out", default="build")
    args = parser.parse_args()

    base = load_json(Path(args.data))
    variants = load_json(Path(args.variants))

    if args.variant == "all":
        variant_keys = list(variants.keys())
    else:
        if args.variant not in variants:
            valid = ", ".join(variants.keys())
            raise SystemExit(f"Unknown variant '{args.variant}'. Valid: {valid}")
        variant_keys = [args.variant]

    langs = ["es", "en", "bi"] if args.lang == "all" else [args.lang]

    out_root = Path(args.out)
    out_root.mkdir(parents=True, exist_ok=True)

    for lang in langs:
        for variant_key in variant_keys:
            cv = apply_variant(base, variants[variant_key])

            if lang == "bi":
                md = render_markdown_bilingual(cv, variant_key)
                typ = render_typst_bilingual(cv, variant_key)
            else:
                md = render_markdown_single_lang(cv, lang, variant_key)
                typ = render_typst_single_lang(cv, lang, variant_key)

            txt = markdown_to_txt(md)

            target = out_root / lang / variant_key
            target.mkdir(parents=True, exist_ok=True)

            (target / "cv.md").write_text(md, encoding="utf-8")
            (target / "cv.txt").write_text(txt, encoding="utf-8")
            (target / "cv.typ").write_text(typ, encoding="utf-8")

    print(f"Generated CV variants in {out_root.resolve()}")


if __name__ == "__main__":
    main()
