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
