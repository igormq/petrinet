var Input;

Input = (function() {
  Input._largura = 120;

  Input._altura = 40;

  function Input(processing) {
    this.processing = processing;
    this.visible = false;
  }

  Input.prototype.draw = function() {
    if (this.visible) {
      this.processing.rect(this.position.x, this.position.y, Input._largura, Input._altura);
      this.processing.line(this.position.x + 40, this.position.y, this.position.x + 40, this.position.y + 40, Input._largura, Input._altura);
      this.processing.line(this.position.x + 80, this.position.y, this.position.x + 80, this.position.y + 40, Input._largura, Input._altura);
      return this.processing.ellipse(this.position.x + 20, this.position.y + 20, 20, 20);
    }
  };

  Input.prototype.mouseInside = function(mouseX, mouseY) {
    if (this.visible === false) {
      return false;
    }
    if (mouseX >= this.position.x && mouseX <= this.position.x + Input._largura && mouseY >= this.position.y && mouseY <= this.position.y + Input._altura) {
      return true;
    } else {
      return false;
    }
  };

  Input.prototype.mouseClicked = function(mouseX, mouseY) {
    this.visible = !this.visible;
    return this.position = new this.processing.PVector(mouseX, mouseY);
  };

  Input.prototype.mouseMoved = function(mouseX, mouseY) {
    if (!this.mouseInside(mouseX, mouseY)) {
      return this.visible = false;
    }
  };

  return Input;

})();
