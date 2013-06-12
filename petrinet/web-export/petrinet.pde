Manager manager;

void setup(){
//Setting screen size
size(1024,768);

//Loading background
PImage bg = loadImage("bg.png");


//Constructing the Manager
manager = new Manager(bg, new UtilBox());


  


}




void draw(){

 

manager.draw();
 
 smooth();





}

void mouseClicked(){
 if(manager.utilBox.mouseInsideBoxBar) (manager.utilBox).mouseClicked= true; 
 if(manager.utilBox.mouseInsideTB) (manager.utilBox).mouseClicked= true; 
 if(manager.utilBox.mouseInsidePB) (manager.utilBox).mouseClicked= true; 
  
}

void mouseDragged(){
 (manager.utilBox).mouseDragged=true; 
  
  
}


void mouseReleased(){
  (manager.utilBox).mouseDragged=false;
  (manager.utilBox).moveOn=false;
}



class Arcs{
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
}
class Manager{
  
  PImage bg;
  PImage logo = loadImage("petrinet.png");
  UtilBox utilBox=new UtilBox();
  
  ArrayList places= new ArrayList();
  ArrayList arcs= new ArrayList();
  ArrayList transitions= new ArrayList();
  
 //Constructor
 Manager(PImage bg, UtilBox utilBox){
  this.utilBox=utilBox;
  this.bg=bg; 
   
 }
 
 
 
 void draw(){
  background(bg); 
  //Prints Logo
  image(logo,4,6);
  utilBox.draw();
      
 }
  
  
}
class Place{
  
  Place(color pColor){
    
  }
  
}    
class Transition{
  
  
  Transition(){
  }
  
  
  
  
  
  
  
}
class UtilBox {



  Boolean boxOn = true;
  Boolean moveOn= false;
  Boolean mouseClicked = false;
  Boolean mouseDragged = false;
  Boolean mouseInsideBoxBar = false;
  Boolean mouseInsideTB = false;
  Boolean mouseInsidePB = false;

  //Box coordenates
  float boxX=5;
  float boxY=100;





  //Empty constructor
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
      textSize(23);
      fill(255);
      text("MENU", boxX+69, boxY+25);
      return true;
    } 

    fill(54, 54, 54, 100);     // the color if the mouse is not over the button
    rect(x, y, w, h);
    textSize(23);
    fill(255);
    text("MENU", boxX+69, boxY+25);

    return false;
  }

  //Transitions Button
  void transitionButton( float x, float y, float w, float h )
  {
    // if mouse is inside rectangle
    if ( mouseX >= x  &&  mouseX <= x+w &&
      mouseY >= y  &&  mouseY <= y+h) { 
      mouseInsideTB=true;

      if (mouseClicked) {       
        (manager.transitions).add(new Transition());
        mouseClicked=false;
      }
      else {
        fill(255, 255, 0); // the color if the mouse is over the button
      }
    } 
    else {
      fill(0, 0, 0, 245);     // the color if the mouse is not over the button
    }
    rect(x, y, w, h);
  }

  //Places Button
  void placeButton( float x, float y, float radius, color bColor )
  {
    // if mouse is inside ellipse
    if ( (dist(mouseX, mouseY, x, y))<=radius) { 
      mouseInsidePB=true;
      if (mouseClicked) {       
        (manager.places).add(new Place(bColor));
        mouseClicked=false;
      }

      else {
        fill(bColor); // the color if the mouse is over the button
      }
    } 
    else {
      fill(bColor, 150);     // the color if the mouse is not over the button
    }

    ellipse(x, y, radius, radius);
  }

  //MENU box
  void box(Boolean boxOn) {
    if (boxOn) {
      strokeWeight(5);
      textSize(23);


      fill(97, 97, 97, 100);
      rect(boxX, boxY, 200, 620);

      //Places Menu
      fill(0, 0, 0, 225);
      rect(boxX, boxY+45, 200, 30);
      fill(255);
      text("Places", boxX+65, boxY+68);
      placeButton(boxX+40, boxY+100, 30, color(152, 58, 47));
      placeButton(boxX+100, boxY+100, 30, color(20, 56, 255));
      placeButton(boxX+160, boxY+100, 30, color(249, 249, 20));
      placeButton(boxX+40, boxY+145, 30, color(51, 255, 23));
      placeButton(boxX+100, boxY+145, 30, color(255, 145, 233));
      placeButton(boxX+160, boxY+145, 30, color(255, 50, 0));

      //Transitions Menu
      fill(0, 0, 0, 225);
      rect(boxX, boxY+170, 200, 30);
      fill(255);
      text("Transitions", boxX+36, boxY+193);
      transitionButton(boxX+40, boxY+220, 15, 60);
      transitionButton(boxX+90, boxY+220, 60, 15);


      //Informations Menu
      fill(0, 0, 0, 225);
      rect(boxX, boxY+300, 200, 30);
      fill(255);
      text("Informations", boxX+35, boxY+323);
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


