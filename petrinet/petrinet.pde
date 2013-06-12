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
 
 if(manager.placeCreated) {
   manager.placeCreated=false;
   manager.mouseClicked=false;
 } 
 
 if(manager.transitionCreated) {
   manager.transitionCreated=false;
   manager.mouseClicked=false;
 } 
  
}

void mouseDragged(){
 (manager.utilBox).mouseDragged=true; 
 manager.mouseDragged=true;
  
  
}


void mouseReleased(){
  (manager.utilBox).mouseDragged=false;
  (manager.utilBox).moveOn=false;
  manager.mouseDragged=false;
  manager.placeDragged=null;
  manager.transitionDragged=null;
}



