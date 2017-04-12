class Umbrella {

  PVector pos = new PVector();
  PVector size = new PVector(0.4, 0.4);
  boolean actived = false;

  class Impact {
    float relPosX;
    float relPosY;
    float startTime;
    float duration;
    float radius;
    color c;

    Impact(PVector position, float speedZ, float thickness, color c) {
      relPosX = position.x-pos.x;
      relPosY = position.y-pos.y;
      startTime = millis();
      duration = 100f/speedZ;
      radius = thickness*duration/1000000;
      this.c = c;
    }

    void drawImpact(PVector scale) {
      fill(c, map(millis(), startTime, startTime+duration, 255, 0));
      ellipse(relPosX*scale.x, relPosY*scale.y, radius*scale.x, radius*scale.x);
    }

    boolean isDead() {
      return millis()>startTime+duration;
    }
  }

  ArrayList<Impact> allImpact = new ArrayList<Impact>();

  void drawUmbrella(PVector scale) {
    if (actived) {
      fill(255, 150);
      pushMatrix();
      translate(pos.x*scale.x, pos.y*scale.y, (pos.z+0.5)*scale.z);
      box(size.x*scale.x, size.y*scale.y, 1);
      translate(0, 0, 1);
      for (int i=0; i<allImpact.size(); i++) {
        Impact imp = allImpact.get(i);
        imp.drawImpact(scale);
        if (imp.isDead()) {
          allImpact.remove(i);
          i--;
        }
      }
      popMatrix();
    }
  }

  boolean killDrop(PVector position, float speedZ, float thickness, color c) {
    boolean result = actived && (position.x>pos.x-size.x/2 && position.x<pos.x+size.x/2 && position.y>pos.y-size.y/2 && position.y<pos.y+size.y/2 && position.z<pos.z);
    if (result)
      allImpact.add(new Impact(position, speedZ, thickness, c));
    return result;
  }
};