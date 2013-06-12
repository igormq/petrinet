class Manager {

  PImage bg;
  PImage trash = loadImage("trash.png");
  PImage logo = loadImage("petrinet.png");
  UtilBox utilBox=new UtilBox();
  
  //Historic info (just for ids)
  int numberOfPlacesCreated=0;
  int numberOfTransitionsCreated=0;
  
  Place placeDragged = null;
  Transition transitionDragged =null;
  
  ArrayList places= new ArrayList();
  ArrayList arcs= new ArrayList();
  ArrayList transitions= new ArrayList();

  Boolean placeCreated=false;
  Boolean transitionCreated=false;

  Boolean mouseClicked =false;
  Boolean mouseDragged = false;

  //Constructor
  Manager(PImage bg, UtilBox utilBox) {
    this.utilBox=utilBox;
    this.bg=bg;
  }

void trash(float x, float y, float w, float h, PImage trash){

  // if mouse is inside rectangle
  if ( mouseX >= x  &&  mouseX <= x+w &&
       mouseY >= y  &&  mouseY <= y+h) { 
       if(placeDragged!=null){
         places.remove(int(placeDragged.index));
         placeDragged=null;
       }
        if(transitionDragged!=null){
         transitions.remove(int(transitionDragged.index));
         transitionDragged=null;
       }
      tint(150,100); // the color if the mouse is over the button
  
    
  } 
  else {
    noTint();     // the color if the mouse is not over the button
  }
  
image(trash,x,y);
noTint();

  
}

  void draw() {
    
    println(places.size());
    //Sets Backgroung
    background(bg); 
    
    //Prints Trash
    trash(900,640,128,128,trash);

    //Prints Logo
    image(logo, 4, 6);

    //Prints UtilBox
    utilBox.draw();

    //Draw all Places
    if (placeCreated) {
      ((Place) places.get(places.size()-1)).pos = new PVector (mouseX, mouseY); 
      if (mouseClicked) placeCreated=false;
    }
    for (int i=0; i<places.size(); i++) {
      if(places.get(i)!=null){
        ((Place) places.get(i)).index=i;
        ((Place) places.get(i)).draw(mouseDragged);
      }
    }
    //Draw all Transitions
    if (transitionCreated) {
      ((Transition) transitions.get(transitions.size()-1)).pos = new PVector (mouseX, mouseY); 
      if (mouseClicked) transitionCreated=false;
    }
    for (int i=0; i<transitions.size(); i++) {
      ((Transition) transitions.get(i)).index=i;;
      ((Transition) transitions.get(i)).draw(mouseDragged);
    }
  }
}

