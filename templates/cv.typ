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
      "experience": "Experiencia",
      "skills": "Habilidades",
      "additional": "Otras habilidades y experiencias",
      "education": "Formacion",
      "publications": "Publicaciones",
      "links": "Links",
    )
  } else {
    (
      "summary": "Summary",
      "experience": "Experience",
      "skills": "Skills",
      "additional": "Additional Experience & Skills",
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

#let localized_item(item, lang) = {
  if type(item) == dictionary and lang in item {
    item.at(lang)
  } else {
    item
  }
}

#let skill_text(item, lang) = {
  if type(item) == dictionary {
    if "label" in item {
      localized_item(item.label, lang)
    } else if "name" in item {
      localized_item(item.name, lang)
    } else if lang in item {
      item.at(lang)
    } else if "key" in item {
      item.key
    } else {
      ""
    }
  } else {
    localized_item(item, lang)
  }
}

#let skill_category_label(skill, lang) = {
  if "short" in skill {
    localized_item(skill.short, lang)
  } else {
    localized_item(skill.name, lang)
  }
}

#let skill_items_line(skill, lang) = {
  skill.items.map(item => skill_text(item, lang)).join(" · ")
}

#let skill_group(skill, lang) = [
  #grid(
    columns: (2.9cm, 1fr),
    column-gutter: 8pt,
    align: top,
    text(size: 8.15pt, weight: "semibold", fill: palette.at("muted"))[#skill_category_label(skill, lang)],
    text(size: 8.5pt, fill: palette.at("body"))[#skill_items_line(skill, lang)],
  )
]

#let render_detail(detail, lang) = {
  if type(detail) == dictionary and "text" in detail {
    [
      #(detail.text.at(lang))
      #if "url" in detail and detail.url != "" [
        #text(fill: palette.at("accent"))[ #link(detail.url)[#if "label" in detail { detail.label.at(lang) } else { detail.url }] ]
      ]
    ]
  } else if type(detail) == dictionary and lang in detail {
    detail.at(lang)
  } else {
    detail
  }
}

#let section_bar(title) = [
  #v(0.45em)
  #grid(
    columns: (auto, 1fr),
    column-gutter: 6pt,
    align: horizon,
    text(size: 9.8pt, weight: "semibold", fill: palette.at("accent"))[#title],
    line(length: 100%, stroke: 0.45pt + palette.at("line")),
  )
  #v(0.18em)
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

#let links_line(cv) = {
  let links = ()

  if "linkedin" in cv.contact and cv.contact.linkedin != "" {
    links.push(link(cv.contact.linkedin)[LinkedIn])
  }

  if "github" in cv.contact and cv.contact.github != "" {
    links.push(link(cv.contact.github)[GitHub])
  }

  if "links" in cv.contact {
    for item in cv.contact.links {
      if "label" in item and "url" in item and item.url != "" {
        links.push(link(item.url)[item.label])
      }
    }
  }

  if links.len() > 0 {
    [#text(size: 8.8pt, fill: palette.at("accent"))[#links.join(" | ")]]
  } else {
    []
  }
}

#let contact_line(cv, lang) = {
  let base = (
    cv.contact.email,
    cv.contact.phone,
    cv.contact.location.at(lang),
  )
  base.join(" | ")
}

#let render_lang(cv, lang, photo_path) = {
  let l = labels(lang)

  [
    #set page(margin: (x: 1.3cm, y: 1.1cm))
    #set text(font: "Liberation Sans", size: 9.35pt, fill: palette.at("body"))
    #set par(leading: 0.52em)
    #set heading(numbering: none)

    #grid(
      columns: (auto, 1fr),
      column-gutter: 10pt,
      align: top,
      [#photo_circle(photo_path)],
      [
        #text(size: 19pt, weight: "bold", fill: palette.at("ink"))[#cv.person.name]
        #v(0.08em)
        #text(size: 10pt, weight: "medium", fill: palette.at("body"))[#cv.person.title.at(lang)]
        #if "subtitle" in cv.person [
          #v(0.1em)
          #text(size: 8.8pt, fill: palette.at("accent"))[#cv.person.subtitle.at(lang)]
        ]
        #v(0.18em)
        #text(size: 8.3pt, fill: palette.at("muted"))[#contact_line(cv, lang)]
        #v(0.04em)
        #links_line(cv)
      ],
    )

    #section_bar(l.at("summary"))
    #cv.summary.at(lang)

    #section_bar(l.at("experience"))
    #for exp in cv.experience [
      #text(size: 9.5pt, weight: "semibold", fill: palette.at("ink"))[#exp.role.at(lang)]
      #text(size: 8.55pt, fill: palette.at("muted"))[*#exp.company* | #exp.location.at(lang) | #month_label(exp.period, lang)]
      #v(0.08em)
      #for bullet in exp.bullets [
        - #bullet.text.at(lang)
      ]
      #v(0.16em)
    ]

    #section_bar(l.at("skills"))
    #for skill in cv.skills [
      #skill_group(skill, lang)
      #v(0.22em)
    ]

    #if "additional" in cv and cv.additional.len() > 0 [
      #section_bar(l.at("additional"))
      #for item in cv.additional [
        - *#item.title.at(lang)*: #item.text.at(lang)
        #v(0.12em)
      ]
    ]

    #section_bar(l.at("education"))
    #for edu in cv.education [
      - *#edu.degree.at(lang)* - #edu.institution (#month_label(edu.period, lang))#if "status" in edu { " - " + edu.status.at(lang) }
      #if "details" in edu [
        #for detail in edu.details [
          - #render_detail(detail, lang)
        ]
      ] else if "notes" in edu [
        - #edu.notes.at(lang)
      ]
      #v(0.08em)
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
