enum Mode_type {
  MAIN("Mode normal", 1500), UMBRELLA("umbrella", 1), MAN_CAMERA("manual camera", 1), 
    TEMPO("Mode tempo", 2000), ENABLE_AUTO_CAMERA("auto camera enable", 1000), ENABLE_AUTO_FPV("auto FPV enable", 1000), DISABLE_AUTO("auto disable", 1000), RESET_CAMERA("reset camera", 1), 
    FPV("Mode FPV", 2000);

  String text;
  int modeDuration;

  private Mode_type(String text, int modeDuration) {
    this.text = text;
    this.modeDuration = modeDuration;
  }
}

class Mode {

  Mode_type mode = Mode_type.MAIN;
  Mode_type wantedMode = Mode_type.MAIN;
  int autoCameraActivated = 0; // 0 not activated, -1 auto camera, 1 auto FPV

  PVector pos = new PVector();
  boolean posSetted = false;
  float enableXpos = 0.4;
  float zPosTempo = 0;

  private int handDetected = 0; // 0 not detected, -1 opened, 1 closed
  float handTwistedValue = 0;
  float easingHandTwisted = 0.90;
  float isTwistingValue = 1;
  int handDetectedTime = 0;
  int handDetectedDuration = 200;

  int switchTime = 0;

  String musicPlaying;

  Camera camera;
  MidiFileReader midiFileReader;
  Rain rain;
  Storm storm;

  void init(String filenameMidi, Camera c, MidiFileReader m, Rain r, Storm s) {
    musicPlaying = filenameMidi.substring(0, filenameMidi.lastIndexOf("."));
    camera = c;
    midiFileReader = m;
    rain = r;
    storm = s;
  }

  void setPos(float posX, float posY, float posZ) {
    pos.x = constrain(posX, -0.5, 0.5);
    pos.y = constrain(posY, -0.5, 0.5);
    pos.z = constrain(posZ, -0.5, 0.5);
  }

  // return true if the hand is opening or closing
  private boolean isHandStateChanged(int newHandDetected) {
    return handDetected != newHandDetected && handDetected !=0 && newHandDetected != 0;
  }

  void setHandDetected(int newHandDetected) {
    handTwistedValue += isHandStateChanged(newHandDetected) ? 1 : 0;
    handDetected = millis()<handDetectedTime && newHandDetected==0 ? handDetected : newHandDetected;
    handDetectedTime = newHandDetected==0 ? handDetectedTime : millis() + handDetectedDuration;
    posSetted = handDetected != 0 && posSetted;
  }

  boolean isHandTwisting() {
    return handTwistedValue>isTwistingValue;
  }

  void switchMode(Mode_type newMode) {
    if (mode!=newMode)
      wantedMode = newMode;
    if (millis()>switchTime || mode == newMode || (mode == Mode_type.MAIN && !isHandTwisting())) {
      myRain.umbrella.actived = newMode == Mode_type.UMBRELLA;
      switch (newMode) {
      case ENABLE_AUTO_CAMERA:
        autoCameraActivated = -1;
        break;
      case ENABLE_AUTO_FPV:
        autoCameraActivated = 1;
        break;
      case DISABLE_AUTO:
        autoCameraActivated = 0;
        break;
      default:
        break;
      }
      mode = newMode;
      switchTime = millis() + mode.modeDuration;
    }
  }

  void update() {
    setHandDetected(0);
    handTwistedValue *= easingHandTwisted;

    for (ModeController mc : allModeController)
      mc.update(this);

    if (handDetected == 0)
      switchMode(mode == Mode_type.MAN_CAMERA || mode == Mode_type.UMBRELLA ? Mode_type.MAIN : mode);
    else
      if (isHandTwisting())
        switchMode(mode == Mode_type.MAIN ? Mode_type.TEMPO : mode == Mode_type.TEMPO ? Mode_type.FPV : Mode_type.MAIN);
      else {
        if (mode == Mode_type.MAIN || mode == Mode_type.MAN_CAMERA || mode == Mode_type.UMBRELLA)
          switchMode(handDetected>0 ? Mode_type.MAN_CAMERA : Mode_type.UMBRELLA);
        else
          if (mode == Mode_type.TEMPO || mode == Mode_type.ENABLE_AUTO_FPV || mode == Mode_type.ENABLE_AUTO_CAMERA || mode == Mode_type.DISABLE_AUTO || mode == Mode_type.RESET_CAMERA)
            if (abs(pos.x) > enableXpos) 
              switchMode(pos.x<0 ? handDetected>0 ? Mode_type.ENABLE_AUTO_FPV : Mode_type.ENABLE_AUTO_CAMERA : handDetected>0 ? Mode_type.DISABLE_AUTO : Mode_type.RESET_CAMERA);
            else
              switchMode(Mode_type.TEMPO);
          else
            switchMode(Mode_type.FPV);
        move();
      }
  }

  void move() {
    if (mode == Mode_type.MAN_CAMERA && handDetected == 1)
      camera.moveCam(pos);

    if (mode == Mode_type.FPV)
      camera.moveFPV(pos, handDetected == 1);

    if (mode == Mode_type.TEMPO && handDetected == 1 && abs(pos.x) < enableXpos) {
      zPosTempo = pos.z;
      midiFileReader.setTempoFactor(zPosTempo);
    }

    if (mode == Mode_type.UMBRELLA) {
      rain.umbrella.pos.x = pos.x;
      rain.umbrella.pos.y = pos.y;
      rain.umbrella.pos.z = pos.z;
    }

    if (mode == Mode_type.RESET_CAMERA) {
      camera.resetCamera();
    }
  }

  void drawMode() {
    hint(DISABLE_DEPTH_TEST);
    camera();
    noLights();    
    pushMatrix();
    scale(width, height);
    noFill();

    float sizeDraw = 0.17;
    float xDraw = 0.015 + sizeDraw/2;
    float yDraw = 0.99 - xDraw;

    // drawRectPosition
    stroke(255);
    strokeWeight(sizeDraw*0.2);
    rect(xDraw, yDraw, sizeDraw, sizeDraw);
    rect(xDraw+2*sizeDraw/3, yDraw, sizeDraw/12, sizeDraw);
    float zDrawX = xDraw+7.5*sizeDraw/12;
    strokeWeight(sizeDraw*0.3);
    line(zDrawX, yDraw, zDrawX+sizeDraw/12, yDraw);
    if (zPosTempo < 0)
      stroke(255, 0, 0);
    else
      stroke(0, 255, 0);
    if (zPosTempo != 0)
      line(zDrawX, lerp(yDraw, yDraw-sizeDraw, zPosTempo), zDrawX+sizeDraw/12, lerp(yDraw, yDraw-sizeDraw, zPosTempo));

    strokeWeight(sizeDraw*0.15);
    // drawLines
    if (pos.x < -enableXpos)
      stroke(getColorHand());
    else
      stroke(255);
    line(xDraw+enableXpos*sizeDraw, yDraw-sizeDraw/2, xDraw+enableXpos*sizeDraw, yDraw+sizeDraw/2);
    if (pos.x > enableXpos)
      stroke(getColorHand());
    else
      stroke(255);
    line(xDraw-enableXpos*sizeDraw, yDraw-sizeDraw/2, xDraw-enableXpos*sizeDraw, yDraw+sizeDraw/2);

    // drawPosition

    strokeWeight(sizeDraw*0.6);
    stroke(255);
    point(xDraw, yDraw);
    stroke(getColorHand());
    point(lerp(xDraw, xDraw-sizeDraw, pos.x), lerp(yDraw, yDraw-sizeDraw, pos.y));
    strokeWeight(sizeDraw*0.2);
    line(xDraw, yDraw, lerp(xDraw, xDraw-sizeDraw, pos.x), lerp(yDraw, yDraw-sizeDraw, pos.y));
    line(zDrawX, lerp(yDraw, yDraw-sizeDraw, pos.z), zDrawX+sizeDraw/12, lerp(yDraw, yDraw-sizeDraw, pos.z));

    /* drawWind
     translate((float)width/height-1.5*xDraw, yDraw);
     ellipse(0, 0, sizeDraw/2, sizeDraw/2);
     rotate(rain.windTheta-HALF_PI);
     rect(0, -rain.wind.rate*50*sizeDraw, sizeDraw/2, rain.wind.rate*100*sizeDraw);
     drawArraw(0, -rain.wind.rate*100*sizeDraw+sizeDraw, 0, 1);
     //drawArraw((float)width/height-xDraw, yDraw, cos(rain.windTheta), sin(rain.windTheta));
     */
    popMatrix();

    // printMode
    textSize(160*sizeDraw);
    textAlign(LEFT, BOTTOM);
    float alpha = map (millis(), switchTime-mode.modeDuration, switchTime, 255, 0);
    fill(0, 255, 0, alpha);
    text(mode.text, (xDraw+0.8*sizeDraw)*width, (yDraw+0.55*sizeDraw)*height);
    fill(255, 0, 0, 255-alpha);
    text(wantedMode.text, (xDraw+0.8*sizeDraw)*width, (yDraw+0.55*sizeDraw)*height);

    // printAuto
    textSize(160*sizeDraw);
    textAlign(RIGHT, BOTTOM);
    fill(255, 0, 0);
    if (autoCameraActivated != 0)
      text(autoCameraActivated < 0 ? Mode_type.ENABLE_AUTO_CAMERA.text : Mode_type.ENABLE_AUTO_FPV.text, (1-(xDraw-sizeDraw/2))*width, (yDraw+sizeDraw/2)*height);

    // printTitle
    textSize(180*sizeDraw);
    textAlign(CENTER, TOP);
    fill(255);
    text(musicPlaying, 0.5*width, 0.025*height);

    hint(ENABLE_DEPTH_TEST);
    noStroke();
  }

  color getColorHand() {
    return isHandTwisting() ? color(0, 0, 255) : handDetected>0 ? color(255, 0, 0) : handDetected<0 ? color(0, 255, 0) : color(255);
  }

  String posToString() {
    return handDetected==0 ? "" : roundString(pos.x)+","+roundString(pos.y)+","+roundString(pos.z);
  }

  float roundString(float f) {
    return roundString(f, 1);
  }

  float roundString(float f, int nbFigures) {
    return (float)round(pow(10, nbFigures)*f)/pow(10, nbFigures);
  }

  /*void drawArraw(float x, float y, float dirX, float dirY, float size) {
   triangle(x-size/2*dirY+size*dirX, y-size/2*dirX-size*dirY, 
   x+size/2*dirY+size*dirX, y+size/2*dirX-size*dirY, 
   x+2*size*dirX, y-2*size*dirY);
   }*/
}