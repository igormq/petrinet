var Lugar;

Lugar = (function() {
  Lugar._id = 1;

  Lugar._radius = 30;

  function Lugar(processing, opts) {
    this.processing = processing;
    this.position = new this.processing.PVector(opts.x, opts.y);
    this.id = Lugar._id++;
    this.draw();
  }

  Lugar.prototype.draw = function() {
    return this.processing.ellipse(this.position.x, this.position.y, Lugar._radius, Lugar._radius);
  };

  Lugar.prototype.mouseClicked = function(mouseX, mouseY) {};

  return Lugar;

})();
