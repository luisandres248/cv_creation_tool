#let months_es = (
  "01": "Ene",
  "02": "Feb",
  "03": "Mar",
  "04": "Abr",
  "05": "May",
  "06": "Jun",
  "07": "Jul",
  "08": "Ago",
  "09": "Sep",
  "10": "Oct",
  "11": "Nov",
  "12": "Dic",
)

#let months_en = (
  "01": "Jan",
  "02": "Feb",
  "03": "Mar",
  "04": "Apr",
  "05": "May",
  "06": "Jun",
  "07": "Jul",
  "08": "Aug",
  "09": "Sep",
  "10": "Oct",
  "11": "Nov",
  "12": "Dec",
)

#let palette = (
  "accent": rgb("1F9ED8"),
  "ink": rgb("14181F"),
  "body": rgb("222831"),
  "muted": rgb("5D6878"),
  "line": rgb("CBD4DF"),
)

#let labels(lang) = {
  if lang == "es" {
    (
      "summary": "Perfil",
      "keywords": "Palabras clave",
      "experience": "Experiencia",
      "skills": "Habilidades",
      "education": "Formacion",
      "publications": "Publicaciones",
      "links": "Links",
    )
  } else {
    (
      "summary": "Summary",
      "keywords": "Keywords",
      "experience": "Experience",
      "skills": "Skills",
      "education": "Education",
      "publications": "Publications",
      "links": "Links",
    )
  }
}

#let month_label(period, lang) = {
  let months = if lang == "es" { months_es } else { months_en }

  let start_parts = period.start.split("-")
  let start = months.at(start_parts.at(1)) + " " + start_parts.at(0)

  let end_label = if period.end == "present" {
    if lang == "es" { "Actualidad" } else { "Present" }
  } else {
    let end_parts = period.end.split("-")
    months.at(end_parts.at(1)) + " " + end_parts.at(0)
  }

  start + " - " + end_label
}

#let lang_keywords(cv, lang) = {
  if "keywords" in cv and lang in cv.keywords {
    cv.keywords.at(lang)
  } else {
    ()
  }
}

#let section_bar(title) = [
  #v(0.65em)
  #grid(
    columns: (auto, 1fr),
    column-gutter: 8pt,
    align: horizon,
    text(size: 10.2pt, weight: "semibold", fill: palette.at("accent"))[#title],
    line(length: 100%, stroke: 0.55pt + palette.at("line")),
  )
  #v(0.28em)
]

#let photo_circle(path) = box(
  width: 2.85cm,
  height: 2.85cm,
  radius: 50%,
  inset: 0pt,
  clip: true,
  stroke: 1.1pt + palette.at("accent"),
  image(path, width: 2.85cm, height: 2.85cm, fit: "cover"),
)

#let links_line(cv, l) = {
  let links = ()

  if "linkedin" in cv.contact and cv.contact.linkedin != "" {
    links.push(link(cv.contact.linkedin)["LinkedIn"])
  }

  if "github" in cv.contact and cv.contact.github != "" {
    links.push(link(cv.contact.github)["GitHub"])
  }

  if links.len() > 0 {
    [
      #text(size: 8.8pt, fill: palette.at("muted"))[#(l.at("links") + ": ")]
      #text(size: 8.8pt, fill: palette.at("accent"))[#links.join(" | ")]
    ]
  } else {
    []
  }
}

#let contact_line(cv, lang) = {
  let base = (
    link("mailto:" + cv.contact.email)[cv.contact.email],
    cv.contact.phone,
    cv.contact.location.at(lang),
  )
  base.join(" | ")
}

#let render_lang(cv, lang, photo_path) = {
  let l = labels(lang)
  let kws = lang_keywords(cv, lang)

  [
    #set page(margin: (x: 1.55cm, y: 1.35cm))
    #set text(font: "Liberation Sans", size: 9.9pt, fill: palette.at("body"))
    #set par(leading: 0.62em)
    #set heading(numbering: none)

    #grid(
      columns: (auto, 1fr),
      column-gutter: 12pt,
      align: top,
      [#photo_circle(photo_path)],
      [
        #text(size: 21pt, weight: "bold", fill: palette.at("ink"))[#cv.person.name]
        #v(0.12em)
        #text(size: 10.8pt, weight: "medium", fill: palette.at("body"))[#cv.person.title.at(lang)]
        #v(0.3em)
        #text(size: 8.9pt, fill: palette.at("muted"))[#contact_line(cv, lang)]
        #v(0.08em)
        #links_line(cv, l)
      ],
    )

    #section_bar(l.at("summary"))
    #cv.summary.at(lang)

    #if kws.len() > 0 [
      #section_bar(l.at("keywords"))
      #text(size: 9.2pt, fill: palette.at("body"))[#kws.join(" | ")]
    ]

    #section_bar(l.at("experience"))
    #for exp in cv.experience [
      #text(size: 10pt, weight: "semibold", fill: palette.at("ink"))[#exp.role.at(lang)]
      #text(size: 9.05pt, fill: palette.at("muted"))[*#exp.company* | #exp.location.at(lang) | #month_label(exp.period, lang)]
      #v(0.14em)
      #for bullet in exp.bullets [
        - #bullet.text.at(lang)
      ]
      #v(0.27em)
    ]

    #section_bar(l.at("skills"))
    #for skill in cv.skills [
      #grid(
        columns: (2.75cm, 1fr),
        column-gutter: 7pt,
        align: horizon,
        text(weight: "semibold", fill: palette.at("ink"))[#skill.name.at(lang)],
        text(fill: palette.at("body"))[#skill.items.join(" | ")],
      )
      #v(0.12em)
    ]

    #section_bar(l.at("education"))
    #for edu in cv.education [
      - *#edu.degree.at(lang)* - #edu.institution (#month_label(edu.period, lang))
      #if "notes" in edu [
        - #edu.notes.at(lang)
      ]
      #v(0.16em)
    ]

    #if "publications" in cv and cv.publications.len() > 0 [
      #section_bar(l.at("publications"))
      #for pub in cv.publications [
        - #pub.citation.at(lang)
        #if "url" in pub and pub.url != "" [
          - #link(pub.url)[#pub.url]
        ]
      ]
    ]
  ]
}

#let render(profile_path, lang: "bi") = {
  let cv = json(profile_path + "/cv.json")
  let photo_path = profile_path + "/photo.jpg"

  if lang == "bi" {
    [
      #render_lang(cv, "es", photo_path)
      #pagebreak()
      #render_lang(cv, "en", photo_path)
    ]
  } else {
    render_lang(cv, lang, photo_path)
  }
}
