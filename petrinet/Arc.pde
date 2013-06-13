class Arc {

  ArrayList verteces = new ArrayList();

  String from;
  String fromType;
  String to;
  Place fromPlace=null;
  Transition fromTransition=null;
  
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
    if(fromType.equals("Place"))  curveVertex(fromPlace.pos.x, fromPlace.pos.y);
    if(fromType.equals("Transition"))  curveVertex(fromTransition.pos.x, fromTransition.pos.y);

    for (int i=0; i<verteces.size(); i++) {
      curveVertex(((PVector)verteces.get(i)).x, ((PVector)verteces.get(i)).y);
    }
    curveVertex(((PVector)verteces.get(verteces.size()-1)).x, ((PVector)verteces.get(verteces.size()-1)).y);
    endShape();
  }
}

