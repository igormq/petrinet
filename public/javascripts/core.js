var core_draw,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

core_draw = function(processing) {
  var resizeWindow;
  processing.setup = function() {
    resizeWindow();
    processing.println('PetriNet 0.0.1');
    processing.background();
    this.manager = new Manager(processing);
    this.teste = new Transicao(processing, {
      x: 200,
      y: 200
    });
    this.popup = new Popup(processing);
    return this.objects = [];
  };
  processing.mouseClicked = function() {
    var object, _i, _len, _ref, _results,
      _this = this;
    if (!(__indexOf.call((function() {
      var _i, _len, _ref, _results;
      _ref = this.objects;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        object = _ref[_i];
        _results.push(object.mouseInside(processing.mouseX, processing.mouseY));
      }
      return _results;
    }).call(this), true) >= 0)) {
      if (processing.mouseButton === processing.RIGHT) {
        return this.popup.mouseClicked(processing.mouseX, processing.mouseY);
      } else {
        if (this.popup.visible) {
          return this.popup.mouseClicked(processing.mouseX, processing.mouseY, function(object) {
            if (object != null) {
              return _this.objects.push(object);
            }
          });
        }
      }
    } else if (processing.mouseButton === processing.LEFT) {
      _ref = this.objects;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        object = _ref[_i];
        _results.push(object.mouseClicked(processing.mouseX, processing.mouseY));
      }
      return _results;
    }
  };
  processing.mouseMoved = function() {
    var object;
    if (this.popup.visible != null) {
      return this.popup.mouseMoved(processing.mouseX, processing.mouseY);
    } else {
      if ((__indexOf.call((function() {
        var _i, _len, _ref, _results;
        _ref = this.objects;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          object = _ref[_i];
          _results.push(object.mouseInside(processing.mouseX, processing.mouseY));
        }
        return _results;
      }).call(this), true) >= 0)) {
        return processing.cursor(processing.HAND);
      } else {
        return processing.cursor(processing.ARROW);
      }
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
    this.popup.draw();
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
