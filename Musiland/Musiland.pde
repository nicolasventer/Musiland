//# create instance of each class
Camera myCamera = new Camera();
Grid myGrid = new Grid();
MidiFileReader myMidiFileReader = new MidiFileReader();
Interface myInterface = new Interface();
Rain myRain = new Rain();
Storm myStorm = new Storm();
Sun mySun = new Sun();
Timer myTimer = new Timer();

void setup()
{
  //# init setup
  initLeapMotion(this);
  //size(1250, 750, P3D);
  fullScreen(P3D);
  background(0);
  noStroke();
  rectMode(CENTER);
  ellipseMode(CENTER);
  textAlign(CENTER, CENTER);
  noCursor();

  //# init all instances
  myGrid.init();
  setSizeBox(myCamera.eyeZ);
  //String folderWeather = sketchPath()+"/_weatherSongs";
  //String fileNameRain = "rain 1.mp3";
  //myRain.init(this, folderWeather, fileNameRain);
  //String fileNameStorm = "thunder 2.mp3";
  //myStorm.init(this, folderWeather, fileNameStorm);
  String folderMidi = sketchPath()+"/_midiSongs";
  String fileNameMidi = "Joplin - Maple leaf rag.midi"; //# choose music here
  myInterface.init(fileNameMidi, myCamera, myMidiFileReader, myRain, myStorm);
  myMidiFileReader.openMidiFile(folderMidi, fileNameMidi);

  //# setup the start
  myTimer.addFunction("launchSequencer", startWaitMs, launchSequencer);
}

//# size of the draw box in 3D world
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
  //# exit the program at the end of the music
  myTimer.check();
  if (myMidiFileReader.getTickRate()==1 && !myTimer.containsFunction("exitProgram"))
    myTimer.addFunction("exitProgram", endWaitMs, exitProgram);

  myMidiFileReader.getCurrentMessage();

  background(0);
  myInterface.update();
  myCamera.autoCamera();
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

  //# the 2D interface has to be drawn at the end
  myInterface.drawInterface();
}

//# take screenshot
int numScreenshot = 0;
void keyPressed() {
  if (key == 's') {
    save("screenshot"+numScreenshot+".jpg");
    println("screenShot "+numScreenshot++);
  }
}