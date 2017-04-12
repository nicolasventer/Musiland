class Timer {

  class Function {
    int endTimeMs;
    OnUse o;
    Function(int endTimeMs, OnUse o) {
      this.endTimeMs = endTimeMs;
      this.o = o;
    }
  }

  HashMap<String, Function> allFunctions = new HashMap<String, Function>();

  boolean containsFunction(String keyFunction) {
    return allFunctions.containsKey(keyFunction);
  }

  void addFunction(String keyFunction, int delayMs, OnUse o) {
    if (containsFunction(keyFunction))
      println("warning : " + keyFunction + " already added");
    allFunctions.put(keyFunction, new Function(millis()+delayMs, o));
  }

  void check() {
    ArrayList<String> keysToRemove = new ArrayList<String>();
    for (String keyFunction : allFunctions.keySet()) {
      Function f = allFunctions.get(keyFunction);
      if (millis()>f.endTimeMs) {
        f.o.use();
        keysToRemove.add(keyFunction);
      }
    }
    for (String keyFunction : keysToRemove)
      allFunctions.remove(keyFunction);
  }
}

interface OnUse {
  void use();
}

OnUse exitProgram = new OnUse() {
  void use() {
    exit();
  }
};

OnUse launchSequencer = new OnUse() {
  void use() {
    myMidiFileReader.sequencer.start();
  }
};