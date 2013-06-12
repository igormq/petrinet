Manager manager;

void setup(){
//Setting screen size
size(1024,768);

//Loading background
PImage bg = loadImage("bg.png");


//Constructing the Manager
manager = new Manager();


  


}




void draw(){


manager.draw();





}
class Arcs{
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
}
class Manager{
  
  PImage bg;
  
  
  
 //Constructor
 Manager(){
     PImage bg = loadImage("bg.png");

  this.bg=bg; 
   
 }
 void draw(){
if(bg!=null)  line(0,0,500,500);
image(bg,400,400);
  background(bg); 
   
   
 }
  
  
}
class Places{
  
  
  
  
}    
class Transitions{
  
  
  
  
  
  
}
class UtilBox{
  
  
  
  
  
  
  
UtilBox(){

}  
  
  
  
//Draws UtilBox  
void draw(){

}  
  
 
}

