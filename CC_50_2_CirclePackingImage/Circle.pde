// Daniel Shiffman
// http://codingtra.in
// http://patreon.com/codingtrain
// Code for: https://youtu.be/ERQcYaaZ6F0

class Circle {
  float x;
  float y;
  float r;
  color c;
  int age = 0;
  int maxage = 240;

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
    age++;
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
    float a = map(age,maxage/4,maxage,255,0);
    if(a>255) a=255;
    fill(c, a);
    noStroke();
    ellipse(x, y, r*2, r*2);
  }
}