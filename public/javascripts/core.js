var core_draw;

core_draw = function(processing) {
  var resizeWindow;
  processing.setup = function() {
    resizeWindow();
    processing.println('PetriNet 0.0.1');
    processing.background();
    return this.manager = new Manager(processing);
  };
  processing.draw = function() {
    return resizeWindow();
  };
  processing.mouseClicked = function() {};
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
