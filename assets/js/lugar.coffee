Raphael.fn.lugar = (cx, cy) ->
	tempc = @circle(cx, cy, RAIO)
    .attr
      x: cx - RAIO,
      y: cy - RAIO,
      fill: '#12394d',
      stroke: "none",
      cursor: "pointer"
    .drag(move, start, end)
    .click(click)
    .dblclick(dblclick)
    .mousedown(removeEl)
    .data 'fichas', 0
  temp = @text(cx,cy,"0")
  temp.node.style.pointerEvents = "none"
  tempc.data("textref", temp)
  console.log("circulo criado")
  console.log("temp id is #{temp.id}")
  console.log("tempc id is #{tempc.id}")
  tempc