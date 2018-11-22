/*
This sketch builds on a prior work, "Animated 3d road render", created by Lukas & [unnamed author]
http://studio.sketchpad.cc/sp/pad/view/ro.9c$lOG3CzVzn6/rev.1744
*/

// track data block = {direction,length}
// direction: 1=left, 0=straight, -1=right
// lenght: int >0

int track[][] = {
 {1,1},
 {-1,1},
 {0,2},
 {1,2},
 {-1,2},
 {-1,2},
 {0,3},
 {1,1},
 {-1,1},
 {1,1}
};

int mapWidth = 0;
int mapHeight = 0;
double map[] = {0};
double blockSize = 2000.0;

int distanceTravelled = 0; 
double camAnimPhase = 0;

double cameraXOffset = 0;
double cameraYOffset = 0;

int displace[] = {0};

void setup() {  // this is run once.   
    
    // set the background color
    background(255);
    size(640, 400); 
    
    // limit the number of frames per second
    frameRate(60);
    
    // --------------------------
    // compute road data first
    // --------------------------
    
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
 
 expand(displace,width*height);
 
 for (int h = 0; h < height; h++) {
     for (int w = 0; w < width; w++) {
         double wd = Math.cos((w/width)*Math.PI)*20+w;
         double hd = Math.cos((h/height)*Math.PI)*20+h;
         int soff = h*width+w;
         int eoff = hd*width+wd;
         if (eoff < 0) eoff = 0;
         if (eoff > width*height-1) eoff = width*height-1;
         int diff = eoff-soff;
         displace[soff]=eoff;
     }    
 }
 
 mapWidth = x;
 mapHeight = y;
} 

// ----------------------------------
// road curve functions - tweens
// ----------------------------------

double easeInOut(double t) {
 return t < 0.5 ? 2.0 * t * t : -1.0 + (4.0 - 2.0 * t) * t
}
double easeInOutSine(double t) {
 return (1 + Math.sin(Math.PI * t - Math.PI / 2)) / 2
}

double getMapRow(int dst) {
        
    return map[Math.abs(dst) % mapHeight];
}


void draw() {  // this is run repeatedly.  

    // gradient sky
    for (int i = 0; i < 200; i++) {
        stroke(135+i, 206, 255-i, 255);
         // draw the line
        line(0, i, width, i);
    }
    
    // animated road
    for (int i = 200; i < 400; i++) {
        
        double dy = i;
        double focalDist=50.0;
        double rayDist = dy / ((200.0-dy)/focalDist);
        
        int color = (int)((rayDist+distanceTravelled)/200.0) % 2; 
        int colorStredovka = (int)((rayDist+distanceTravelled)/50.0) % 2; 
        int colorPatnik = (int)((rayDist+distanceTravelled)/10.0) % 2; 
        
        double cameraXStep = (1/(rayDist+focalDist))*focalDist;
            
        if (color == 0) {
            stroke(255,165,0, 255);
        } else {
            stroke(50, 205, 50, 255);
        }
        
          // draw the background row
        line(0, i, width, i);
        
        double wo = 600.0;
        double wp = (wo/(rayDist+focalDist))*focalDist;
        
        if (color == 0) {
            stroke(0,0,0, 255);
        } else {
            stroke(50, 50, 50, 255);
        }
        
        int scrx = (int)wp;
    //  if (scrx > width/2) scrx = width/2;
        
        int rd = (int)(rayDist+distanceTravelled);
        int followCam = (int)(distanceTravelled+focalDist);
        double camTrackOffset = (cameraXOffset+getMapRow(rd))*cameraXStep;
        
        // draw the road row
        line(320-scrx+camTrackOffset,
             i,
             320+scrx+camTrackOffset,
             i);
        
        // -------------------------
        // krajnice a stredovka
        // -------------------------
        
        double krajniceWidth = 50;
        double stredovkaWidth = 10;
        
        double wk1 = 550.0;
        double wk1p = (wk1/(rayDist+focalDist))*focalDist;
        
        double wk2 = 550-krajniceWidth;
        double wk2p = (wk2/(rayDist+focalDist))*focalDist;
        
        double sw1 = stredovkaWidth;
        double sw1p = (sw1/(rayDist+focalDist))*focalDist;
        
        stroke(i-100,i-100,i-100,255); // gradient 
        line(320-wk1p+(cameraXOffset+getMapRow(rd))*cameraXStep,i,320-wk2p+(cameraXOffset+getMapRow(rd))*cameraXStep,i); //krajnice prava
        line(320+wk1p+(cameraXOffset+getMapRow(rd))*cameraXStep,i,320+wk2p+(cameraXOffset+getMapRow(rd))*cameraXStep,i); //krajnice leva
        
        if (colorStredovka == 0) {
            line(320-sw1p+(cameraXOffset+getMapRow(rd))*cameraXStep,i,320+sw1p+(cameraXOffset+getMapRow(rd))*cameraXStep,i); //stredovka prerusovana
        }
        
    }
    
    // ----------------------
    // patniky
    // ----------------------
        
    int numOfStones = 20;
    double stonesDistance = 300;
    double patnikWidth = 20;
    double patnikHeightFactor = 50; //times width tall
    double patnikXOffset = 700; // road is 600 points 
    
    double startDistance = 0 + (distanceTravelled % stonesDistance) + stonesDistance * numOfStones;
    
    for (int i = 0; i < numOfStones; i++) {
    
        double pwp = (patnikWidth/(startDistance+focalDist))*focalDist;
        double php = pwp*patnikHeightFactor;
        double pxp = (patnikXOffset/(startDistance+focalDist))*focalDist;
        double pyp = 200-(200*startDistance)/(focalDist+startDistance)+200;
        
        double cameraXStep = (1/(startDistance+focalDist))*focalDist;
        
        stroke(pyp-50);
        fill(pyp-50);
       
        rect(320-pxp-(cameraXOffset+getMapRow(startDistance-distanceTravelled))*cameraXStep,pyp-php,pwp,php);
        rect(320+pxp-(cameraXOffset+getMapRow(startDistance-distanceTravelled))*cameraXStep,pyp-php,pwp,php);
        //  stroke(255,255,255,255);
        //  line(320-pxp,i,320-pxp,i+php);
        
        startDistance -= stonesDistance; //  +/-
    }
    
    //cameraXOffset = Math.sin(camAnimPhase)*1600;
    //cameraYOffset = -Math.round(Math.sin(camAnimPhase)*100); 
    // camAnimPhase += 0.01;
    
    distanceTravelled -= 5;
        
    if (keyPressed) {
        if (keyCode == LEFT) {
            cameraXOffset -= 10;
        }
        if (keyCode == RIGHT) {
            cameraXOffset += 10; 
        }
    }
    
    //loadPixels();  
    //for (int i = 0; i < pixels.length; i++) {
    // pixels[i]=new Color(displace[i]*10);
    //}
    //updatePixels(); 


    
  //  fill(0);
  //  text("mapWidth=" + mapWidth + ", mapHeight=" + mapHeight, 20,20);
    
  //  stroke(255);
  //  for (int i = 0; i < 400; i++) {
  //      line(0,i,getMapRow(i)+320,i);
  //  }
}
