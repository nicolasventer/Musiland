Camera myCamera = new Camera();
Grid myGrid = new Grid();
MidiFileReader myMidiFileReader = new MidiFileReader();
Mode myMode = new Mode();
Rain myRain = new Rain();
Storm myStorm = new Storm();
Sun mySun = new Sun();
Timer myTimer = new Timer();

void setup()
{
  initLeapMotion(this);
  //size(1250, 750, P3D);
  fullScreen(P3D);
  myGrid.init();
  setSizeBox(myCamera.eyeZ);
  background(0);
  noStroke();
  rectMode(CENTER);
  ellipseMode(CENTER);
  //String folderWeather = sketchPath()+"/_weatherSongs";
  //String fileNameRain = "rain 1.mp3";
  //myRain.init(this, folderWeather, fileNameRain);
  //String fileNameStorm = "thunder 2.mp3";
  //myStorm.init(this, folderWeather, fileNameStorm);
  String folderMidi = sketchPath()+"/_midiSongs";
  String fileNameMidi = "cannondmjrjazz(all).mid"; //# choose music here
  myMode.init(fileNameMidi, myCamera, myMidiFileReader, myRain, myStorm);
  myMidiFileReader.openMidiFile(folderMidi, fileNameMidi);

  myTimer.addFunction("launchSequencer", startWaitMs, launchSequencer);
}

PVector sizeBox;
void setSizeBox(float zDist) {
  sizeBox = new PVector();
  float ratioXY = (float)width/height;
  sizeBox.y = 1.15*zDist/1.5;
  sizeBox.x = ratioXY*sizeBox.y;
  sizeBox.z = sizeBox.mag()/4;
}

int startWaitMs = 3500;
int endWaitMs = 5000;


void draw() {
  myTimer.check();
  if (myMidiFileReader.getTickRate()==1 && !myTimer.containsFunction("exitProgram"))
    myTimer.addFunction("exitProgram", endWaitMs, exitProgram);

  myMidiFileReader.getCurrentMessage();

  background(0);
  myMode.update();
  myCamera.placeCamera();

  mySun.setSunPosition(sizeBox, myMidiFileReader.getTickRate());
  mySun.drawSun(sizeBox.z/15);
  directionalLight(100, 100, 100, 0, 0, -1);

  myGrid.drawGrid(sizeBox);
  myGrid.updateGrid();

  myRain.drawRain(sizeBox);
  myRain.updateRain();
  myRain.umbrella.drawUmbrella(sizeBox);

  myStorm.drawStorm(sizeBox);
  myMode.drawMode();
}

//# take screenshot
int numScreenshot = 0;
void keyPressed() {
  if (key == 's') {
    save("screenshot"+numScreenshot+".jpg");
    println("screenShot "+numScreenshot++);
  }
}