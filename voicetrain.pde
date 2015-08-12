import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioInput in;
FFT fft;
float[] temp = new float[1024];
int div = 40;

void setup()
{
  size(560, 600, P3D);
  minim = new Minim(this);
  in = minim.getLineIn();
  fft = new FFT(in.bufferSize(), 44000); //sr = 550
  h = height / div;
  background(0);
  fill(0);
}

int t;
int h;
float db;
float db_max;
float voice_thre = 1;
float max_note_db;
int max_note_i;
float max_hz_db;
float max_hz_i;
int octab_num = 3;
float[] sum = new float[12];

void draw() {
  fft.forward(in.mix);
  db_max = 0;
  max_note_db = 0;
  max_hz_db = 0;
  t++;
  stroke(0, 0, 255, 100);
  line(t, 0, t, height);
  if (t > width) {
    background(0);
    t = 0;
  }

  for (int i = 0; i < div; i++) {
    temp[i] = fft.getBand(i) * 8;
  }
  
  for (int i = 0; i < 12 * octab_num; i++) {
    sum[i % 12] += temp[(int)map(i, 0, 12 * octab_num, 0, div)];
    db_max = max(db_max, temp[(int)map(i, 0, 12 * octab_num, 0, div)]);
  }

  for (int i = 0; i < sum.length; i++) {
    if (max_note_db < sum[i]) {
      max_note_db = sum[i];
      max_note_i = i;
    }
  }
  
  for (int i = 0; i < octab_num; i++) {
    int note_i = max_note_i + 12 * i;
    if (max_hz_db < temp[(int)map(note_i, 0, 12 * octab_num, 0, div)]) {
      max_hz_db = temp[(int)map(note_i, 0, 12 * octab_num, 0, div)];
      max_hz_i = note_i;
    }
  }
  
  if (db_max < voice_thre) {
    return;
  }
  
  drawText(max_note_i);
  
  for (int i = 0; i < temp.length; i++){
    stroke(255, 255, 255, min((int)map(temp[i], 0, db_max, 10, 255), 255));
    if (max_hz_i == i) {
      stroke(0, 255, 0);
    }
    line( t, i * h, t, (i + 1) * h);
  }
}

void drawText(int max_note_id) {
  fill(0);
  rect(0, 0, 30, height);
  fill(255);
  for (int i = 0; i < 12 * octab_num; i++) {
    text(codes[i % 12], 0, map(i, 0, 12 * octab_num, 0, height) + 20);
  }
  fill(0, 255, 0);
  for (int i = 0; i < octab_num; i++) {
    int note_id = max_note_id * i;
    text(codes[note_id % 12], 0, map(note_id, 0, 12 * octab_num, 0, height) + 20);
  }
} 
    

String[] codes = {"A", "A#/Bb", "B", "C", "C#/Db", "D", "D#/Eb", "E", "F", "F#/Gb", "G", "G#/Ab"};

// fft.getBand(0) = db(220hz) = db(A3)
// fft.getBand(10) = db(440hz) = db(A4)
// fft.getBand(20) = db(880hz) = db(A5)
// fft.getBand(40) = db(1760hz) = db(A6) = n(div)

int k = 0;
void keyPressed() {
  if (key == 'v') {
    voice_thre++;
  }else if (key == 'V') {
    voice_thre--;
  }
}
