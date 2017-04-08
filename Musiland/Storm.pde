//import ddf.minim.*;

// Thanks to Esteban Hufstedler for his lighning storm project
// https://www.openprocessing.org/sketch/2924

class Storm {

  ArrayList<TreeLightning> allLightning = new ArrayList<TreeLightning>();

  //AudioPlayer thunderSound;
  float minGain = -40;
  float maxGain = 5;
  float thunderAmp = 0;
  float decreasingVolume = 0.995;

  float minDTheta = PI/16;
  float maxDTheta = PI/8;
  float childGenOdds = 0.015;
  float maxTheta = PI/4;

  float minThickness = 7;
  float maxThickness = 14;

  float minJumpLength = 0.01;
  float maxJumpLength = 0.03;

  int minLifeDuration = 500;
  int maxLifeDuration = 2000;

  //void init(Musiland m, String folder, String fileName) {
  //  thunderSound = new Minim(m).loadFile(folder+"/"+fileName);
  //  thunderSound.loop();
  //  thunderSound.setGain(getGain(0));
  //}

  float getGain(float amp) { // 0 <= amp <= 1
    return minGain-1+pow(maxGain-minGain+1, amp);
  }

  class TreeLightning {
    PVector pos;
    TreeLightning child0;
    TreeLightning child1;
    int lifeDuration;
    int deathTime;
    float thickness;

    TreeLightning(PVector pos, float thickness, float theta, float thetaZ, int lifeDuration) {
      this.pos = pos;
      this.thickness = thickness;
      this.lifeDuration = lifeDuration;
      deathTime = millis() + lifeDuration;
      if (pos.z>0 && pos.x>-1 && pos.x<1 && pos.y>-1 && pos.y<1)
        createChild(theta, thetaZ);
    }

    void createChild(float theta, float thetaZ)
    {   
      theta = getNewTheta(theta);
      thetaZ = getNewTheta(thetaZ);
      float length = random(minJumpLength, maxJumpLength);
      PVector posChild = new PVector(pos.x+length*cos(theta-HALF_PI), 
        pos.y+length*cos(thetaZ-HALF_PI), 
        pos.z-length*sin(theta-HALF_PI)*sin(thetaZ-HALF_PI));
      child0 = new TreeLightning(posChild, thickness, theta, thetaZ, lifeDuration);
      if (random(1)<childGenOdds)
        child1 = new TreeLightning(posChild, thickness, getNewTheta(theta), getNewTheta(thetaZ), lifeDuration);
    }

    float getNewTheta(float theta) {
      return min(max(theta+randomSign()*random(minDTheta, maxDTheta), -maxTheta), maxTheta);
    }

    int randomSign() {
      return random(1)>0.5 ? 1 : -1;
    }

    void drawLightning(PVector scale) {
      strokeWeight(max(0, pos.z)*thickness);
      if (child0 != null) {
        drawLine(pos, child0.pos, scale);
        child0.drawLightning(scale);
      }
      if (child1 != null) {
        drawLine(pos, child1.pos, scale);
        child1.drawLightning(scale);
      }
    }

    void drawLine(PVector p1, PVector p2, PVector scale) {
      line(p1.x*scale.x, p1.y*scale.y, p1.z*scale.z, 
        p2.x*scale.x, p2.y*scale.y, p2.z*scale.z);
    }

    boolean isDead() {
      return millis()>deathTime;
    }
  }

  void addLightning() {
    addLightning(random(-0.5, 0.5), random(-0.5, 0.5));
  }

  void addLightning(float xPos, float yPos) {
    thunderAmp = 1;
    allLightning.add(new TreeLightning(new PVector(xPos, yPos, 1), 
      random(minThickness, maxThickness), 0, 0, (int)random(minLifeDuration, maxLifeDuration)));
  }

  void drawStorm(PVector scale) {
    thunderAmp*=decreasingVolume;
    //if (thunderSound!=null)
    //  thunderSound.setGain(getGain(thunderAmp));
    for (int i=0; i<allLightning.size(); i++) {
      TreeLightning lightning = allLightning.get(i);
      if (lightning.isDead()) {
        allLightning.remove(i);
        i--;
      } else {
        stroke(255, 255*(float)(lightning.deathTime-millis())/lightning.lifeDuration);
        lightning.drawLightning(scale);
      }
    }
  }

  OnCommand stormCommand = new OnCommand() {

    long lastTick = 0;
    int countSimultaneaousNote = 0;
    int isChordValue = 4;

    int[] crashPitch = {46, 49, 52};

    boolean isCrash(int channel, int pitch) {
      boolean result = false;
      for (int i=0; i<crashPitch.length; i++)
        result = result || pitch == crashPitch[i];
      return result && channel == MidiFileReader.DRUM_CHANNEL;
    }

    void NoteOn(long tick, int channel, int pitch, int velocity, float ratio) {
      if (channel != MidiFileReader.DRUM_CHANNEL) {
        countSimultaneaousNote = lastTick == tick ? countSimultaneaousNote+1 : 0;
        lastTick = tick;
      }
      if (countSimultaneaousNote>isChordValue || isCrash(channel, pitch))
        addLightning();
    }

    void NoteOff(long tick, int channel, int pitch, int velocity) {
    }
  };
}