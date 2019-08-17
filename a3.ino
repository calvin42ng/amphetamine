#include <Arduino.h>
#include <CapacitiveSensor.h>
#include <NeoPatterns.h>
#define PIN_NEOPIXEL_BAR_16  5

void allPatterns(NeoPatterns * aLedsPtr);
#ifdef TEST_USER_PATTERNS
void ownPatterns(NeoPatterns * aLedsPtr);
NeoPatterns bar16 = NeoPatterns(16, PIN_NEOPIXEL_BAR_16, NEO_GRB + NEO_KHZ800, &ownPatterns);
#else
NeoPatterns bar16 = NeoPatterns(16, PIN_NEOPIXEL_BAR_16, NEO_GRB + NEO_KHZ800, &allPatterns);
#endif

CapacitiveSensor   cs_4_2 = CapacitiveSensor(4,2);        // 10M resistor between pins 4 & 2, pin 2 is sensor pin, add a wire and or foil if desired
long detect_total = 0;

#include <Servo.h>

int rec = 0;

Servo myservo;  // create servo object to control a servo
// twelve servo objects can be created on most boards

int pos = 0;    // variable to store the servo position

int relay = 7;
int relay2 = 6;

int flashlight = 1;
int waterfalling = 1;

int ledloop = 1;

void setup() {
  Serial.begin(9600);
  myservo.attach(9);  // attaches the servo on pin 9 to the servo object
  pinMode (relay, OUTPUT);
  pinMode (relay2, OUTPUT);


    bar16.begin(); // This initializes the NeoPixel library.
    bar16.ColorWipe(COLOR32(0, 0, 02), 50, REVERSE); // light Blue  

    cs_4_2.set_CS_AutocaL_Millis(0xFFFFFFFF);     // turn off autocalibrate on channel 1 - just as an example
}

void loop() {
   long total1 =  cs_4_2.capacitiveSensor(30);
   detect_total = total1;
   //Serial.println(detect_total);

  if(detect_total <= 1000){
    if(ledloop == 1)
      bar16.Update();
   }else{
    Serial.println("1");
   }
  
  if(flashlight == 1){
    digitalWrite (relay, LOW);
    delay(5);    
  }else{
    digitalWrite (relay, HIGH);
    delay(5);    
   }

 if(waterfalling == 1){
   digitalWrite (relay2, HIGH);
   delay(5);
  }else{
   digitalWrite(relay2, LOW);
   delay(5); 
  }
  
  if(Serial.available()){
    rec = Serial.read();
    if(rec == 97){
        for (pos = 0; pos <= 170; pos += 1) { // goes from 0 degrees to 180 degrees
          // in steps of 1 degree
          myservo.write(pos);              // tell servo to go to position in variable 'pos'
          delay(5);                       // waits 15ms for the servo to reach the position
        }
        delay(6000);
        for (pos = 170; pos >= 10; pos -= 1) { // goes from 0 degrees to 180 degrees
          // in steps of 1 degree
          myservo.write(pos);              // tell servo to go to position in variable 'pos'
          delay(5);                       // waits 15ms for the servo to reach the position
        }    
      }
     else if(rec == 98){
      flashlight = 0;
     }else if(rec == 99){
      flashlight = 1;
     }else if(rec == 100){
      waterfalling = 0;
     }else if(rec == 101){
      waterfalling = 1; ;       
     }else if(rec == 122){
      ledloop = 0; 
     }else if(rec == 121){
      ledloop = 1; 
     }
  }
}

//the example of NeoPatterns

#ifdef TEST_USER_PATTERNS

void UserPattern1(NeoPatterns * aNeoPatterns, color32_t aColor1, color32_t aColor2, uint8_t aInterval, uint8_t aDirection) {
    aNeoPatterns->ActivePattern = PATTERN_USER_PATTERN1;
    aNeoPatterns->Interval = aInterval;
    aNeoPatterns->Color1 = aColor1;
    aNeoPatterns->Color2 = aColor2;
    aNeoPatterns->Direction = aDirection;
    aNeoPatterns->TotalStepCounter = aNeoPatterns->numPixels();
}

void UserPattern1Update(NeoPatterns * aNeoPatterns, bool aDoUpdate) {
    for (uint16_t i = 0; i < aNeoPatterns->numPixels(); i++) {
        if (i == aNeoPatterns->Index) {
            aNeoPatterns->setPixelColor(i, aNeoPatterns->Color2);
        } else {
            aNeoPatterns->setPixelColor(i, aNeoPatterns->Color1);
        }
    }
    if (aDoUpdate) {
        aNeoPatterns->NextIndexAndDecrementTotalStepCounter();
    }
}



/*
 * Handler for testing your own patterns
 */
void ownPatterns(NeoPatterns * aLedsPtr) {
    static int8_t sState = 0;

    uint8_t tDuration = random(20, 120);
    uint8_t tColor = random(255);

    switch (sState) {
    case 0:
        UserPattern1(aLedsPtr, COLOR32_RED_HALF, NeoPatterns::Wheel(tColor), tDuration, FORWARD);
        break;

    default:
        break;
    }

    sState++;
}
#endif // TEST_USER_PATTERNS

/*
 * Handler for all pattern
 */
void allPatterns(NeoPatterns * aLedsPtr) {
    static int8_t sState = 0;

    uint8_t tDuration = random(40, 81);
    uint8_t tColor = random(255);

    switch (sState) {
    case 0:
        // simple scanner
        aLedsPtr->clear();
        aLedsPtr->ScannerExtended(NeoPatterns::Wheel(tColor), 5, tDuration, 2, FLAG_SCANNER_EXT_CYLON);
        break;
    case 1:
        // rocket and falling star - 2 times bouncing
        aLedsPtr->ScannerExtended(NeoPatterns::Wheel(tColor), 7, tDuration, 2,
        FLAG_SCANNER_EXT_ROCKET | FLAG_SCANNER_EXT_START_AT_BOTH_ENDS, (tDuration & DIRECTION_DOWN));
        break;
    case 2:
        // 1 times rocket or falling star
        aLedsPtr->clear();
        aLedsPtr->ScannerExtended(COLOR32_WHITE_HALF, 7, tDuration / 2, 0, FLAG_SCANNER_EXT_VANISH_COMPLETE,
                (tDuration & DIRECTION_DOWN));
        break;
    case 3:
        // Multiple falling star
        initMultipleFallingStars(aLedsPtr, COLOR32_WHITE_HALF, tDuration / 2, 3, &allPatterns);
        break;
//    case 8:
//        // clear pattern
//        aLedsPtr->ColorWipe(COLOR32_BLACK, tDuration, FLAG_DO_NOT_CLEAR, DIRECTION_DOWN);
//        break;        
    case 4:
        if (aLedsPtr->PatternsGeometry == GEOMETRY_BAR) {
            //Fire
            aLedsPtr->Fire(tDuration / 2, 150);
        } else {
            // start at both end
            aLedsPtr->ScannerExtended(NeoPatterns::Wheel(tColor), 5, tDuration, 0,
            FLAG_SCANNER_EXT_START_AT_BOTH_ENDS | FLAG_SCANNER_EXT_VANISH_COMPLETE);
        }

        sState = -1; // Start from beginning
        break;
    default:
        break;
    }

    sState++;
}
