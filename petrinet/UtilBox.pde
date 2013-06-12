class UtilBox {

  ArrayList places= new ArrayList();
  ArrayList arcs= new ArrayList();
  ArrayList transitions= new ArrayList();

  Boolean boxOn = true;
  Boolean moveOn= false;
  Boolean mouseClicked = false;
  Boolean mouseDragged = false;
  Boolean mouseInsideBoxBar = false;

  //Box coordenates
  float boxX=5;
  float boxY=100;






  UtilBox() {
  }  

  //Box bar -  returns if the mouse is inside
  Boolean boxBar (float x, float y, float w, float h ) {

    // if mouse is inside rectangle
    if ( mouseX >= x  &&  mouseX <= x+w && mouseY >= y  &&  mouseY <= y+h) { 
      if (mouseDragged) {
        moveOn=true;
      }
      if (mouseClicked) {  
        fill(54, 54, 54, 100);   // the color if the mouse is pressed and over the button
        if (boxOn) boxOn=false;
        else if (!boxOn) boxOn=true;
        mouseClicked=false;
      }

      else {
        fill(0, 0, 0, 200); // the color if the mouse is over the button
      }
      rect(x, y, w, h);

      return true;
    } 

    fill(54, 54, 54, 100);     // the color if the mouse is not over the button
    rect(x, y, w, h);

    return false;
  }


  void box(Boolean boxOn) {
    if (boxOn) {
      strokeWeight(5);
      fill(97, 97, 97, 100);
      rect(boxX, boxY, 200, 620);
    }
  }


  void moveBox(Boolean moveOn) {
    if (moveOn) {
      PVector mouseMov = new PVector(mouseX-pmouseX, mouseY-pmouseY);
      boxX+=mouseMov.x;
      boxY+= mouseMov.y;
    }
  }

  //Draws UtilBox  
  void draw() {
    moveBox(moveOn);
    smooth();
    box(boxOn);
    //Draws boxBar
    mouseInsideBoxBar=boxBar(boxX, boxY, 200, 30);
  }
}

