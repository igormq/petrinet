Raphael.fn.lugar = (cx, cy) ->
	@circle(cx, cy, RAIO)
    .attr
      x: cx - RAIO,
      y: cy - RAIO,
      fill: '#12394d',
      stroke: "none",
      cursor: "pointer"
    .drag(move, start, end)
    .click(click)
    .dblclick(dblclick)
    .data 'fichas', 0