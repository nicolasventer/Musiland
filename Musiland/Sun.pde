class Sun {
  PVector sun = new PVector(0, 0, 0);
  float minAng = PI/6;
  float maxAng = 5*PI/6;

  void setSunPosition(PVector scale, float tickRate) {
    float currentAng = minAng+(maxAng-minAng)*tickRate;
    sun.x = scale.x*cos(currentAng)/2;
    sun.y = scale.y*cos(currentAng)/2;
    sun.z = scale.z*sin(currentAng);
  }

  void drawSun(float sizeSun) {
    pushMatrix();
    translate(sun.x, sun.y, sun.z);
    fill(#edda31);
    sphere(sizeSun);
    popMatrix();
    pointLight(255, 255, 255, sun.x, sun.y, sun.z);
  }
}