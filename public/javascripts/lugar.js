var Lugar;

Lugar = (function() {
  Lugar._id = 1;

  Lugar._radius = 40;

  function Lugar(processing, opts) {
    this.processing = processing;
    this.position = new this.processing.PVector(opts.x, opts.y);
    this.id = Lugar._id++;
    this.fichas = 0;
    this.draw();
  }

  Lugar.prototype.draw = function() {
    this.processing.fill(this.processing.white);
    this.processing.ellipse(this.position.x, this.position.y, Lugar._radius, Lugar._radius);
    return this._drawFichas();
  };

  Lugar.prototype._drawFichas = function() {
    this.processing.fill(0);
    this.processing.textSize(20);
    this.processing.textAlign(this.processing.CENTER, this.processing.CENTER);
    return this.processing.text(this.fichas, this.position.x, this.position.y);
  };

  Lugar.prototype.mouseClicked = function(mouseX, mouseY) {};

  return Lugar;

})();
