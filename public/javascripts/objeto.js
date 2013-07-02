var Objeto;

Objeto = (function() {
  Objeto._id = 1;

  function Objeto(processing, opts) {
    this.processing = processing;
    this.position = new this.processing.PVector(opts.x, opts.y);
    this.id = Objeto._id++;
    this._selected = false;
  }

  Objeto.prototype.mouseClicked = function(mouseX, mouseY) {
    if (this.mouseInside(mouseX, mouseY)) {
      this._selected = true;
    } else {
      this._selected = false;
    }
    return this._selected;
  };

  return Objeto;

})();
