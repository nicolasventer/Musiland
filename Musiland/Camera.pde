class Camera {

  PVector defaultAngCenter = new PVector(1, 0, 2.9);
  PVector defaultAngEye = new PVector();
  PVector defaultCenter = new PVector();
  float defaultEyeZ = 300;

  PVector angCenter = defaultAngCenter.copy();
  PVector angEye = defaultAngEye.copy();
  PVector center = defaultCenter.copy();
  float eyeZ = defaultEyeZ;

  PVector up = new PVector(0, 1, 0);

  PVector sensiCam = new PVector(-0.2, -0.1, -30);
  PVector sensiFPV = new PVector(-0.05, 0.05, -50);

  void placeCamera() {
    camera(0, 0, 0, 0, 0, -eyeZ, up.x, up.y, up.z);
    translate(center.x, center.y, center.z);
    rotateX(angEye.x);
    rotateY(angEye.y);
    translate(0, 0, -eyeZ);
    rotateX(angCenter.x);
    rotateZ(angCenter.z);
  }

  PVector posReset = new PVector();

  void resetCamera() {
    if (!angEye.equals(defaultAngEye)) {
      println("angering eye");
      PVector epsilonAngEye = new PVector(0.05, 0.05, 0);
      reseting(angEye, defaultAngEye, epsilonAngEye);
      println(angEye);
    } else
      if (!center.equals(defaultCenter)) {
        println("centering");
        PVector epislonCenter = new PVector(1, 1, 1);
        reseting(center, defaultCenter, epislonCenter);
        println(center);
      } else
        if (!angCenter.equals(defaultAngCenter)) {
          println("angering center");
          PVector epsilonAngCenter = new PVector(0.05, 0, 0.05);
          reseting(angCenter, defaultAngCenter, epsilonAngCenter);
          println(angCenter);
        }
  }

  void reseting(PVector values, PVector defaultValues, PVector epsilonValues) {
    values.add(PVector.sub(defaultValues, values).mult(0.08));
    values.x = abs(defaultValues.x-values.x) < epsilonValues.x ? defaultValues.x : values.x;
    values.y = abs(defaultValues.y-values.y) < epsilonValues.y ? defaultValues.y : values.y;
    values.z = abs(defaultValues.z-values.z) < epsilonValues.z ? defaultValues.z : values.z;
  }

  float getSign(float value, float epsilon) {
    return abs(value) < epsilon ? 0 : abs(value)/value;
  }

  void moveCam(PVector pos) {
    angCenter.z = (angCenter.z+pos.x*sensiCam.x)%(2*PI);
    angCenter.x = (angCenter.x+pos.z*sensiCam.y)%(2*PI);
    eyeZ = max(100, eyeZ+pos.y*sensiCam.z);
  }

  PVector translationVector = new PVector();

  void moveFPV(PVector pos, boolean translation) {
    translationVector.x = -sin(angEye.y)*sin(angCenter.z)*sensiFPV.z;
    translationVector.y = cos(angEye.x)*cos(angEye.y)*cos(angCenter.x)*cos(angCenter.z)*sensiFPV.z;
    translationVector.z = sin(angEye.x)*cos(angEye.y)*sin(angCenter.x)*cos(angCenter.z)*sensiFPV.z;
    if (translation) {
      // TODO
      center.x += pos.z*translationVector.x; // *getSign(-sin(angEye.y));
      center.y += pos.z*translationVector.y; // *getSign cos(angEye.x)*cos(angEye.y));
      center.z += pos.z*translationVector.z; // *getSign(sin(angEye.x)*cos(angEye.y));

      center.z += pos.x*translationVector.x;
      center.x += pos.x*translationVector.y;
      center.y += pos.x*translationVector.z;
      /*
      center.x += pos.y*translationVector.z + (translation ? pos.z*translationVector.x + pos.x*translationVector.y : 0);
       center.y += pos.y*translationVector.x + (translation ? pos.z*translationVector.y + pos.x*translationVector.z : 0);
       center.z += pos.y*translationVector.y + (translation ? pos.z*translationVector.z + pos.x*translationVector.x : 0);
       */
    } else {
      angEye.y = (angEye.y+pos.x*sensiFPV.x)%(2*PI);
      angEye.x = (angEye.x+pos.z*sensiFPV.y)%(2*PI);
    }
    center.y += pos.y*translationVector.x;
    center.z += pos.y*translationVector.y;
    center.x += pos.y*translationVector.z;
  }
}