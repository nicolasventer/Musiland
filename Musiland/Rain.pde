//import ddf.minim.*;

class Rain {

  class NoteRate {
    float rate = 0;
    int timeRate = 0;
    float nbRefAdd;
    float addToTimeRate;
    NoteRate(float nbRefAdd, float addToTimeRate) {
      this.nbRefAdd = nbRefAdd;
      this.addToTimeRate = addToTimeRate;
    }

    void update() {
      timeRate = max(timeRate, millis());
      rate = (float)(timeRate - millis())/(nbRefAdd*addToTimeRate);
    }
  }

  ArrayList<Drop> allDrops = new ArrayList<Drop>();
  int maxDrop = 3;
  float stepDrop = 0.1;
  //AudioPlayer rainSound;
  float minGain = -35;
  float maxGain = 5;

  float minSpeed = 0.04;
  float maxSpeed = 0.1;
  float minThickness = 2;
  float maxThickness = 4;

  NoteRate rain = new NoteRate(2.5, 90);
  NoteRate wind = new NoteRate(1000, 120);

  float currentEasing = 0.02;
  private float currentRate = 0;
  float maxRate = 8;

  float windTheta = HALF_PI;
  float dTheta = 0;
  float dThetaMax = PI/10;
  float randomSeed = 0.05;

  Umbrella umbrella = new Umbrella();

  //void init(Musiland m, String folder, String fileName) {
  //  rainSound = new Minim(m).loadFile(folder+"/"+fileName);
  //  rainSound.loop();
  //  rainSound.setGain(getGain(0));
  //}

  float getGain(float amp) { // 0 <= amp <= 1
    println(amp);
    return minGain-1+pow(maxGain-minGain+1, amp);
  }

  class Drop {
    PVector position;
    float speedZ;
    float thickness;
    color cStart;
    color cEnd; 
    int level;

    private float lengthDrop;

    Drop(PVector position, float speedZ, float thickness, color cStart, color cEnd, int level) {
      this.position = position;
      this.speedZ = speedZ;
      this.thickness = thickness;
      this.cStart = cStart;
      this.cEnd = cEnd;
      this.level = level;
      lengthDrop = 4+10*speedZ*thickness;
    }

    void drawDrop(PVector scale) {
      for (float j=0; j<lengthDrop; j+=stepDrop) {
        float ratio = norm(j, lengthDrop, 0);
        strokeWeight(thickness*ratio*sqrt(level/allOnDrop.length+1));
        stroke(allOnDrop[level].getColor(cStart, cEnd, ratio), 255*ratio);
        point(position.x*scale.x, 
          position.y*scale.y, 
          (position.z+speedZ*j)*scale.z);
      }
    }

    void updateDrop() {
      position.z -= speedZ;
      position.x += wind.rate*cos(windTheta);
      position.y += wind.rate*sin(windTheta);
    }

    boolean isDead() {
      return position.z<0;
    }
  }

  private void addDrop() {
    int nbDrops = (int)(maxDrop * pow(currentRate, 0.4));
    for (int i=0; i<nbDrops; i++)
      allDrops.add(new Drop(new PVector(random(-0.5, 0.5)-wind.rate*cos(windTheta)*15, random(-0.5, 0.5)-wind.rate*sin(windTheta)*15, 1), 
        random(minSpeed, maxSpeed), random(minThickness, maxThickness), color(random(255), random(255), random(255)), color(random(255), random(255), random(255)), (int)currentRate%allOnDrop.length));
  }

  void drawRain(PVector scale) {
    for (int i=0; i<allDrops.size(); i++) {
      Drop drop = allDrops.get(i);
      drop.drawDrop(scale);
      drop.updateDrop();
      if (drop.isDead() || umbrella.killDrop(drop.position, drop.speedZ, drop.thickness, allOnDrop[drop.level].getColor(drop.cStart, drop.cEnd, 0))) {
        allDrops.remove(i);
        i--;
      }
    }
  }

  void updateRain() {
    rain.update();
    dTheta = random(-dThetaMax, dThetaMax)*randomSeed+dTheta*(1-randomSeed);
    windTheta += dTheta;
    wind.update();
    currentRate = currentRate + (rain.rate - currentRate)*currentEasing;
    //if (rainSound!=null)
    //  rainSound.setGain(getGain(pow(currentRate/maxRate, 0.2)));
    addDrop();
  }

  OnCommand rainCommand = new OnCommand() {
    int lowestHighPitch = 60;
    int highestLowPitch = 65;

    void NoteOn(long tick, int channel, int pitch, int velocity, float ratio) {
      rain.timeRate += (pitch>lowestHighPitch && channel != MidiFileReader.DRUM_CHANNEL ? rain.addToTimeRate : 0) * ratio;
      wind.timeRate += (pitch<highestLowPitch && channel != MidiFileReader.DRUM_CHANNEL ? wind.addToTimeRate : 0) * ratio;
    }

    void NoteOff(long tick, int channel, int pitch, int velocity) {
    }
  };
}