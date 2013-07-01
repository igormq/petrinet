var Popup;

Popup = (function() {
  Popup._largura = 120;

  Popup._altura = 40;

  function Popup(processing) {
    this.processing = processing;
    this.visible = false;
  }

  Popup.prototype.draw = function() {
    if (this.visible) {
      this.processing.rect(this.position.x, this.position.y, Popup._largura, Popup._altura);
      this.processing.line(this.position.x + 40, this.position.y, this.position.x + 40, this.position.y + 40, Popup._largura, Popup._altura);
      this.processing.line(this.position.x + 80, this.position.y, this.position.x + 80, this.position.y + 40, Popup._largura, Popup._altura);
      return this.processing.ellipse(this.position.x + 20, this.position.y + 20, 20, 20);
    }
  };

  Popup.prototype.mouseInside = function(mouseX, mouseY) {
    if (this.visible === false) {
      return false;
    }
    return mouseX >= this.position.x && mouseX <= this.position.x + Popup._largura && mouseY >= this.position.y && mouseY <= this.position.y + Popup._altura;
  };

  Popup.prototype.mouseClicked = function(mouseX, mouseY) {
    this.visible = !this.visible;
    return this.position = new this.processing.PVector(mouseX, mouseY);
  };

  Popup.prototype.mouseMoved = function(mouseX, mouseY) {
    if (!this.mouseInside(mouseX, mouseY)) {
      return this.visible = false;
    }
  };

  return Popup;

})();
