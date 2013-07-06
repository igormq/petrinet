$(function() {
  var band, click, end, height, in_range, line_collision, move, paper, rectSize, set, start, width, x, y;
  in_range = function(val, start, size) {
    return !(val + size < start || val > start + size);
  };
  line_collision = function(x1, y1, width1, height1, x2, y2, width2, height2) {
    var a, b;
    a = {
      top: y1,
      bottom: y1 + height1,
      left: x1,
      right: x1 + width1
    };
    b = {
      top: y2,
      bottom: y2 + height2,
      left: x2,
      right: x2 + width2
    };
    return !(a.left >= b.right || a.right <= b.left || a.top >= b.bottom || a.bottom <= b.top);
  };
  start = function() {
    this.ox = this.type === 'circle' ? this.attr("cx") : this.attr("x");
    this.oy = this.type === 'circle' ? this.attr("cy") : this.attr("y");
    return this.attr({
      cursor: "move",
      opacity: .5
    });
  };
  end = function() {
    return this.attr({
      cursor: "pointer",
      opacity: 1.0
    });
  };
  move = function(dx, dy) {
    var bbox,
      _this = this;
    bbox = this.getBBox();
    return set.forEach(function(e) {
      var bbox2, x, y;
      if (e.id !== _this.id) {
        bbox2 = e.getBBox();
        x = _this.ox + dx;
        y = _this.oy + dy;
        if (_this.type === 'circle') {
          x = x - _this.attr('r');
          y = y - _this.attr('r');
        }
        x = x < 0 ? 0 : (x > width - bbox.width ? width - bbox.width : x);
        y = y < 0 ? 0 : (y > height - bbox.height ? height - bbox.height : y);
        if (!line_collision(bbox2.x, bbox2.y, bbox2.width, bbox2.height, x, bbox.y, bbox.width, bbox.height)) {
          if ((_this.stuckx && (!in_range(y, bbox2.y, bbox2.height) || Math.abs(x - bbox.x) < bbox.width)) || !_this.stuckx) {
            if (_this.type === 'circle') {
              _this.attr({
                cx: x + _this.attr('r')
              });
            } else {
              _this.attr({
                x: x
              });
            }
            _this.pdx = dx;
            _this.stuckx = false;
          }
        } else {
          _this.stuckx = true;
          if (_this.type === 'circle') {
            _this.attr({
              cx: _this.pdx > dx ? bbox2.x + bbox2.width + 1 + _this.attr('r') : bbox2.x - 1 - _this.attr('r')
            });
          } else {
            _this.attr({
              x: _this.pdx > dx ? bbox2.x + bbox2.width + 1 : bbox2.x - bbox.width - 1
            });
          }
        }
        if (!line_collision(bbox2.x, bbox2.y, bbox2.width, bbox2.height, bbox.x, y, bbox.width, bbox.height)) {
          if ((_this.stucky && (!in_range(x, bbox2.x, bbox2.width) || Math.abs(y - bbox.y) < bbox.height)) || !_this.stucky) {
            if (_this.type === 'circle') {
              _this.attr({
                cy: y + _this.attr('r')
              });
            } else {
              _this.attr({
                y: y
              });
            }
            _this.pdy = dy;
            return _this.stucky = false;
          }
        } else {
          _this.stucky = true;
          if (_this.type === 'circle') {
            return _this.attr({
              cy: _this.pdy > dy ? bbox2.y + bbox2.height + 1 + _this.attr('r') : bbox2.y - 1 - _this.attr('r')
            });
          } else {
            return _this.attr({
              y: _this.pdy > dy ? bbox2.y + bbox2.height + 1 : bbox2.y - bbox.height - 1
            });
          }
        }
      }
    });
  };
  width = 500;
  height = 500;
  paper = Raphael('canvas', 500, 500);
  set = paper.set();
  band = paper.path("M 0 0");
  x = 0;
  y = 0;
  rectSize = 50;
  click = function() {
    var dimensions, oldx, oldy;
    oldx = x;
    oldy = y;
    dimensions = this.getBBox();
    x = dimensions.x + dimensions.width / 2;
    y = dimensions.y + dimensions.height / 2;
    if (paper.canvas.onmousemove != null) {
      console.log("Entrei aqui oldx: " + oldx + "oldy: " + oldy);
      band.attr({
        path: ("M " + oldx + " " + oldy + "L ") + x + " " + y
      });
    }
    band = paper.path("M 0 0").attr({
      "stroke-width": 5
    });
    band.node.style.pointerEvents = "none";
    if (paper.canvas.onmousemove == null) {
      return paper.canvas.onmousemove = function(e) {
        return band.attr({
          path: "M " + x + " " + y + "L " + e.clientX + " " + e.clientY
        });
      };
    } else {
      return paper.canvas.onmousemove = null;
    }
  };
  set.push(paper.rect(100, 200, rectSize, rectSize).attr({
    fill: "hsb(0, 0, 0)",
    stroke: "none",
    cursor: "move"
  }).drag(move, start, end).click(click));
  set.push(paper.circle(50, 100, 20).attr({
    fill: '#f00',
    stroke: "#fff",
    data: {
      fichas: 0
    },
    cursor: "pointer"
  }).drag(move, start, end).click(click));
  set.push(paper.circle(150, 100, 20).attr({
    fill: '#f00',
    stroke: "#fff",
    data: {
      fichas: 0
    },
    cursor: "pointer"
  }).drag(move, start, end).click(click));
  return $(window).resize(function() {
    return paper.setSize($(window).width(), $(window).height());
  });
});
