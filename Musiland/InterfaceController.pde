import de.voidplus.leapmotion.*;

interface InterfaceController {
  void update(Interface i);
}

InterfaceController mouseInterfaceController = new InterfaceController() {
  void update(Interface i) {
    i.pos.x = norm(mouseX, 0, width);
    i.pos.y = norm(mouseY, 0, height);
  }
};

InterfaceController leapMotionInterfaceController = new InterfaceController() {
  float xMin = 650;
  float xMax = 1550;
  float yMin = 75;
  float yMax = 0;
  void update(Interface i) {
    for (Hand hand : leap.getHands ()) {
      PVector handPosition = hand.getPosition();
      i.pos.x = norm(handPosition.x, xMin, xMax);
      i.pos.y = norm(handPosition.z, yMin, yMax);
    }
  }
};
// for LeapMotionCameraMover
LeapMotion leap;
void initLeapMotion(Musiland m) {
  leap = new LeapMotion(m);
}


InterfaceController[] allInterfaceController = {mouseInterfaceController, leapMotionInterfaceController};