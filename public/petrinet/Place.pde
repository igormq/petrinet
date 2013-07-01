class Place {

  PVector pos;
  color pColor;
  Boolean mouseDragged;
  Boolean mouseInside=false;
  String id;
  int index;

  int tokens=0;
  int tokensCap=100;


  Place(color pColor, String id) {
    this.pColor=pColor;
    this.pos = new PVector(mouseX, mouseY);
    this.id=id;
  }



  void pShape( float x, float y, float radius, color bColor )
  {
    // if mouse is inside ellipse
    if ( (dist(mouseX, mouseY, x, y))<=radius) {
      if (!mouseDragged)   mouseInside=true;
      if (!manager.placeCreated) manager.mouseInsidePlace=(Place)manager.places.get(index);

      fill(bColor,100); // the color if the mouse is over the button
    }
    else {
      if ((!mouseDragged)&&mouseInside) {
        mouseInside=false;
      manager.mouseInsidePlace=null;
    }

      fill(bColor, 400);     // the color if the mouse is not over the button
    }

    ellipse(x, y, radius, radius);
  }

  void draw(Boolean mouseDragged) {
    this.mouseDragged=mouseDragged;
    strokeWeight(5);
    if (mouseDragged && mouseInside) {
      manager.placeDragged=(Place)(manager.places).get(index);
      PVector mouseMov = new PVector(mouseX-pmouseX, mouseY-pmouseY);
      pos.x+=mouseMov.x;
      pos.y+=mouseMov.y;
    }

    pShape(pos.x, pos.y, 40, pColor);
    textSize(20);
    fill(0);
    textAlign(CENTER);
    text(tokens, pos.x, pos.y+7);
    textSize(15);
    text(id, pos.x-25, pos.y-25);


  }
}