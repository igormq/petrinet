var Objeto;

Objeto = (function() {
  function Objeto() {}

  Objeto._id = 1;

  Objeto.prototype.contructor = function(processing, opts) {
    this.processing = processing;
    this.position = new this.processing.PVector(opts.x, opts.y);
    this.id = Objeto._id++;
    return this._selected = false;
  };

  return Objeto;

})();
