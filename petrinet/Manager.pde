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
  //println(transitions.size());
      
 }
  
  
}
