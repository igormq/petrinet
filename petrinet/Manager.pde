class Manager {

  PImage bg;
  PImage logo = loadImage("petrinet.png");
  UtilBox utilBox=new UtilBox();

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



  void draw() {
    //Sets Backgroung
    background(bg); 

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
    ((Place) places.get(i)).draw(mouseDragged);

    }
    //Draw all Transitions
    if (transitionCreated) {
      ((Transition) transitions.get(transitions.size()-1)).pos = new PVector (mouseX, mouseY); 
      if (mouseClicked) transitionCreated=false;
    }
    for (int i=0; i<transitions.size(); i++) {
      ((Transition) transitions.get(i)).draw(mouseDragged);
    }
  }
}

