class Button {
  static final int RECTANGLE = 0, CIRCLE = 1, TRIANG = 2;

  class Text {

    float sizeText;
    String text;
    boolean actived = false;

    Text(String text, float sizeText) {
      this.sizeText = sizeText;
      this.text = text;
    }

    void drawText(float alpha) {
      if (actived)
        fill(255, 255, 0, alpha);
      else
        fill(255, 0, 0, alpha);
      textSize(sizeText);
      text(text, pos.x*width, pos.y*height);
    }
  }

  PVector pos;
  int type;
  PVector sizeDraw;
  Text t;
  OnButton o;
  color c;

  Button(PVector pos, int type, PVector sizeDraw, String text, float sizeText, OnButton o) {
    this.pos = pos;
    this.type = type;
    this.sizeDraw = new PVector(sizeDraw.x/width, sizeDraw.y/height, sizeDraw.z); //# automatically unscaled with size screen
    this.t = new Text(text, sizeText);
    this.o = o;
  }

  void drawButton(float alpha) {
    fill(c, alpha);
    // drawForm
    switch (type) {
    case RECTANGLE:
      rect(pos.x, pos.y, sizeDraw.x, sizeDraw.y);
      break;
    case CIRCLE:
      ellipse(pos.x, pos.y, sizeDraw.x, sizeDraw.y);
      break;
    case TRIANG:
      drawArraw(pos.x, pos.y, sizeDraw.x/2, sizeDraw.y/2, cos(sizeDraw.z), sin(sizeDraw.z));
      break;
    }
  }

  private void drawArraw(float x, float y, float sizeX, float sizeY, float dirX, float dirY) {
    triangle(x-sizeX/2*dirY-sizeX/2*dirX, y-sizeY/2*dirX+sizeY/2*dirY, 
      x+sizeX/2*dirY-sizeX/2*dirX, y+sizeY/2*dirX+sizeY/2*dirY, 
      x+sizeX/2*dirX, y-sizeY/2*dirY);
  }

  void useButton(Interface i) {
    boolean isInside = pos.x-sizeDraw.x/2<i.pos.x && pos.x+sizeDraw.x/2>i.pos.x && pos.y-sizeDraw.y/2<i.pos.y && pos.y+sizeDraw.y/2>i.pos.y; //# only considering rectangle
    if (isInside) {
      c = color(0, 0, 255, 150);
      o.use(this, i);
    } else
      c = color(255, 100);
  }
}

interface OnButton {
  void use(Button b, Interface i);
}

//# defaultOnButton
OnButton nothingOnButton = new OnButton() {
  void use(Button b, Interface i) {
  }
};

OnButton moveCamOnButton = new OnButton() {
  void use(Button b, Interface i) {
    i.camera.moveCam(b.pos);
  }
};

OnButton zoomCamOnButton = new OnButton() {
  void use(Button b, Interface i) {
    i.camera.moveCam(new PVector(0.5, 0.55, (Interface.zoomX-b.pos.x)/Interface.zoomXdiff*0.5));
  }
};

OnButton tempoOnButton = new OnButton() {
  void use(Button b, Interface i) {
    i.midiFileReader.changeTempo((Interface.tempoX-b.pos.x)/Interface.tempoXdiff*0.01);
  }
};

OnButton activeOnButton = new OnButton() {
  int lastTimeActivation = 0;
  int activationDuration = 500;
  void use(Button b, Interface i) {
    if (millis()>lastTimeActivation+activationDuration) {
      b.t.actived = !b.t.actived;
      if (b.t.text == "umbrella")
        i.rain.umbrella.actived = b.t.actived;
      if (b.t.text == "auto camera")
        i.camera.activeAutoCamera(b.t.actived);
    }
    lastTimeActivation = millis();
  }
};

OnButton resetCamOnButton = new OnButton() {
  void use(Button b, Interface i) {
    i.camera.resetCamera();
  }
};