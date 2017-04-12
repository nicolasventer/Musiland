interface OnCommand {
  void NoteOn(long tick, int channel, int pitch, int velocity, float ratio);
  void NoteOff(long tick, int channel, int pitch, int velocity);
}

OnCommand printCommand = new OnCommand() {
  void NoteOn(long tick, int channel, int pitch, int velocity, float ratio) {
    printNote("NoteOn", tick, channel, pitch, velocity);
  }
  void NoteOff(long tick, int channel, int pitch, int velocity) {
    printNote("NoteOff", tick, channel, pitch, velocity);
  }
  void printNote(String command, long tick, int channel, int pitch, int velocity) {
    println("@" + tick + " Channel: " + channel + " " + command + ", key=" + pitch + " velocity: " + velocity);
  }
};

OnCommand[] allCommand = {myGrid.impactCommand, myRain.rainCommand, myStorm.stormCommand};