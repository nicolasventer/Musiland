class Camera {

  PVector defaultAngCenter = new PVector(1, 0, 2.9);
  float defaultEyeZ = 300;

  PVector angCenter = defaultAngCenter.copy();
  float eyeZ = defaultEyeZ;

  float eyeZmin = defaultEyeZ/2;
  float eyeZmax = defaultEyeZ*2;
  float angXmin = 0;
  float angXmax = HALF_PI;

  PVector up = new PVector(0, 1, 0);

  PVector sensiCam = new PVector(-0.2, -0.1, -30);

  PVector epsilonAngCenter = new PVector(0.05, 0, 0.05);
  float epsilonEyeZ = 5;
  float resetEasing = 0.09;

  private boolean autoCameraActived = false;
  float autoCamMoveZ = 0.01;
  float randomSeed = 0.03; //# correspond to the random variability
  float eyeZdir = 0;
  float angXdir = 0;

  void placeCamera() {
    camera(0, 0, 0, 0, 0, -eyeZ, up.x, up.y, up.z);
    translate(0, 0, -eyeZ);
    rotateX(angCenter.x);
    rotateZ(angCenter.z);
  }

  void resetCamera() {
    reseting(angCenter, defaultAngCenter, epsilonAngCenter);
    eyeZ += (defaultEyeZ - eyeZ) * resetEasing;
    eyeZ = abs(defaultEyeZ - eyeZ) < epsilonEyeZ ? defaultEyeZ : eyeZ;
  }

  void reseting(PVector values, PVector defaultValues, PVector epsilonValues) {
    values.add(PVector.sub(defaultValues, values).mult(resetEasing));
    values.x = abs(defaultValues.x-values.x) < epsilonValues.x ? defaultValues.x : values.x;
    values.y = abs(defaultValues.y-values.y) < epsilonValues.y ? defaultValues.y : values.y;
    values.z = abs(defaultValues.z-values.z) < epsilonValues.z ? defaultValues.z : values.z;
  }

  void moveCam(PVector pos) {
    angCenter.z = (angCenter.z+(0.5-pos.x)*sensiCam.x)%(2*PI);
    angCenter.x = constrain(angCenter.x+(0.55-pos.y)*sensiCam.y, angXmin, angXmax);
    eyeZ = constrain(eyeZ+pos.z*sensiCam.z, eyeZmin, eyeZmax);
  }

  void activeAutoCamera(boolean actived) {
    if (actived)
      autoCamMoveZ *= -1; //# change sens when reactivated
    autoCameraActived = actived;
  }

  void autoCamera() {
    if (autoCameraActived) {
      //# camera goes to middle when near to border
      angCenter.z = (angCenter.z+autoCamMoveZ)%(2*PI);
      angXdir = random(angXmin-angCenter.x, angXmax-angCenter.x)*randomSeed + angXdir*(1-randomSeed);
      angCenter.x = constrain(angCenter.x+angXdir/4, angXmin, angXmax);
      eyeZdir = random(eyeZmin-eyeZ, eyeZmax-eyeZ)*randomSeed + eyeZdir*(1-randomSeed);
      eyeZ = constrain(eyeZ+eyeZdir/10, eyeZmin, eyeZmax);
    }
  }
}