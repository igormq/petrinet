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



