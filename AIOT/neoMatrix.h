#ifndef NEOMATRIX_H
#define NEOMATRIX_H

// #include "config.h"
#include "ButtonsTested.h"
// #include <SD.h>

#define MAX_ANIMATION_FRAMES_ACCEPTED (8)
//#define LED_NUM (1024)
#define LED_NUM (256)
#define RGB_NUM (3)
#define LED_DATA_SIZE (3)
#define DATA_PIN (13)
#define matrixWidth (16)
#define matrixHeight (16)
#define tileWidth (16)
#define tileHeight (16)
#define tilesNum (2)

#define BLACK (0)
#define GIF_Repetitions (12)
#define flashMemGifs (6)

int Brightness (3)
// Adafruit_NeoMatrix matrix = Adafruit_NeoMatrix(matrixWidth, matrixHeight,tilesNum,tilesNum, DATA_PIN,
//   NEO_MATRIX_BOTTOM + NEO_MATRIX_RIGHT + NEO_MATRIX_COLUMNS + NEO_MATRIX_ZIGZAG
//   + NEO_TILE_TOP + NEO_TILE_RIGHT+  NEO_TILE_ROWS + NEO_TILE_PROGRESSIVE,
//   NEO_GRB + NEO_KHZ800);
  Adafruit_NeoMatrix matrix = Adafruit_NeoMatrix(tileWidth, tileHeight,DATA_PIN,
  NEO_MATRIX_BOTTOM + NEO_MATRIX_RIGHT +
  NEO_MATRIX_COLUMNS + NEO_MATRIX_ZIGZAG,
  NEO_GRB + NEO_KHZ800);

bool on=false;

void matrixSetUp(){
  Serial.println("matrixSetup");
  matrix.begin();
  matrix.setBrightness(Brightness);
  matrix.fillScreen(BLACK);

  matrix.setTextWrap(false); // we don’t want text to wrap so that it can scroll nicely

}

void turnOff(){
  // setUp();
   matrix.fillScreen(BLACK);
}

void turnOn(){
  setUp();
}

void handleOnOff(){
    Serial.println("Button ONOFF");
  on = !on;
  if(on){
    turnOff();
  }else{
    tuenOn();
  }
  matrix.show();
}
void handleButtonOnOff() {
  handleOnOffPress(handleOnOff);
}


void displayMessage(String text){
  int repetitions=1;
  int16_t textWidth = matrix.width() * text.length();
  
  for (int i = 0; i < repetitions; i++) {
    matrix.fillScreen(0); // Clear the screen

    // Calculate the start position based on text length
    int16_t startPosition = matrix.width();
    if (textWidth < matrix.width()) {
      startPosition = (matrix.width() - textWidth) / 2;
    }
    
    // Calculate the vertical centering position
    int16_t verticalPosition = (matrix.height() - 7) / 2;   
    // Set the cursor position (x, y) for horizontal centering and vertical centering
    matrix.setCursor(startPosition, verticalPosition);
    matrix.print(text); // Print the text
    matrix.show(); 

    // Scroll the text horizontally
    for (int16_t x = startPosition; x >= -textWidth; x--) {
      matrix.clear(); // Clear the display
      matrix.setCursor(x, verticalPosition); // Set the position for the text
      matrix.print(text); // Print the text
      matrix.show(); // Show the updated display
      delay(75); // Adjust scrolling speed
    }
  }

}



// class Matrix{
//   bool on=false;
//   public:
//   // Adafruit_NeoMatrix matrix = Adafruit_NeoMatrix(matrixWidth, matrixHeight,tilesNum,tilesNum, DATA_PIN,
//   //   NEO_MATRIX_BOTTOM + NEO_MATRIX_RIGHT + NEO_MATRIX_COLUMNS + NEO_MATRIX_ZIGZAG
//   //   + NEO_TILE_TOP + NEO_TILE_RIGHT+  NEO_TILE_ROWS + NEO_TILE_PROGRESSIVE,
//   //   NEO_GRB + NEO_KHZ800);
//   Adafruit_NeoMatrix matrix = Adafruit_NeoMatrix(tileWidth, tileHeight,DATA_PIN,
//   NEO_MATRIX_BOTTOM + NEO_MATRIX_RIGHT +
//   NEO_MATRIX_COLUMNS + NEO_MATRIX_ZIGZAG,
//   NEO_GRB + NEO_KHZ800);

//   void matrixSetUp(){
//   Serial.println("matrixSetup");
//   matrix.begin();
//   matrix.setBrightness(Brightness);
//   matrix.fillScreen(BLACK);

//   matrix.setTextWrap(false); // we don’t want text to wrap so that it can scroll nicely

//   }

//   void turnOff(){
//   // setUp();
//    matrix.fillScreen(BLACK);
//   }

//   void turnOn(){
//     setUp();
//   }
//   void handleButtonOnOff() {
//     Serial.println("Button ONOFF");
//     on = !on;
//     if(on){
//       turnOff();
//     }else{
//       tuenOn();
//     }
//     matrix.show();
//   }


//   void displayMessage(String text){
//     int repetitions=2;
//     int16_t textWidth = matrix.width() * text.length();
  
//     for (int i = 0; i < repetitions; i++) {
//       matrix.fillScreen(0); // Clear the screen

//       // Calculate the start position based on text length
//       int16_t startPosition = matrix.width();
//       if (textWidth < matrix.width()) {
//         startPosition = (matrix.width() - textWidth) / 2;
//       }
    
//       // Calculate the vertical centering position
//       int16_t verticalPosition = (matrix.height() - 7) / 2;   
//       // Set the cursor position (x, y) for horizontal centering and vertical centering
//       matrix.setCursor(startPosition, verticalPosition);
//       matrix.print(text); // Print the text
//       matrix.show(); 

//       // Scroll the text horizontally
//       for (int16_t x = startPosition; x >= -textWidth; x--) {
//         matrix.clear(); // Clear the display
//         matrix.setCursor(x, verticalPosition); // Set the position for the text
//         matrix.print(text); // Print the text
//         matrix.show(); // Show the updated display
//         delay(75); // Adjust scrolling speed
//      }
//    }
//   }


// }
