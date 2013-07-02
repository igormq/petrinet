var Transicao,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Transicao = (function(_super) {
  __extends(Transicao, _super);

  Transicao._largura = 20;

  Transicao._altura = 10;

  function Transicao(processing, opts) {
    Transicao.__super__.constructor.call(this, processing, opts);
  }

  Transicao.prototype.draw = function() {
    if (!this._selected) {
      this.processing.fill(255, 0, 0);
    } else {
      this.processing.fill(0, 0, 255);
    }
    return this.processing.rect(this.position.x, this.position.y, Transicao._largura, Transicao._altura);
  };

  Transicao.prototype.mouseInside = function(mouseX, mouseY) {
    return mouseX >= this.position.x - Transicao._largura / 2 && mouseX <= this.position.x + Transicao._largura / 2 && mouseY >= this.position.y - Transicao._altura && mouseY <= this.position.y + Transicao._altura;
  };

  return Transicao;

})(Objeto);
