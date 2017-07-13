// Daniel Shiffman
// http://codingtra.in
// http://patreon.com/codingtrain
// Code for: https://youtu.be/ERQcYaaZ6F0

class Circle {
  float x;
  float y;
  float r;
  color c;

  boolean growing = true;

  Circle(float x_, float y_, color c_) {
    x = x_;
    y = y_;
    c = c_;
    r = 1;
  }

  void grow() {
    if (growing) {
      r = r + 0.5;
    }
  }

  boolean edges() {
    return (x + r > width || x -  r < 0 || y + r > height || y -r < 0);
  }
  
  boolean colliding(Circle other) {
    if (this == other) return false;
    float d = dist(x, y, other.x, other.y);
    if (d - 2 < r + other.r) {
        return true;
    }
    return false;
  }

  void show() {
    //stroke(255);
    //strokeWeight(2);
    //noFill();
    fill(c);
    noStroke();
    ellipse(x, y, r*2, r*2);
  }
}
