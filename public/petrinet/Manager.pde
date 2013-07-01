class Manager {

  PImage bg;
  PImage trash = loadImage("trash.png");
  PImage logo = loadImage("petrinet.png");
  UtilBox utilBox=new UtilBox();

  //Historic info (just for ids)
  int numberOfPlacesCreated=0;
  int numberOfTransitionsCreated=0;

  //Current Activities
  Place placeDragged = null;
  Transition transitionDragged =null;
  Place mouseInsidePlace =null;
  Transition mouseInsideTransition=null;
  Boolean drawingArc=false;

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

  //Moves UtilBox
  void moveUtilBox() {
    if (! drawingArc) {
      if ( utilBox.mouseInsideBoxBar) ( utilBox).mouseClicked= true;
    }
  }
  //Creating places
  void createPlace() {
    if (! drawingArc) {
      if ( utilBox.mouseInsidePB) ( utilBox).mouseClicked= true;
    }

    //When we have just created a place 
    if ( placeCreated) {
      placeCreated=false;
      mouseClicked=false;
    }
  }


  //Creating transition
  void createTransition() {
    if (! drawingArc) {
      if ( utilBox.mouseInsideTB) ( utilBox).mouseClicked= true;
    }

    //When we have just created atransition
    //next click will place it
    if ( transitionCreated) {
      transitionCreated=false;
      mouseClicked=false;
    }
  }





  //Creating Arc
  void createArc() {
    if (!( placeCreated ||  transitionCreated)) {
      if ((( mouseInsidePlace!=null ||  mouseInsideTransition!=null) && (! drawingArc))) {
        drawingArc=true;

        if ( mouseInsidePlace!=null) {
          arcs.add(new Arc( mouseInsidePlace.id, "Place"));
          ((Arc) arcs.get( arcs.size()-1)).fromPlace= mouseInsidePlace;
        }
        if ( mouseInsideTransition!=null) {
          arcs.add(new Arc( mouseInsideTransition.id, "Transition"));
          ((Arc) arcs.get( arcs.size()-1)).fromTransition= mouseInsideTransition;
        }
      }

      if ((( mouseInsidePlace==null &&  mouseInsideTransition==null) && ( drawingArc))) {
        ((Arc) arcs.get( arcs.size()-1)).newVertex(mouseX, mouseY);
      }

      if ( mouseInsidePlace!=null &&  drawingArc) {
        if (((Arc) arcs.get( arcs.size()-1)).fromType.equals("Transition")) {
          drawingArc=false;
          ((Arc) arcs.get( arcs.size()-1)).to= mouseInsidePlace.id;
          ((Arc) arcs.get( arcs.size()-1)).toPlace= mouseInsidePlace;
        }
      }

      if ( mouseInsideTransition!=null &&  drawingArc) {
        if (((Arc) arcs.get( arcs.size()-1)).fromType.equals("Place")) {
          drawingArc=false;
          ((Arc) arcs.get( arcs.size()-1)).to= mouseInsideTransition.id;
          ((Arc) arcs.get( arcs.size()-1)).toTransition= mouseInsideTransition;
        }
      }
      if (mouseButton==RIGHT &&  drawingArc) {
        arcs.remove( arcs.size()-1);
        drawingArc=false;
      }
    }
  }





  void trash(float x, float y, float w, float h, PImage trash) {

    // if mouse is inside rectangle
    if ( mouseX >= x  &&  mouseX <= x+w &&
      mouseY >= y  &&  mouseY <= y+h) { 
      if (placeDragged!=null) {
        places.remove(int(placeDragged.index));
        placeDragged=null;
        mouseInsidePlace=null;
        if (drawingArc) {
          arcs.remove(arcs.size()-1);
          drawingArc=false;
        }
      }
      if (transitionDragged!=null) {
        transitions.remove(int(transitionDragged.index));
        transitionDragged=null;
        mouseInsideTransition=null;
        if (drawingArc) {
          arcs.remove(arcs.size()-1);
          drawingArc=false;
        }
      }
      tint(150, 100); // the color if the mouse is over the button
    } 
    else {
      noTint();     // the color if the mouse is not over the button
    }

    image(trash, x, y);
    noTint();
  }

  void draw() {

    println("DrawingArc:" + drawingArc+"  ;  "+ "MouseInsidePlace:"+mouseInsidePlace+"  ;  "+"  ;  "+ "MouseInsideTransition:"+mouseInsideTransition+"  ;  "+"NumberOfArcs:"+arcs.size() );
    //Sets Backgroung
    background(bg); 

    //Prints Trash
    trash(900, 640, 128, 128, trash);

    //Prints Logo
    image(logo, 4, 6);

    //Prints UtilBox
    utilBox.draw();

    //Draw all arcs

    for (int i=0; i<arcs.size(); i++) {
      ((Arc) arcs.get(i)).index=i;
      ((Arc) arcs.get(i)).draw();
    }

    //Draw all Places
    if (placeCreated) {
      ((Place) places.get(places.size()-1)).pos = new PVector (mouseX, mouseY); 
      if (mouseClicked) placeCreated=false;
    }
    for (int i=0; i<places.size(); i++) {
      if (places.get(i)!=null) {
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
      ((Transition) transitions.get(i)).index=i;      
      ((Transition) transitions.get(i)).draw(mouseDragged);
    }
  }
}

