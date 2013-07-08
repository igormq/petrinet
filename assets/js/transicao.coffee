Raphael.fn.transicao = (x, y) ->
  temp = @rect(x, y, LARGURA, ALTURA)
    .attr
       fill: "#000",
       stroke: "none",
       cursor: "move"
    .drag(move, start, end)
    .click(click)
    .mousedown(removeEl)
    .data("nome", "T#{numT}")
  console.log("nome is #{temp.data("nome")}")
  numT++
  bbox = temp.getBBox()
  tempx = bbox.x + bbox.width/2
  tempy = bbox.y - 8 # - font-size/2
  tempn = @text(tempx, tempy, temp.data("nome"))
    .attr
      fill: "#aaa"
      stroke: "#aaa"
      "font-size": 16
  temp.data("nomeref", tempn)
  temp