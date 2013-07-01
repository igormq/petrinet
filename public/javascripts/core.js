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
  processing.mouseClicked = function() {
    var object, _i, _len, _ref, _results;
    if (processing.mouseButton === processing.RIGHT) {
      return this.objects.push(new Lugar(processing, {
        x: processing.mouseX,
        y: processing.mouseY
      }));
    } else {
      _ref = this.objects;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        object = _ref[_i];
        _results.push(object.mouseClicked(processing.mouseX, processing.mouseY));
      }
      return _results;
    }
  };
  resizeWindow = function() {
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
  return processing.draw = function() {
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
};

$(function() {
  var canvas, processing;
  canvas = document.getElementById("processing");
  return processing = new Processing(canvas, core_draw);
});
