#import "@preview/cetz:0.3.4": *

#let w = 40mm
#let a4w = 210mm
#set page(width: a4w, height: auto, margin: (x: 0.5mm, y: 1mm))


#set text(font: "Nimbus Sans")

#let maybe-image(path, ..args) = context {
  let path-label = label(path)
  let first-time = query((context {}).func()).len() == 0
  if first-time or query(path-label).len() > 0 {
    [#image(path, ..args)#path-label]
  } else {
    [No File!]
  }
}

#maybe-image(sys.inputs.path + "/HyperSSE.brakingCheck.hstg.svg")
