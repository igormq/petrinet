class UtilBox {

  ArrayList places= new ArrayList();
  ArrayList arcs= new ArrayList();
  ArrayList transitions= new ArrayList();

  Boolean boxOn = true;
  Boolean mouseClicked = false;






  UtilBox() {
  }  


  void boxBar (int x, int y, int w, int h ) {

    // if mouse is inside rectangle
    if ( mouseX >= x  &&  mouseX <= x+w &&
      mouseY >= y  &&  mouseY <= y+h) { 

      if (mouseClicked) {  
println
        fill(54, 54, 54, 100);   // the color if the mouse is pressed and over the button
          if (boxOn) boxOn=false;
          else if (!boxOn) boxOn=true;
          mouseClicked=false;
        }
      
      else {
        fill(0, 0, 0, 200); // the color if the mouse is over the button
      }
    } 
    else {
      fill(54, 54, 54, 100);     // the color if the mouse is not over the button
    }

    rect(x, y, w, h);
  }


  void box(Boolean boxOn) {
    if (boxOn) {
      strokeWeight(5);
      fill(97, 97, 97, 100);
      rect(5, 130, 200, 620);
    }
  }



  //Draws UtilBox  
  void draw() {
    smooth();
    box(boxOn);
    boxBar(5, 100, 200, 30);
  }
}

