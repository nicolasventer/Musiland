import de.voidplus.leapmotion.*;

interface ModeController {
  void update(Mode mode);
}

ModeController MouseModeController = new ModeController() {
  float easingCount = 0.6;
  void update(Mode mode) {
    mode.setHandDetected(mouseRight ? 1 : mouseLeft || mousePressed ? -1 : 0);
    countWheel *= easingCount;
    if (mousePressed)
      mode.setPos(map(mouseX, 0, width, 0.5, -0.5), map(mouseY, 0, height, 0.5, -0.5), mode.pos.z+countWheel);
    /*if (mouseButton==CENTER)
     myCamera.resetCameraOn = true;*/
  }
};
// for MouseCameraMover
boolean mouseLeft = false;
boolean mouseRight = false;
void mousePressed() {
  mouseRight = mouseRight || mouseButton==RIGHT;
  mouseLeft = mouseLeft || mouseButton==LEFT;
}
void mouseReleased() {
  mouseRight = mouseRight && mouseButton!=RIGHT;
  mouseLeft = mouseLeft && mouseButton!=LEFT;
}
float countWheel = 0;
void mouseWheel(MouseEvent event) {
  countWheel -= event.getCount() * 0.05;
}

// TODO : update direction
ModeController CameraAutoModeController = new ModeController() {
  PVector pos = new PVector();
  void update(Mode mode) {
    pos.x = 0.1;
    if (mode.autoCameraActivated != 0)
      mode.camera.moveCam(pos);
  }
};


ModeController LeapMotionModeController = new ModeController() {

  float xMin = 200;
  float xMax = 1100;
  float yMin = 0;
  float yMax = 75;
  float zMin = 100;
  float zMax = 500;

  void update(Mode mode) {
    for (Hand hand : leap.getHands ()) {
      PVector handPosition = hand.getPosition();
      mode.setHandDetected(hand.getGrabStrength() > 0.8 ? 1 : -1);
      mode.setPos(map(handPosition.x, xMin, xMax, 0.5, -0.5), map(handPosition.z, yMin, yMax, -0.5, 0.5), map(handPosition.y, zMin, zMax, 0.5, -0.5));
    }
  }
};
// for LeapMotionCameraMover
LeapMotion leap;
void initLeapMotion(Musiland m) {
  leap = new LeapMotion(m);
}

ModeController[] allModeController = {MouseModeController, CameraAutoModeController, LeapMotionModeController};