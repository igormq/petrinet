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
class Places{
  
  
  
  
}    
class Transitions{
  
  
  
  
  
  
}
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


