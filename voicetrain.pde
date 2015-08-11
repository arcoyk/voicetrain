import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioInput in;
FFT fft;

void setup()
{
  size(560, 200, P3D);
  minim = new Minim(this);
  in = minim.getLineIn();
  fft = new FFT(in.bufferSize(), 44000); //sr = 550
  h = height / 40;
  background(0);
}

int t;
int h;
float db;
float db_max = 200;
void draw() {
  fft.forward(in.mix);
  for (int i = 0; i < 40; i++){
    db = fft.getBand(i) * 8;
    db = min((int)map(db, 0, db_max, 0, 255), 255);
    stroke(255, 255, 255, db);
    line( t, i * h, t, (i + 1) * h); 
    // db_max = db_max > db ? db_max : db;
  }
  println(db_max);
  t++;
  if (t > width) {
    background(0);
    t = 0;
  }
}

// fft.getBand(0) = db(220hz) = db(A3)
// fft.getBand(10) = db(440hz) = db(A4)
// fft.getBand(20) = db(880hz) = db(A5)
// fft.getBand(40) = db(1760hz) = db(A6)

int k = 0;
void keyPressed() {
}
