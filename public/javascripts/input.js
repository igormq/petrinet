var Input;

Input = (function() {
  Input._width = 120;

  Input._height = 40;

  function Input(processing, opts) {
    this.processing = processing;
    this.position = new this.processing.PVector(opts.x, opts.y);
  }

  Input.prototype.draw = function() {
    this.processing.rect(this.position.x, this.position.y, Input._width, Input._height);
    this.processing.line(this.position.x + 40, this.position.x + 40, this.position.y, this.position.y + 40, Input._width, Input._height);
    return this.processing.ellipse(this.position.x + 20, this.position.y + 20, 20, 20);
  };

  Input.prototype.mouseMoved = function() {};

  Input.prototype.mouseHover = function() {};

  Input.prototype.mouseClicked = function() {};

  return Input;

})();
