#import "@preview/cetz:0.3.4": *

#let w = 40mm
#let a4w = 210mm
#set page(width: a4w, height: auto, margin: (x: 0.5mm, y: 1mm))

#let autosar = rgb("#F8CECC")
#let zephyr = rgb("#DAE8FC")
#let android = rgb("#D5E8D4")
#let autosar_stroke = rgb("#B85450")
#let zephyr_stroke = rgb("#6C8EBF")
#let android_stroke = rgb("#82B366")

#set text(font: "Nimbus Sans")

#let cols = 6 // 3 or 4 or 5 or 6
// #let thing = "MCAnalyzer"
#let thing = "HyperSSE"

#let round = "" // "-0"
#let data = sys.inputs.path + "/" + thing + "."

#let svgs = (
  data + "min-autosar.hstg.svg",
  data + "min-zephyr.hstg.svg",
  data + "min-baremetal.hstg.svg",
  data + "min-az.hstg.svg",
  data + "min-zb.hstg.svg",
  data + "min-ba.hstg.svg",
  data + "hc-autosar.hstg.svg",
  data + "hc-zephyr.hstg.svg",
  data + "hc-baremetal.hstg.svg",
  data + "hc-autosar2.hstg.svg",
  data + "hc-zephyr2.hstg.svg",
  data + "hc-baremetal2.hstg.svg",
  data + "hc-a-z1.hstg.svg",
  data + "hc-z-b1.hstg.svg",
  data + "hc-b-a1.hstg.svg",
  data + "hc-a-z2.hstg.svg",
  data + "hc-z-b2.hstg.svg",
  data + "hc-b-a2.hstg.svg",
  data + "hc-autosar-notiming.hstg.svg",
  data + "hc-zephyr-notiming.hstg.svg",
  data + "hc-baremetal-notiming.hstg.svg",
  data + "hc-autosar-polled.hstg.svg",
  data + "pingpong.hstg.svg",
  data + "channels.hstg.svg",
  //
  data + "shamem-autosar-ro.hstg.svg",
  data + "shamem-autosar-raw.hstg.svg",
  data + "shamem-autosar-war.hstg.svg",
  data + "shamem-autosar-unknown.hstg.svg",
  //
  // data + "many.hstg.svg",
  data + "sendrecv-a.hstg.svg",
  data + "sendrecv-b.hstg.svg",
  // data + "hc-autosar-noiit.hstg.svg",
  // data + "braking7.hstg.svg",
  
)

// from https://github.com/typst/typst/issues/2025#issuecomment-2500136936
#let maybe-image(path, ..args) = context {
  let path-label = label(path)
  let first-time = query((context {}).func()).len() == 0
  if first-time or query(path-label).len() > 0 {
    [#image(path, ..args)#path-label]
  } else {
    [No File!]
  }
}

#let vimg(i, body) = {
  set par(spacing: 0.4em)
  rect(width: 100%, height: w, inset: 1pt)[
    // typst svg render does not scale the rectangles properly, therefore the text runs into the right wall
    // in other svg viewer it looks good
    #maybe-image(body)
  ]
  text(size: 0.65em, weight: "bold")[#numbering("(1)", i) #body.split(".").at(1)]
}

// #rect(height: 1.2em)[Dom A |Dom B]: Synchronizationpoint
#set align(center)
#canvas({
  import draw: *

  let y = 0.5
  let pad = 0.1
  let x_space = 0.5
  let radius = (y - 2*pad) / 2
  content((0,0), (16.4,y),
    box([#set par(justify: false, leading: 0.4em)
        #set align(center+horizon)
        #set text(size: 0.8em)
        // this does not work inside a tyst box, because after rect is always a new paragraph 
        // #rect(height: 1.2em)[Dom A |Dom B]: Synchronizationpoint
        
        // #text(size: 0.8em, black, weight: "extrabold")[#sym.rect.stroked.h]:Synchronizationpoint
      ],
      radius: 3pt, stroke: 0.5pt,
      width: 100%, height: 100%,
      inset: 0.2em,
      ), name: "root")
  rect((rel: (pad, 0+pad), to: "root.south-west"), (1,y - pad), name: "dom")
  line("dom.north", "dom.south")
  content("dom.east", anchor: "mid-west", padding: .1, text(size: 0.7em)[Synchronization Point], name: "sp")
  circle((rel: (x_space, 0), to: "sp.mid-east"), radius: (radius,radius * 0.66), 
    stroke: rgb("#008000"), name: "abb")
  content("abb.east", anchor: "mid-west", padding: .1, text(size: 0.7em)[ABB], name: "abb_text")
  rect((rel: (x_space, 0 - y/2 + pad), to: "abb_text.east"), (rel: (x_space*2.5, 0 + y/2 - pad), to: "abb_text.east"), 
    stroke: rgb("#6495ed"), name: "syscall")
  content("syscall.east", anchor: "mid-west", padding: .1, text(size: 0.7em)[Syscall/Hypercall], name: "syscall_text")
  circle((rel: (x_space, 0), to: "syscall_text.mid-east"), radius: (radius,radius * 0.66), 
    stroke: rgb("#ee82ee"), name: "idle")
  content("idle.east", anchor: "mid-west", padding: .1, text(size: 0.7em)[Idle State], name: "idle_text")
  rect((rel: (x_space, 0 - y/2 + pad), to: "idle_text.east"), (rel: (x_space*2, 0 + y/2 - pad), to: "idle_text.east"), 
    fill: rgb("#F8CECC"), name: "autosar")
  rect((rel: (0, 0 - y/2 + pad), to: "autosar.east"), (rel: (x_space, 0 + y/2 - pad), to: "autosar.east"), 
    fill: rgb("#DAE8FC"), name: "zephyr")
  rect((rel: (0, 0 - y/2 + pad), to: "zephyr.east"), (rel: (x_space, 0 + y/2 - pad), to: "zephyr.east"), 
    fill: rgb("#D5E8D4"), name: "baremetal")
  content("baremetal.east", anchor: "mid-west", padding: .1, text(size: 0.7em)[AUTOSAR/Zephyr/Baremetal], name: "os-text")
  
})
// 
#v(-0.25cm)
#grid(
  columns: cols,
  // columns: 5,
  column-gutter: 3pt,
  row-gutter: 10pt,
  align: center+horizon,
  ..svgs.slice(0, 24).enumerate(start: 1).map(((i,b)) => vimg(i,b))
)

// #v(0.25cm)
#grid(
  columns: 4,
  column-gutter: 3pt,
  row-gutter: 10pt,
  align: center+horizon,
  ..svgs.slice(24, 28).enumerate(start: 25).map(((i,b)) => vimg(i,b))
)

// #v(0.25cm)
#grid(
  columns: 2,
  column-gutter: 3pt,
  row-gutter: 10pt,
  align: center+horizon,
  ..svgs.slice(28, 30).enumerate(start: 29).map(((i,b)) => vimg(i,b))
)
