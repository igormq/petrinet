class Arc {

  ArrayList verteces = new ArrayList();

  String from;
  String fromType;
  String to="";
  Place fromPlace=null;
  Transition fromTransition=null;
  Place toPlace;
  Transition toTransition;

  int index;

  Arc(String from, String fromType) {
    this.from=from;
    this.fromType=fromType;
  }


  void newVertex(int x, int y) {
    verteces.add(new PVector(x, y));
  }






  void draw() {
    noFill();
    beginShape();
    println(verteces.size());
    if (fromPlace!=null) {
      curveVertex(fromPlace.pos.x, fromPlace.pos.y);
      curveVertex(fromPlace.pos.x, fromPlace.pos.y);
    }
    if (fromTransition!=null) {
      curveVertex(fromTransition.pos.x, fromTransition.pos.y);  
      curveVertex(fromTransition.pos.x, fromTransition.pos.y);
    }
    if(verteces.size()!=0){
    for (int i=0; i<verteces.size(); i++) {
      curveVertex(((PVector)verteces.get(i)).x, ((PVector)verteces.get(i)).y);
    }
    }
    if(to.equals("")){
     curveVertex(mouseX,mouseY);
     curveVertex(mouseX,mouseY); 
    }
    
    if (toPlace!=null) {
      PVector tail = new PVector(toPlace.pos.x, toPlace.pos.y);
       curveVertex(tail.x, tail.y);
      curveVertex(tail.x, tail.y);
    }
    if (toTransition!=null) {
      curveVertex(toTransition.pos.x, toTransition.pos.y);  
      curveVertex(toTransition.pos.x, toTransition.pos.y);
    }
    endShape();
  }
}

