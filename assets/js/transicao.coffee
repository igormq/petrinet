Raphael.fn.transicao = (x, y) ->
  @rect(x, y, LARGURA, ALTURA)
    .attr
       fill: "#000",
       stroke: "none",
       cursor: "move"
    .drag(move, start, end)
    .click(click)
    .mousedown(removeEl)