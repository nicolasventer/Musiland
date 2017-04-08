class Grid {

  class NoteActivator {
    int i;
    int j;
    float targetValue;
    float easing;
    int radiusGrid;

    NoteActivator(int i, int j, float value, float easing, int radiusGrid) {
      this.i = i;
      this.j = j;
      this.targetValue = value;
      this.easing = easing;
      this.radiusGrid = radiusGrid;
    }
  }

  HashMap<PVector, NoteActivator> noteActivators = new HashMap<PVector, NoteActivator>(); // {channel,pitch} -> NoteActivator

  PVector sizeGrid;
  float grid[][];
  float basicRadiusGrid;

  void init() {
    int resolution = 300;
    sizeGrid = new PVector(resolution, (int)(resolution*height/width));
    grid = new float[(int)sizeGrid.x][(int)sizeGrid.y];
    basicRadiusGrid = sqrt(sizeGrid.x*sizeGrid.y)/5;
  }

  void drawGrid(PVector scale) {
    for (int i=0; i<sizeGrid.x-1; i++) {
      for (int j=0; j<sizeGrid.y-1; j++) {
        fill(getRedGridColor(grid[i][j]), getGreenGridColor(grid[i][j]), getBlueGridColor(grid[i][j]));
        beginShape(QUAD);
        applyVertex(scale, i, j);
        applyVertex(scale, i+1, j);
        applyVertex(scale, i+1, j+1);
        applyVertex(scale, i, j+1);
        endShape();
      }
    }
  }

  void applyVertex(PVector scale, int i, int j) {
    vertex((i-sizeGrid.x/2)/sizeGrid.x*scale.x, 
      (j-sizeGrid.y/2)/sizeGrid.y*scale.y, 
      grid[i][j]*scale.z);
  }

  // -1 <= x <= 1
  float getRedGridColor(float x) {
    return 190*pow(x, 3)-235*x+74;
  }
  float getGreenGridColor(float x) {
    return -33*pow(x, 3) +165*x+87;
  }
  float getBlueGridColor(float x) {
    return -64*pow(x, 3)+80*x+18.5;
  }

  void updateGrid() {
    for (int i=0; i<sizeGrid.x; i++)
      for (int j=0; j<sizeGrid.y; j++)
        grid[i][j]*=0.995;
    for (NoteActivator na : noteActivators.values()) {
      float toAdd = (na.targetValue-grid[na.i][na.j])*na.easing;
      for (int a=-na.radiusGrid; a<=na.radiusGrid; a++)
        for (int b=-na.radiusGrid; b<=na.radiusGrid; b++) {
          if (na.i+a>=0 && na.i+a<sizeGrid.x && na.j+b>=0 && na.j+b<sizeGrid.y)
            grid[na.i+a][na.j+b]+=toAdd*toAddRatio(sqrt((a*a+b*b)/2)/(0.001+na.radiusGrid));
        }
    }
  }

  float toAddRatio(float ratioDist) { // 0 <= ratioDist <= 1
    float result = -1.78*pow(ratioDist, 4)
      +5.5*pow(ratioDist, 3)
      -4.8*pow(ratioDist, 2)
      +0.03*ratioDist
      +1;
    return result;
  }

  OnCommand impactCommand = new OnCommand() {

    int minPitch = 33;
    int middlePitch = 53;
    int maxPitch = 96;
    int middleVelocity = 64;

    float maxValue = 0.7;

    float basicDistance = 50;
    float randomSeed = 0.03;

    class LastNote {
      int pitch;
      PVector position;
      PVector randomAdd;

      LastNote(int pitch, PVector position, PVector randomAdd) {
        this.pitch = pitch;
        this.position = position;
        this.randomAdd = randomAdd;
      }
    }

    HashMap<Integer, LastNote> lastNotes = new HashMap<Integer, LastNote>(); // channel, lastNote

    void NoteOn(long tick, int channel, int pitch, int velocity, float ratio) {
      float ratioPitch = norm(pitch, minPitch, maxPitch);
      float ratioToMiddlePitch = abs(norm(pitch, middlePitch, maxPitch));
      float ratioVelocity = (float)velocity/middleVelocity;
      PVector position = getPosition(channel, pitch);
      float targetValue = (pitch > middlePitch ? maxValue : -maxValue) * ratio;
      float easing = 0.005+0.07*pow(ratioToMiddlePitch, 0.8)*pow(ratioVelocity, 2);
      int radiusGrid = (int)(basicRadiusGrid*pow(max(0, 1-ratioPitch), 0.7));
      if (tick!=0)
        noteActivators.put(new PVector(channel, pitch), new NoteActivator((int)position.x, (int)position.y, targetValue, easing, radiusGrid));
    }

    PVector getPosition(int channel, int pitch) {
      LastNote ln = lastNotes.get(channel);
      if (ln == null)
        ln = new LastNote(pitch, new PVector(random(sizeGrid.x), random(sizeGrid.y)), new PVector());
      else {
        ln.randomAdd.x = random(-1, 1)*randomSeed+ln.randomAdd.x*(1-randomSeed);
        ln.randomAdd.y = random(-1, 1)*randomSeed+ln.randomAdd.y*(1-randomSeed);
        ln.position.add(PVector.mult(ln.randomAdd, basicDistance*abs(pitch-ln.pitch))); //# difference notes' position proportionnal notes' pitch
        ln.position.x = (ln.position.x%(sizeGrid.x-1)+sizeGrid.x-1)%(sizeGrid.x-1);
        ln.position.y = (ln.position.y%(sizeGrid.y-1)+sizeGrid.y-1)%(sizeGrid.y-1);
        ln.pitch = pitch;
      }
      lastNotes.put(channel, ln);
      return ln.position;
    }

    void NoteOff(long tick, int channel, int pitch, int velocity) {
      noteActivators.remove(new PVector(channel, pitch));
    }
  };
}