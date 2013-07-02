var Lugar,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Lugar = (function(_super) {
  __extends(Lugar, _super);

  Lugar._radius = 15;

  function Lugar(processing, opts) {
    Lugar.__super__.constructor.call(this, processing, opts);
    this.fichas = 0;
  }

  Lugar.prototype.draw = function() {
    if (!this._selected) {
      this.processing.fill(255, 0, 0);
    } else {
      this.processing.fill(0, 0, 255);
    }
    this.processing.ellipse(this.position.x, this.position.y, Lugar._radius * 2, Lugar._radius * 2);
    return this._drawFichas();
  };

  Lugar.prototype._drawFichas = function() {
    this.processing.fill(0);
    this.processing.textSize(20);
    this.processing.textAlign(this.processing.CENTER, this.processing.CENTER);
    return this.processing.text(this.fichas, this.position.x, this.position.y);
  };

  Lugar.prototype.mouseInside = function(mouseX, mouseY) {
    return this.processing.dist(mouseX, mouseY, this.position.x, this.position.y) <= Lugar._radius;
  };

  return Lugar;

})(Objeto);
