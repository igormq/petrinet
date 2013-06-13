Manager manager;

void setup() {
  //Setting screen size
  size(1024, 768);

  //Loading background
  PImage bg = loadImage("bg.png");


  //Constructing the Manager
  manager = new Manager(bg, new UtilBox());
}




void draw() {



  manager.draw();

  smooth();
}

void mouseClicked() {
  if(!manager.drawingArc){
  if (manager.utilBox.mouseInsideBoxBar) (manager.utilBox).mouseClicked= true; 
  if (manager.utilBox.mouseInsideTB) (manager.utilBox).mouseClicked= true; 
  if (manager.utilBox.mouseInsidePB) (manager.utilBox).mouseClicked= true;
  }


  if (!(manager.placeCreated || manager.transitionCreated)) {
    if (((manager.mouseInsidePlace!=null || manager.mouseInsideTransition!=null) && (!manager.drawingArc))) {
      manager.drawingArc=true;

      if (manager.mouseInsidePlace!=null) {
        manager.arcs.add(new Arc(manager.mouseInsidePlace.id, "Place"));
        ((Arc)manager.arcs.get(manager.arcs.size()-1)).fromPlace=manager.mouseInsidePlace;
      }
      if (manager.mouseInsideTransition!=null) {
        manager.arcs.add(new Arc(manager.mouseInsideTransition.id, "Transition"));
        ((Arc)manager.arcs.get(manager.arcs.size()-1)).fromTransition=manager.mouseInsideTransition;
      }
    }
    
    if (((manager.mouseInsidePlace==null && manager.mouseInsideTransition==null) && (manager.drawingArc))) {
      ((Arc)manager.arcs.get(manager.arcs.size()-1)).newVertex(mouseX, mouseY);
    }

    if (manager.mouseInsidePlace!=null && manager.drawingArc) {
      if (((Arc)manager.arcs.get(manager.arcs.size()-1)).fromType.equals("Transition")) {
        manager.drawingArc=false;
       ((Arc)manager.arcs.get(manager.arcs.size()-1)).to=manager.mouseInsidePlace.id;
       ((Arc)manager.arcs.get(manager.arcs.size()-1)).toPlace=manager.mouseInsidePlace;
       } 
   }

    if (manager.mouseInsideTransition!=null && manager.drawingArc) {
      if (((Arc)manager.arcs.get(manager.arcs.size()-1)).fromType.equals("Place")) {
        manager.drawingArc=false;
        ((Arc)manager.arcs.get(manager.arcs.size()-1)).to=manager.mouseInsideTransition.id;
        ((Arc)manager.arcs.get(manager.arcs.size()-1)).toTransition=manager.mouseInsideTransition;

      } 
     
    }
  }

  //When we have just created a place or transition
  //and we are miving then
  if (manager.placeCreated) {
    manager.placeCreated=false;
    manager.mouseClicked=false;
  } 

  if (manager.transitionCreated) {
    manager.transitionCreated=false;
    manager.mouseClicked=false;
  }
}

void mouseDragged() {
  (manager.utilBox).mouseDragged=true; 
  manager.mouseDragged=true;
}


void mouseReleased() {
  (manager.utilBox).mouseDragged=false;
  (manager.utilBox).moveOn=false;
  manager.mouseDragged=false;
  manager.placeDragged=null;
  manager.transitionDragged=null;
}

