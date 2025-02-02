import processing.video.*;

PImage current;
PImage buffer1;
PImage buffer2;
PImage buffer3;

float[][] pheromone;
float[][] buffer;
float decay = 0.2;
Particle[] particles = new Particle[100000];

float angle = 0.3;
float sensor_dist = 5;
float angle_sensitivity = 0.9;
float rand_angle = 0.2;

Capture video;

void captureEvent(Capture video) {
  buffer1 = buffer2.copy();
  buffer2 = buffer3.copy();
  buffer3 = current.copy();
  
  video.read();
  
  current = video.copy();
}

void resample_slime_mold_paramters() {
  angle = random(PI/2);
  sensor_dist = random(30);
  angle_sensitivity = random(0.5, 1.0);
  rand_angle = random(PI/4);
  println("angle: "+angle+", sensor_dist: "+sensor_dist+", angle_sensitivity: "+angle_sensitivity+", rand_angle: "+rand_angle);
}

void keyPressed() {
  resample_slime_mold_paramters();
}

void setup(){
  size(640, 480);
  video = new Capture(this, 640, 480, "pipeline: ksvideosrc device-index=0 ! video/x-raw,width=640,height=480,framerate=30/1");
  video.start();
  current = createImage(width, height, RGB);
  buffer1 = createImage(width, height, RGB);
  buffer2 = createImage(width, height, RGB);
  buffer3 = createImage(width, height, RGB);

  pheromone = new float[width][height];
  buffer = new float[width][height];
  for (int i=0; i<width; i++) {
    for (int j=0; j<height; j++) {
      pheromone[i][j] = 0;
      buffer[i][j] = 0;
    }
  }
  for (int k=0; k<particles.length; k++) {
    particles[k] = new Particle();
  }
}

void draw() {
  //video.loadPixels();
  //image(current,0 ,0);
  /*for (int i=0; i<width; i++) {
    for (int j=0; j<height; j++) {
      set(i, j, color(abs(green(current.get(i, j)) - green(buffer1.get(i, j)))));
    }
  }*/
 
  for (int i=0; i<width; i++) {
    for (int j=0; j<height; j++) {
      float motion_level = abs(green(current.get(i, j)) - green(buffer1.get(i, j)));
      //if (i==50 && j==50) println(motion_level);
      set(i, j, color((pheromone[i][j]>100) ? 0.2*pheromone[i][j]-100 : 0, motion_level, 0.5*pheromone[i][j]));
      
      float dynamic_decay = max(0, 1-motion_level/1.);
      pheromone[i][j] *= decay*dynamic_decay;
    }
  }
  
  for (int i=0; i<width; i++) {
    for (int j=0; j<height; j++) {
      float neighbor_sum = 0;
      for (int k=-1; k<=1; k++) {
        for (int q=-1; q<=1; q++) {
          int ii = i+k;
          int jj = j+q;
          if (ii < 0) ii += width;
          if (jj < 0) jj += height;
          if (ii >= width) ii -= width;
          if (jj >= height) jj -=height;
          
          neighbor_sum += pheromone[ii][jj];
        }
      }
      buffer[i][j] = neighbor_sum/9;
    }
  }
  pheromone = buffer;
  
  for (int k=0; k<particles.length; k++) {
    particles[k].update();
  }
  //println(frameRate);
}

class Particle{
  PVector position;
  PVector velocity;
  
  Particle() {
    position = new PVector(random(width), random(height));//width/2, height/2);//
    velocity = PVector.random2D();
    
  }
  
  void update() {
    position.add(velocity);
    int x = max(0, min(width-1, int(position.x)));
    int y = max(0, min(height-1, int(position.y)));
    /*int x = int(position.x);
    int y = int(position.y);*/
    pheromone[x][y] += 255;
    
    float motion_level = abs(green(current.get(x, y)) - green(buffer1.get(x, y)));
    if (motion_level>10) position = new PVector(random(width), random(height));
    
    PVector position_left_sensor = PVector.add(position, velocity.copy().rotate(-angle).normalize().mult(sensor_dist));
    int x_pls = int(position_left_sensor.x);
    int y_pls = int(position_left_sensor.y);
    
    if (x_pls < 0) x_pls += width;
    if (y_pls < 0) y_pls += height;
    if (x_pls >= width) x_pls -= width;
    if (y_pls >= height) y_pls -=height;
    
    PVector position_right_sensor = PVector.add(position, velocity.copy().rotate(angle).normalize().mult(sensor_dist));
    int x_prs = int(position_right_sensor.x);
    int y_prs = int(position_right_sensor.y);
    
    if (x_prs < 0) x_prs += width;
    if (y_prs < 0) y_prs += height;
    if (x_prs >= width) x_prs -= width;
    if (y_prs >= height) y_prs -=height;
    
    
    if (pheromone[x_pls][y_pls] < pheromone[x_prs][y_prs]) {
      velocity.rotate(angle_sensitivity*angle);
    } else {
      velocity.rotate(-angle_sensitivity*angle);
    }
    velocity.rotate(random(-rand_angle, rand_angle));
    
    
    if (position.x <= 0) position.x += width;
    if (position.y <= 0) position.y += height;
    if (position.x >= (width-1)) position.x -= width;
    if (position.y >= (height-1)) position.y -= height;
  }
}
