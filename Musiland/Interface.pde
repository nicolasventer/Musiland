class Interface {

  PVector pos = new PVector();
  PVector lastPos = new PVector();
  int lastTimeMove = 0;
  int moveDuration = 10000;
  int fadeOutDuration = 5000;

  String musicPlaying;

  Camera camera;
  MidiFileReader midiFileReader;
  Rain rain;
  Storm storm;

  ArrayList<Button> allButton = new ArrayList<Button>();

  void init(String filenameMidi, Camera c, MidiFileReader m, Rain r, Storm s) {
    musicPlaying = filenameMidi.substring(0, filenameMidi.lastIndexOf("."));
    camera = c;
    midiFileReader = m;
    rain = r;
    storm = s;
    addAllButton();
  }

  static final float zoomX = 0.16;
  static final float zoomXdiff = 0.02;
  static final float tempoX = 0.925;
  static final float tempoXdiff = 0.015;

  //# sizeText proportionnal to width
  //# sizeButton proprotionnal to width if text inside
  void addAllButton() {
    // addTitle
    allButton.add(new Button(new PVector(0.5, 0.08), Button.RECTANGLE, new PVector(), musicPlaying, 0.032*width, nothingOnButton));
    // addCameraControl
    allButton.add(new Button(new PVector(0.9, 0.55), Button.TRIANG, new PVector(75, 75, 0), "", 1, moveCamOnButton));
    allButton.add(new Button(new PVector(0.5, 0.2), Button.TRIANG, new PVector(75, 75, HALF_PI), "", 1, moveCamOnButton));
    allButton.add(new Button(new PVector(0.1, 0.55), Button.TRIANG, new PVector(75, 75, PI), "", 1, moveCamOnButton));
    allButton.add(new Button(new PVector(0.5, 0.9), Button.TRIANG, new PVector(75, 75, -HALF_PI), "", 1, moveCamOnButton));
    allButton.add(new Button(new PVector(0.08, 0.2), Button.RECTANGLE, new PVector(), "zoom", 0.024*width, nothingOnButton));
    allButton.add(new Button(new PVector(zoomX-zoomXdiff, 0.2), Button.CIRCLE, new PVector(0.03*width, 0.03*width), "+", 0.026*width, zoomCamOnButton));
    allButton.add(new Button(new PVector(zoomX+zoomXdiff, 0.2), Button.CIRCLE, new PVector(0.03*width, 0.03*width), "-", 0.026*width, zoomCamOnButton));
    // addAutoCamera
    allButton.add(new Button(new PVector(0.9, 0.95), Button.RECTANGLE, new PVector(0.12*width, 0.03*width), "auto camera", 0.019*width, activeOnButton));
    // addResetCamera
    allButton.add(new Button(new PVector(0.1, 0.95), Button.RECTANGLE, new PVector(0.12*width, 0.03*width), "reset camera", 0.019*width, resetCamOnButton));
    // addUmbrella
    allButton.add(new Button(new PVector(0.1, 0.1), Button.RECTANGLE, new PVector(0.1*width, 0.03*width), "umbrella", 0.019*width, activeOnButton));
    // addTempo
    allButton.add(new Button(new PVector(0.86, 0.1), Button.RECTANGLE, new PVector(), "tempo", 0.021*width, nothingOnButton));
    allButton.add(new Button(new PVector(tempoX-tempoXdiff, 0.1), Button.CIRCLE, new PVector(0.027*width, 0.027*width), "+", 0.024*width, tempoOnButton));
    allButton.add(new Button(new PVector(tempoX+tempoXdiff, 0.1), Button.CIRCLE, new PVector(0.027*width, 0.027*width), "-", 0.024*width, tempoOnButton));
  }

  //# condition for activating button
  boolean buttonIsActived(Button b) {
    return (b.t.text == "umbrella" || b.t.text == musicPlaying ||  b.t.text == "auto camera") || !rain.umbrella.actived && (b.pos.y == 0.1 || !camera.autoCameraActived);
  }

  void update() {
    for (InterfaceController i : allInterfaceController)
      i.update(this);
    if (!pos.equals(lastPos)) {
      lastPos.x = pos.x;
      lastPos.y = pos.y;
      lastTimeMove = millis();
    }
    rain.umbrella.pos.x = 0.5-pos.x;
    rain.umbrella.pos.y = 0.5-pos.y;
    for (Button b : allButton)
      if (buttonIsActived(b))
        b.useButton(this);
  }

  void drawInterface() {
    noStroke();
    hint(DISABLE_DEPTH_TEST);
    camera();
    noLights(); 
    pushMatrix();
    scale(width, height);
    float alpha = constrain(map(millis(), lastTimeMove+moveDuration+fadeOutDuration, lastTimeMove+moveDuration, 0, 255), 0, 255);

    // drawAllButton
    for (Button b : allButton)
      if (buttonIsActived(b))
        b.drawButton(alpha);

    // drawPoint 
    fill(255, alpha);
    ellipse(pos.x, pos.y, 19f/width, 19f/height);
    popMatrix();

    // drawAllText
    for (Button b : allButton) {
      if (buttonIsActived(b))
        b.t.drawText(alpha);
    }
    hint(ENABLE_DEPTH_TEST);
    noStroke();
  }
}