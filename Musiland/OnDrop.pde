interface OnDrop {
  color getColor(color cStart, color cEnd, float ratio);
}

OnDrop greyDrop = new OnDrop() {
  color getColor(color cStart, color cEnd, float ratio) {
    return color(200);
  }
};

OnDrop rainbowDrop = new OnDrop() {
  color getColor(color cStart, color cEnd, float ratio) {
    return cStart;
  }
};

OnDrop degradeDrop = new OnDrop() {
  color getColor(color cStart, color cEnd, float ratio) {
    return color(lerp(red(cStart), red(cEnd), ratio), lerp(green(cStart), green(cEnd), ratio), lerp(blue(cStart), blue(cEnd), ratio));
  }
};

OnDrop chaoticDrop = new OnDrop() {
  color getColor(color cStart, color cEnd, float ratio) {
    return color(random(255), random(255), random(255));
  }
};

OnDrop[] allOnDrop = {greyDrop, rainbowDrop, degradeDrop, chaoticDrop};