var core_draw;

core_draw = function(processing) {
  var resizeWindow;
  processing.setup = function() {
    resizeWindow();
    processing.println('PetriNet 0.0.1');
    processing.background();
    this.manager = new Manager(processing);
    return this.objects = [];
  };
  processing.draw = function() {
    var object, _i, _len, _ref, _results;
    resizeWindow();
    _ref = this.objects;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      object = _ref[_i];
      _results.push(object.draw());
    }
    return _results;
  };
  processing.mouseClicked = function() {
    return this.objects.push(new Input(processing, {
      x: processing.mouseX,
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
  var canvas, processing;
  canvas = document.getElementById("processing");
  return processing = new Processing(canvas, core_draw);
});
