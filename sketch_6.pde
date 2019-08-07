import processing.video.*;
import processing.serial.*;

import oscP5.*;
import netP5.*;
  
OscP5 oscP5;
NetAddress myRemoteLocation;
int[] array = new int[2];


Serial port;
String message;

Capture video;

int clear = 0;

int mode = 1;

// image path is relative to sketch directory
PImage img;
String imgFileName = "outImg";
String fileType = "jpg";
int picNum = 0;

int loops = 1;

// threshold values to determine sorting start and end pixels
int blackValue = -16000000;
int brightnessValue = 90;
int whiteValue = -13000000;

int row = 0;
int column = 0;

boolean saved = false;

int patternNum = 9; //initial as 9

int click = 0;
int timer = 0; // 0 or 1 to control the switch
int timerNum = 0; //it could ++

int strangeTFlag = 0;
int strangeT = 0;
int strangeTNum = 0;
int strangeHaveBeen = 0;
int strangeHaveBeenDisplay = 0;

int switchFlag = 0;
int blackTimerTrigger = 0;
int blackTimer = 0;

int BeenSlow = 0;

void setup(){
  size(1920,1080);
  img = loadImage(imgFileName+"."+fileType);

  oscP5 = new OscP5(this,5555);
  myRemoteLocation = new NetAddress("127.0.0.1",5555);
  
  String[] cameras = Capture.list();
  printArray(cameras);
  //video = new Capture(this, cameras[29]);
  video = new Capture(this, cameras[1]);
  video.start();
  
  
  port = new Serial(this, "COM14", 9600);
}

void draw(){
  
  if(port.available() > 0){
    String inString = port.readStringUntil('\n');
    if(inString != null){
      inString = inString.trim();
      int recNum = int(inString);
      
      if(blackTimer >= 300 && BeenSlow == 0){
        if(recNum == 1)
          if(switchFlag == 1){
              blackTimer = 2998;
          }          
      }

      if(blackTimer >= 35 && BeenSlow == 1){
        if(recNum == 1)
          if(switchFlag == 1){
              blackTimer = 2998;
              BeenSlow = 0;
          }          
      }      
      
      
      if(recNum == 1)
        if(switchFlag == 0){
          switchOn();
          switchFlag = 1;
        }
     }    
  }
  
  if(blackTimerTrigger == 1){
    blackTimer++;
  }
  
  
  if(timer == 1){
    timerNum++;
  }
  
//select the modes
  if(timerNum >=350){   
    
    if(patternNum == 0){
      video.read();
      video.save("/data/outImg"+picNum+".jpg");
      img = loadImage(imgFileName+picNum+"."+fileType);
      picNum++;      
      modePattern0();
      patternNum = 9;
      blackTimerTrigger = 1;
      switchOff();
    }
    
    if(patternNum == 1){
      video.read();
      video.save("/data/outImg"+picNum+".jpg");
      img = loadImage(imgFileName+picNum+"."+fileType);
      picNum++;      
      cutPicture();
      patternNum = 9;
      blackTimerTrigger = 1;
      switchOff();
    }    

    if(patternNum == 2){
      strangeTimer();
      if(strangeTNum >= strangeT){
        video.read();
        video.save("/data/outImg"+picNum+".jpg");
        clear = 0;
        img = loadImage(imgFileName+picNum+"."+fileType);
        picNum++;
        strangeTNum = 0;
        strangeTFlag = 0;
        patternNum = 9;
        strangeHaveBeenDisplay = 1;
        blackTimerTrigger = 1;
        switchOff();
        BeenSlow = 1;
      }
      strangeHaveBeen = 1;
      println("strangeT:", strangeT, " strangeTNum:", strangeTNum);
    }    
 
    if(patternNum == 3){
      fingerEffect();
      delay(2000);
      video.read();
      video.save("/data/outImg"+picNum+".jpg");
      img = loadImage(imgFileName+picNum+"."+fileType);
      picNum++;
      image(img, 0, 0, width, height);
      patternNum = 9;
      blackTimerTrigger = 1;
      switchOff();
    }    
    
    if(patternNum == 4){
      waterEffect(); 
      delay(1500);
      video.read();
      video.save("/data/outImg"+picNum+".jpg");
      img = loadImage(imgFileName+picNum+"."+fileType);
      picNum++;
      image(img, 0, 0, width, height);      
      patternNum = 9;
      blackTimerTrigger = 1;
      message = "e"; //101
      port.write(message);
      switchOff();
    }        
    
    if(patternNum == 5){
      flashlightEffect();
      delay(1000);
      video.read();
      video.save("/data/outImg"+picNum+".jpg");
      img = loadImage(imgFileName+picNum+"."+fileType);
      picNum++;
      image(img, 0, 0, width, height);
      patternNum = 9;
      blackTimerTrigger = 1;
      message = "c"; //99
      port.write(message);
      switchOff();
    }    
       
  timerNum = 0;
  timer = 0;
  }

  if(strangeHaveBeen == 1) {
    timerNum = 1000;     
  }
  if(strangeHaveBeenDisplay == 1){
    image(img, 0, 0, width, height);
  }

  if(timerNum != 0 && timerNum != 1000) println("TIMER=", timerNum);

//generate the random array  
  if(click == 1){
   //patternNum = 0;
   patternNum = (int)random(0,6);
   println("MODE NUMBER:",patternNum);
   click = 0;
  }  

 // image(video,0,0, 1920, 1080);  
  if(clear == 1){
    strangeHaveBeen = 0;
    strangeHaveBeenDisplay = 0;
    background(0);
  }

  if(patternNum == 9){
    println("blackTimer: ", blackTimer);
    if(blackTimer >= 3000){
      clear = 1;
      blackTimer = 0;
      blackTimerTrigger = 0;
      switchFlag = 0;
      port.write("y"); //121
    }
  }

}

void switchOn(){
  OscMessage myMessage = new OscMessage("");
  array[0] = 1;
  array[1] = 0;
  myMessage.add(array); /* add an int to the osc message */
  oscP5.send(myMessage, myRemoteLocation); 
  
  //video.read();
  //video.save("/data/outImg"+picNum+".jpg");
  clear = 0;
  //img = loadImage(imgFileName+picNum+"."+fileType);
  //picNum++;
  row = 0;
  column = 0;
  saved = false;
  click = 1; //generate the random array  
  timer = 1; //start the timer
  port.write("z"); //122
  redraw();
}


void switchOff(){
  OscMessage myMessage = new OscMessage("");
  array[0] = 0;
  array[1] = 1;  
  myMessage.add(array); 
  oscP5.send(myMessage, myRemoteLocation); 
}


//Glitch effect
void sortRow() {
  // current row
  int y = row;
  
  // where to start sorting
  int x = 0;
  
  // where to stop sorting
  int xend = 0;
  
  while(xend < img.width-1) {
    switch(mode) {
      case 0:
        x = getFirstNotBlackX(x, y);
        xend = getNextBlackX(x, y);
        break;
      case 1:
        x = getFirstBrightX(x, y);
        xend = getNextDarkX(x, y);
        break;
      case 2:
        x = getFirstNotWhiteX(x, y);
        xend = getNextWhiteX(x, y);
        break;
      default:
        break;
    }
    
    if(x < 0) break;
    
    int sortLength = xend-x;
    
    color[] unsorted = new color[sortLength];
    color[] sorted = new color[sortLength];
    
    for(int i=0; i<sortLength; i++) {
      unsorted[i] = img.pixels[x + i + y * img.width];
    }
    
    sorted = sort(unsorted);
    
    for(int i=0; i<sortLength; i++) {
      img.pixels[x + i + y * img.width] = sorted[i];      
    }
    
    x = xend+1;
  }
}

void sortColumn() {
  // current column
  int x = column;
  
  // where to start sorting
  int y = 0;
  
  // where to stop sorting
  int yend = 0;
  
  while(yend < img.height-1) {
    switch(mode) {
      case 0:
        y = getFirstNotBlackY(x, y);
        yend = getNextBlackY(x, y);
        break;
      case 1:
        y = getFirstBrightY(x, y);
        yend = getNextDarkY(x, y);
        break;
      case 2:
        y = getFirstNotWhiteY(x, y);
        yend = getNextWhiteY(x, y);
        break;
      default:
        break;
    }
    
    if(y < 0) break;
    
    int sortLength = yend-y;
    
    color[] unsorted = new color[sortLength];
    color[] sorted = new color[sortLength];
    
    for(int i=0; i<sortLength; i++) {
      unsorted[i] = img.pixels[x + (y+i) * img.width];
    }
    
    sorted = sort(unsorted);
    
    for(int i=0; i<sortLength; i++) {
      img.pixels[x + (y+i) * img.width] = sorted[i];
    }
    
    y = yend+1;
  }
}


// black x
int getFirstNotBlackX(int x, int y) {
  
  while(img.pixels[x + y * img.width] < blackValue) {
    x++;
    if(x >= img.width) 
      return -1;
  }
  
  return x;
}

int getNextBlackX(int x, int y) {
  x++;
  
  while(img.pixels[x + y * img.width] > blackValue) {
    x++;
    if(x >= img.width) 
      return img.width-1;
  }
  
  return x-1;
}

// brightness x
int getFirstBrightX(int x, int y) {
  
  while(brightness(img.pixels[x + y * img.width]) < brightnessValue) {
    x++;
    if(x >= img.width)
      return -1;
  }
  
  return x;
}

int getNextDarkX(int _x, int _y) {
  int x = _x+1;
  int y = _y;
  
  while(brightness(img.pixels[x + y * img.width]) > brightnessValue) {
    x++;
    if(x >= img.width) return img.width-1;
  }
  return x-1;
}

// white x
int getFirstNotWhiteX(int x, int y) {

  while(img.pixels[x + y * img.width] > whiteValue) {
    x++;
    if(x >= img.width) 
      return -1;
  }
  return x;
}

int getNextWhiteX(int x, int y) {
  x++;

  while(img.pixels[x + y * img.width] < whiteValue) {
    x++;
    if(x >= img.width) 
      return img.width-1;
  }
  return x-1;
}


// black y
int getFirstNotBlackY(int x, int y) {

  if(y < img.height) {
    while(img.pixels[x + y * img.width] < blackValue) {
      y++;
      if(y >= img.height)
        return -1;
    }
  }
  
  return y;
}

int getNextBlackY(int x, int y) {
  y++;

  if(y < img.height) {
    while(img.pixels[x + y * img.width] > blackValue) {
      y++;
      if(y >= img.height)
        return img.height-1;
    }
  }
  
  return y-1;
}

// brightness y
int getFirstBrightY(int x, int y) {

  if(y < img.height) {
    while(brightness(img.pixels[x + y * img.width]) < brightnessValue) {
      y++;
      if(y >= img.height)
        return -1;
    }
  }
  
  return y;
}

int getNextDarkY(int x, int y) {
  y++;

  if(y < img.height) {
    while(brightness(img.pixels[x + y * img.width]) > brightnessValue) {
      y++;
      if(y >= img.height)
        return img.height-1;
    }
  }
  return y-1;
}

// white y
int getFirstNotWhiteY(int x, int y) {

  if(y < img.height) {
    while(img.pixels[x + y * img.width] > whiteValue) {
      y++;
      if(y >= img.height)
        return -1;
    }
  }
  
  return y;
}

int getNextWhiteY(int x, int y) {
  y++;
  
  if(y < img.height) {
    while(img.pixels[x + y * img.width] < whiteValue) {
      y++;
      if(y >= img.height) 
        return img.height-1;
    }
  }
  
  return y-1;
}

//Glitch effect 2

void modePattern0(){
   while(column < img.width-1) {
    //println("Sorting Column " + column);
    img.loadPixels(); 
    sortColumn();
    column++;
    img.updatePixels();
  }
  
  // loop through rows
  while(row < img.height-1) {
   // println("Sorting Row " + column);
    img.loadPixels(); 
    sortRow();
    row++;
    img.updatePixels();
  }
  
  // load updated image onto surface and scale to fit the display width,height
  image(img, 0, 0, width, height);
  
  if(!saved && frameCount >= loops) {
    
  // save img
    img.save("/data/"+imgFileName+"_"+mode+".png");
  
    saved = true;
   // println("Saved "+frameCount+" Frame(s)");
    
    // exiting here can interrupt file save, wait for user to trigger exit
    //println("Click or press any key to exit...");
  } 
}

//Cut the picture
void cutPicture(){
  image(img, -500, -1050, width*2, height*2);
}

//strange timer
void strangeTimer(){
  if(strangeTFlag == 0){
    strangeT = (int)random(100,650);
    strangeTFlag = 1;
  }
  strangeTNum++;
  background(0);
}

//finger obscuring
void fingerEffect(){
  message = "a"; //97
  port.write(message);
  
}

//water dropping
void waterEffect(){
  message = "d";//100
  port.write(message);
}

//flashlight
void flashlightEffect(){
  message = "b"; //98
  port.write(message);
}
