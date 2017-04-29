import javax.sound.midi.*; // audio output changed in importinig minim, try to change the midi player code in using SoundCipher
import themidibus.*;
import java.util.TreeMap;

class MidiFileReader {

  static final int NOTE_ON = 0x90;
  static final int NOTE_OFF = 0x80;
  static final int DRUM_CHANNEL = 9;

  Sequencer sequencer;
  Track track;
  MidiEvent eventToAdd;
  int trackSize;
  int indexInTrack = 0;

  float tempoFactor = 1;
  float tempoFactorMax = 2; // tempoFactorMin = 1/tempoFactorMax

  float refreshRate = 0.24;

  void openMidiFile(String folderMidi, String fileNameMidi) {
    try {
      Sequence sequence = MidiSystem.getSequence(new File(dataPath(folderMidi+"/"+fileNameMidi)));
      setSequencer(sequence);
      setTrackMelodies(sequence);
      setTrackSize();
    } 
    catch (Exception e) {
      println(e.getMessage());
      exit();
    }
  }

  void setSequencer(Sequence sequence) throws Exception {
    sequencer = MidiSystem.getSequencer();
    sequencer.open();
    sequencer.setSequence(sequence);
  }

  void setTrackMelodies(Sequence sequence) {
    Track[] tracks = sequence.getTracks();
    TreeMap<Long, ArrayList<MidiEvent>> tracksMap = new TreeMap<Long, ArrayList<MidiEvent>>();

    for (int i=0; i<tracks.length; i++) {
      for (int j=0; j<tracks[i].size(); j++) {
        MidiEvent event = tracks[i].get(j);
        ArrayList<MidiEvent> trackMap = tracksMap.get(event.getTick());
        if (trackMap==null)
          trackMap = new ArrayList<MidiEvent>();
        trackMap.add(event);
        tracksMap.put(event.getTick(), trackMap);
      }
      sequence.deleteTrack(tracks[i]);
    }

    OnCommand[] oldAllCommand = allCommand;
    allCommand = new OnCommand[] {MelodiesCommand};
    track = sequence.createTrack();
    for (Long tick : tracksMap.keySet()) {
      for (MidiEvent event : tracksMap.get(tick)) {
        if (getMessage(event))
          track.add(eventToAdd);
        else
          track.add(event);
      }
    }
    allCommand = oldAllCommand;
  }

  void setTrackSize() {
    trackSize = track.size();
  }

  void getAllMessage() {
    for (int i=0; i<trackSize; i++)
      getMessage(track.get(i));
  }

  void getCurrentMessage() {
    sequencer.setTempoFactor(tempoFactor);
    while (indexInTrack<trackSize && sequencer.getTickPosition() >= track.get(indexInTrack).getTick()) {
      getMessage(track.get(indexInTrack));
      indexInTrack++;
    }
  }

  long lastTick = 0;
  int lastTime = 0;

  boolean getMessage(MidiEvent event) {
    int command = 0;
    MidiMessage message = event.getMessage();
    long tick = event.getTick();
    if (message instanceof ShortMessage) {
      ShortMessage sm = (ShortMessage) message;
      command = sm.getCommand();
      int pitch = sm.getData1();
      int velocity = sm.getData2();
      int channel = sm.getChannel();
      if (command == NOTE_ON && velocity!=0) {
        float ratio = lastTick == tick || millis() == lastTime  ? 1 : refreshRate/((float)(millis()-lastTime)/(tick-lastTick));
        for (OnCommand oc : allCommand)
          oc.NoteOn(tick, channel, pitch, velocity, ratio);
      } else if (command == NOTE_OFF || (command == NOTE_ON && velocity==0))
        for (OnCommand oc : allCommand)
          oc.NoteOff(tick, channel, pitch, velocity);
    }
    if (lastTick != tick) {
      lastTime=millis();
      lastTick = tick;
    }
    return command == NOTE_ON || command == NOTE_OFF;
  }

  float getTickRate() {
    return (float)sequencer.getMicrosecondPosition()/sequencer.getMicrosecondLength();
  }

  OnCommand MelodiesCommand = new OnCommand() {

    HashMap<Integer, Integer[]> numMelodiesOn = new HashMap<Integer, Integer[]>(); // numMelody, [channel,pitch]

    void NoteOn(long tick, int channel, int pitch, int velocity, float ratio) {
      int i=0;
      while (numMelodiesOn.containsKey(i) || i==DRUM_CHANNEL)
        i++;
      numMelodiesOn.put(i, new Integer[] {channel, pitch});
      try {
        eventToAdd = new MidiEvent(new ShortMessage(MidiFileReader.NOTE_ON, channel == DRUM_CHANNEL ? DRUM_CHANNEL : i%16, pitch, velocity), tick);
      } 
      catch (Exception e) {
        println(e.getMessage());
        exit();
      }
    }

    void NoteOff(long tick, int channel, int pitch, int velocity) {
      int i = getNumMelodyToRemove(channel, pitch);
      numMelodiesOn.remove(i);
      try {
        if (i!=-1)
          eventToAdd = new MidiEvent(new ShortMessage(MidiFileReader.NOTE_OFF, channel == DRUM_CHANNEL ? DRUM_CHANNEL : i%16, pitch, velocity), tick);
      } 
      catch (Exception e) {
        println(e.getMessage());
        exit();
      }
    }

    int getNumMelodyToRemove(int channel, int pitch) {
      for (int i : numMelodiesOn.keySet()) {
        Integer[] note = numMelodiesOn.get(i);
        if (note[0] == channel && note[1] == pitch)
          return i;
      }
      return -1;
    }
  };

  void setTempoFactor(float zPos) {
    tempoFactor = 1f/tempoFactorMax*pow(tempoFactorMax, 2*(zPos+0.5));
  }
}