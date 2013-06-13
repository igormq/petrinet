class Transition {

  PVector pos;
  Boolean mouseInside=false;
  Boolean mouseDragged;

  String id;
  int index;

  float w, h;

  //Empty Constructor
  Transition(float w, float h, String id) {
    this.pos = new PVector(mouseX, mouseY);
    this.w=w;
    this.h=h;
    this.id=id;
  }



  void tShape( float x, float y, float w, float h )
  {
    // if mouse is inside rect
    if ( mouseX >= x-w/2  &&  mouseX <= x+w/2 && mouseY >= y-h/2  &&  mouseY <= y+h/2) { 
      if (!mouseDragged)   mouseInside=true;
      if(!manager.transitionCreated)  manager.mouseInsideTransition=(Transition)manager.transitions.get(index);


      fill(255, 255, 0); // the color if the mouse is over the button
    } 
    else {
      if ((!mouseDragged)&&mouseInside){
        mouseInside=false;
      manager.mouseInsideTransition=null;
      
      }fill(0, 0, 0, 255);     // the color if the mouse is not over the button
    }
    rectMode(CENTER);
    rect(x, y, w, h);   
    rectMode(CORNER);


  }

  void draw(Boolean mouseDragged) {
    this.mouseDragged=mouseDragged;
    strokeWeight(6);
    if (mouseDragged && mouseInside) {
      manager.transitionDragged=(Transition)(manager.transitions).get(index);
      PVector mouseMov = new PVector(mouseX-pmouseX, mouseY-pmouseY);
      pos.x+=mouseMov.x;
      pos.y+=mouseMov.y;
    }
    tShape(pos.x, pos.y, w, h);

    

    textSize(15);
    fill(0);
    textAlign(CENTER);
    text(id, pos.x-15, pos.y+7);
  }
}    

