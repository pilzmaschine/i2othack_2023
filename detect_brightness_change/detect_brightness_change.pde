import processing.video.*;

PImage current;
PImage buffer;
PImage buffer2;
PImage buffer3;

Capture video;
void setup(){
  size(640, 480);
  video = new Capture(this, 640, 480, "pipeline: ksvideosrc device-index=0 ! video/x-raw,width=640,height=480,framerate=30/1");
  video.start();
  current = createImage(width, height, RGB);
  buffer = createImage(width, height, RGB);
  buffer2 = createImage(width, height, RGB);
  buffer3 = createImage(width, height, RGB);
}

void captureEvent(Capture video) {
  buffer = buffer2.copy();
  buffer2 = buffer3.copy();
  buffer3 = current.copy();
  
  video.read();
  
  current = video.copy();
}

void draw() {
  //video.loadPixels();
  //image(current,0 ,0);
  for (int i=0; i<width; i++) {
    for (int j=0; j<height; j++) {
      set(i, j, color(abs(green(current.get(i, j)) - green(buffer.get(i, j)))));
    }
  }
  
}
