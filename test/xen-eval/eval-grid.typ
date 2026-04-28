// imported from burg/doksem at 2026-03

#import "@preview/cetz:0.3.4": *

#set align(center + top)

#let autosar = rgb("#F8CECC")
#let zephyr = rgb("#DAE8FC")
#let android = rgb("#D5E8D4")
#let autosar_stroke = rgb("#B85450")
#let zephyr_stroke = rgb("#6C8EBF")
#let android_stroke = rgb("#82B366")

#set text(font: "Nimbus Sans")

// path is given as command line paramater
#let data = sys.inputs.path + "/HyperSSE."
#let svgs = (
  "min-autosar.hstg.svg",
  "min-zephyr.hstg.svg",
  "min-baremetal.hstg.svg",
  "min-az.hstg.svg",
  "min-zb.hstg.svg",
  "min-ba.hstg.svg",
  "hc-autosar.hstg.svg",
  "hc-zephyr.hstg.svg",
  "hc-baremetal.hstg.svg",
  "hc-autosar2.hstg.svg",
  "hc-zephyr2.hstg.svg",
  "hc-baremetal2.hstg.svg",
  "hc-a-z1.hstg.svg",
  "hc-z-b1.hstg.svg",
  "hc-b-a1.hstg.svg",
  "hc-a-z2.hstg.svg",
  "hc-z-b2.hstg.svg",
  "hc-b-a2.hstg.svg",
  //
  "shamem-autosar-ro.hstg.svg",
  "shamem-autosar-raw.hstg.svg",
  "shamem-autosar-war.hstg.svg",
  "shamem-autosar-unknown.hstg.svg",
  //
  "hc-autosar-notiming.hstg.svg",
  "hc-zephyr-notiming.hstg.svg",
  "hc-baremetal-notiming.hstg.svg",
  "hc-autosar-polled.hstg.svg",
  "pingpong.hstg.svg",
  "channels.hstg.svg",
  "many.hstg.svg",
  "sendrecv-a.hstg.svg",
  "sendrecv-b.hstg.svg",
  //
  "brakingNoCheck.hstg.svg",
  "brakingNoCheckSlowZ.hstg.svg",
  "brakingUnrolled.hstg.svg",
  "brakingUnrolledSlowZ.hstg.svg",
)

// from https://github.com/typst/typst/issues/2025#issuecomment-2500136936
#let maybe-image(path, ..args) = context {
  let path-label = label(path)
  let first-time = query((context {}).func()).len() == 0
  if first-time or query(path-label).len() > 0 {
    [#image(path, ..args)#path-label]
  } else {
    [No File!\ #path]
  }
}

#set enum(numbering: "a)")
#let vimg(i, body, height, relative_path, do_lable) = {
  set par(spacing: 0.4em)
  if do_lable [
    #text(size: 0.7em, weight: "bold")[#numbering("(a)", i) #body.split(".").at(0)]
  ]
  rect(width: 100%, height: height, inset: 1pt)[
    // typst svg render does not scale the rectangles properly, therefore the text runs into the right wall
    // in other svg viewer it looks good
    #if relative_path [
      #maybe-image("../" + body)
    ] else [
      #maybe-image(data + body)
    ]
  ]
}

#let relative_path = false
#let do_lable = true
#let height = 30mm
#let row-gutter = 10pt
#let a4w = 210mm
#set page(width: a4w, height: auto, margin: (x: 3mm, y: 3mm))

#set align(center)
#canvas({
  import draw: *

  let y = 0.5
  let pad = 0.1
  let x_space = 0.5
  let radius = (y - 2 * pad) / 2
  content(
    (0, 0),
    (15.9, y),
    box(
      [#set par(justify: false, leading: 0.4em)
        #set align(center + horizon)
        #set text(size: 0.8em)
        // this does not work inside a tyst box, because after rect is always a new paragraph
        // #rect(height: 1.2em)[Dom A |Dom B]: Synchronizationpoint

        // #text(size: 0.8em, black, weight: "extrabold")[#sym.rect.stroked.h]:Synchronizationpoint
      ],
      radius: 3pt,
      stroke: 0.5pt,
      width: 100%,
      height: 100%,
      inset: 0.2em,
    ),
    name: "root",
  )
  rect((rel: (pad, 0 + pad), to: "root.south-west"), (1, y - pad), name: "dom")
  line("dom.north", "dom.south")
  content("dom.east", anchor: "mid-west", padding: .1, text(size: 0.7em)[Synchronization Point], name: "sp")
  circle((rel: (x_space, 0), to: "sp.mid-east"), radius: (radius, radius * 0.66), stroke: rgb("#008000"), name: "abb")
  content("abb.east", anchor: "mid-west", padding: .1, text(size: 0.7em)[ABB], name: "abb_text")
  rect(
    (rel: (x_space, 0 - y / 2 + pad), to: "abb_text.east"),
    (rel: (x_space * 2.5, 0 + y / 2 - pad), to: "abb_text.east"),
    stroke: rgb("#6495ed"),
    name: "syscall",
  )
  content("syscall.east", anchor: "mid-west", padding: .1, text(size: 0.7em)[Syscall], name: "syscall_text")
  circle(
    (rel: (x_space, 0), to: "syscall_text.mid-east"),
    radius: (radius, radius * 0.66),
    stroke: rgb("#ee82ee"),
    name: "idle",
  )
  content("idle.east", anchor: "mid-west", padding: .1, text(size: 0.7em)[Idle State], name: "idle_text")
  rect(
    (rel: (x_space, 0 - y / 2 + pad), to: "idle_text.east"),
    (rel: (x_space * 2, 0 + y / 2 - pad), to: "idle_text.east"),
    fill: rgb("#F8CECC"),
    name: "autosar",
  )
  rect(
    (rel: (0, 0 - y / 2 + pad), to: "autosar.east"),
    (rel: (x_space, 0 + y / 2 - pad), to: "autosar.east"),
    fill: rgb("#DAE8FC"),
    name: "zephyr",
  )
  rect(
    (rel: (0, 0 - y / 2 + pad), to: "zephyr.east"),
    (rel: (x_space, 0 + y / 2 - pad), to: "zephyr.east"),
    fill: rgb("#D5E8D4"),
    name: "andriod",
  )
  content(
    "andriod.east",
    anchor: "mid-west",
    padding: .1,
    text(size: 0.7em)[Autosar/Zephyr/Bare-Metal System],
    name: "os-text",
  )
})

#v(-0.25cm)
#grid(
  columns: 6,
  column-gutter: 3pt,
  row-gutter: row-gutter,
  align: center + horizon,
  ..svgs.slice(0, 18).enumerate(start: 1).map(((i, b)) => vimg(i, b, height, relative_path, do_lable))
)
#grid(
  columns: 4,
  column-gutter: 3pt,
  row-gutter: row-gutter,
  align: center + horizon,
  ..svgs.slice(18, 18+4).enumerate(start: 18).map(((i, b)) => vimg(i, b, height, relative_path, do_lable))
)

#grid(
  columns: 3,
  column-gutter: 3pt,
  row-gutter: row-gutter,
  align: center + horizon,
  ..svgs.slice(18+4, 27+4).enumerate(start: 18+4).map(((i, b)) => vimg(i, b, height, relative_path, do_lable))
)

#grid(
  columns: 2,
  column-gutter: 3pt,
  row-gutter: row-gutter,
  align: center + horizon,
  ..svgs.slice(27+4, 31+4).enumerate(start: 28+4).map(((i, b)) => vimg(i, b, 2 * height, relative_path, do_lable))
)
