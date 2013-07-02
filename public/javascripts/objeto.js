var Objeto;

Objeto = (function() {
  Objeto._id = 1;

  function Objeto(processing, opts) {
    this.processing = processing;
    this.position = new this.processing.PVector(opts.x, opts.y);
    this.id = Objeto._id++;
    this._selected = false;
    this.dragged = false;
  }

  Objeto.prototype.mouseClicked = function(mouseX, mouseY) {
    if (this.mouseInside(mouseX, mouseY)) {
      this._selected = true;
    } else {
      this._selected = false;
    }
    return this._selected;
  };

  Objeto.prototype.startDrag = function(mouseX, mouseY) {
    if (this.mouseInside(mouseX, mouseY) && !this.dragged) {
      this.dragged = true;
      this._offsetX = mouseX - this.position.x;
      return this._offsetY = mouseY - this.position.y;
    }
  };

  Objeto.prototype.mouseReleased = function() {
    return this.dragged = false;
  };

  Objeto.prototype.update = function(mouseX, mouseY) {
    if (this.dragged) {
      this.position.x = mouseX - this._offsetX;
      return this.position.y = mouseY - this._offsetY;
    }
  };

  return Objeto;

})();
