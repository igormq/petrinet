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
    .data('fichas', 0)
    .data("nome", "P#{numP}")
  temp = @text(cx,cy,"0")
    .attr
      fill: "#fff"
      "font-size": 16
  temp.node.style.pointerEvents = "none"
  tempc.data("textref", temp)
  console.log("nome is #{tempc.data("nome")}")
  numP++
  bbox = tempc.getBBox()
  tempx = bbox.x + bbox.width/2
  tempy = bbox.y - 8 # - font-size/2
  tempn = @text(tempx, tempy, tempc.data("nome"))
    .attr
      fill: "#aaa"
      stroke: "#aaa"
      "font-size": 16
  tempc.data("nomeref", tempn)
  tempc