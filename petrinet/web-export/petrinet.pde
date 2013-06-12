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





}
class Arcs{
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
}
class Manager{
  
  PImage bg;
  PImage logo = loadImage("petrinet.png");
  UtilBox utilBox;
  
  
 //Constructor
 Manager(PImage bg, UtilBox utilBox){
  this.utilBox=utilBox;
  this.bg=bg; 
   
 }
 
 
 
 void draw(){
  background(bg); 
  //Prints Logo
  image(logo,4,6);
      
 }
  
  
}
class Places{
  
  
  
  
}    
class Transitions{
  
  
  
  
  
  
}
class UtilBox{
  
  ArrayList places= new ArrayList();
  ArrayList arcs= new ArrayList();
  ArrayList transitions= new ArrayList();
  
  
  
  
  
  
UtilBox(){

}  
  
  
  
//Draws UtilBox  
void draw(){

}  
  
 
}

