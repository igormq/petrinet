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
