var core_draw;

core_draw = function(processing) {
  var resizeWindow;
  this._objects = [];
  processing.setup = function() {
    resizeWindow();
    processing.println('PetriNet 0.0.1');
    processing.background();
    return this.manager = new Manager(processing);
  };
  processing.draw = function() {
    var object, _i, _len, _ref, _results;
    resizeWindow();
    _ref = this._objects;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      object = _ref[_i];
      _results.push(object.draw());
    }
    return _results;
  };
  processing.mouseClicked = function() {
    return this._objects.push(new Lugar(processing, {
      x: mouseX,
      y: processing.mouseY
    }));
  };
  return resizeWindow = function() {
    var setupHeight;
    if ($(document).height() > $(window).height()) {
      return setupHeight = $(document).height();
    } else {
      setupHeight = $(window).height();
      $('canvas').width($(window).width());
      $('canvas').height(setupHeight);
      return processing.size($(window).width(), setupHeight);
    }
  };
};

$(function() {
  var canvas;
  canvas = document.getElementById("processing");
  return this.processing = new Processing(canvas, core_draw);
});
