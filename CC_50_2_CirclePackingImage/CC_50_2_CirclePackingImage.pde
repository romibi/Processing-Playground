// Daniel Shiffman
// http://codingtra.in
// http://patreon.com/codingtrain
// Code for: https://youtu.be/ERQcYaaZ6F0

import processing.video.*;
import java.util.Iterator;
ArrayList<Circle> circles;
Capture cam;

void setup() {
  size(150,150);
  surface.setResizable(true);
  String[] devices = Capture.list();
  cam = new Capture(this,devices[0]);  
  cam.start();
  
  while(cam.width == 0 || cam.height == 0) {
    if(cam.available()) cam.read();
    delay(1);
  }
  
  surface.setSize(cam.width, cam.height);
  circles = new ArrayList<Circle>();
}

void draw() {
  background(0);
  if(cam.available()) {
    cam.read();
    cam.loadPixels();  
  }

  int total = 50;
  int count = 0;

  while (count <  total) {
    Circle newC = newCircle();
    if (newC != null) {
      circles.add(newC);
      count++;
    }
  }


  for (Iterator<Circle> iterator = circles.iterator(); iterator.hasNext();) {
    Circle c = iterator.next();
    if (c.growing) {
      if (c.edges()) {
        c.growing = false;
      } else {
        for (Circle other : circles) {
          if(c.colliding(other)) {
            c.growing = false;
            break;
          }
        }
      }
    }
    c.show();
    c.grow();
    if(c.dead()) {
      iterator.remove();
    }
  }
}

Circle newCircle() {

  float x = random(width);
  float y = random(height);

  boolean valid = true;
  for (Circle c : circles) {
    float d = dist(x, y, c.x, c.y);
    if (d < c.r) {
      valid = false;
      break;
    }
  }

  if (valid) {
    color col = cam.get(int(x),int(y));
    return new Circle(x, y, col);
  } else {
    return null;
  }
}
