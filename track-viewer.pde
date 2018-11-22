
// track data block = {direction,length}
// direction: 1=left, 0=straight, -1=right
// lenght: int >0

int track[][] = {
 {
  1,
  1
 },
 {-1,
  1
 },
 {
  0,
  2
 },
 {
  1,
  2
 },
 {-1,
  2
 },
 {-1,
  2
 },
 {
  0,
  3
 },
 {
  1,
  1
 },
 {-1,
  1
 },
 {
  1,
  1
 }
};


int i = 0;


int mapWidth = 0;
int mapHeight = 0;
double map[] = {0};

void setup() { // this is run once.   

 // set the background color
 background(255);

 size(400, 640);

 // limit the number of frames per second
 frameRate(30);

 int x = 0;
 int y = 0;
 for (int i = 0; i < track.length; i++) {

  int w = track[i][1] * blockSize;
  int o = track[i][0];
  double xp = 0;
  for (int j = 0; j < w; j++) {

   double t = j / w;
   if (o == -1) {
    xp = +easeInOut(t) * w;
   } else if (o == 1) {
    xp = -easeInOut(t) * w;
   }

   map[y] = x + xp;
   expand(map,map.length+1);
  
   y++;
  }
  x = x + xp;
 }

 mapWidth = x;
 mapHeight = y;

}

double easeInOut(double t) {
 return t < 0.5 ? 2.0 * t * t : -1.0 + (4.0 - 2.0 * t) * t
}
double easeInOutSine(double t) {
 return (1 + Math.sin(Math.PI * t - Math.PI / 2)) / 2
}

void drawRoadStrip(double width, int color, double xpos, int ypos) {

 stroke(90);
 line(xpos - 6, ypos, xpos + width, ypos);

 stroke(50);
 line(xpos - 3, ypos, xpos + width + 3, ypos);
 stroke(100);
 line(xpos, ypos, xpos + width, ypos);
 double part = width / 40.0;

 stroke(255);
 line(xpos + part * 2, ypos, xpos + part * 3.0, ypos);
 line(xpos + width - part * 3.0, ypos, xpos + width, ypos, );

 if (color < 5) {
  line(xpos + width / 2 - part / 2, ypos, xpos + width / 2 + part / 2, ypos);
 }
}

double blockSize = 35.0;

void draw() {

    for (int i = 0; i < mapHeight; i++) {
        drawRoadStrip(25,i%10,map[i]+200,i);    
    }
        
}


double getOffsetForDistance(int dist) {
 int x = 0;
 int y = 0;
 while (true) {
  for (int i = 0; i < track.length; i++) {

   int w = track[i][1] * blockSize;
   int o = track[i][0];
   double xp = 0;
   for (int j = 0; j < w; j++) {

    double t = j / w;
    if (o == -1) {
     xp = +easeInOutSine(t) * w;
    } else if (o == 1) {
     xp = -easeInOutSine(t) * w;
    }

    if (y == dist) {
     return x + xp;
    }

    y++;
   }
   x = x + xp;
  }
 }
}
