#ifndef COMBINED_SNAKE_GAME_H
#define COMBINED_SNAKE_GAME_H

#include <Adafruit_NeoMatrix.h>
#include <Arduino.h>
#include <FirebaseESP32.h>

#define MAX_SNAKE_LENGTH 255
#define matrixWidth 8    // Update with your matrix width
#define matrixHeight 8   // Update with your matrix height
#define tilesNum 1       // Update with your number of tiles
#define DATA_PIN 6       // Update with your data pin
#define LED_TYPE NEO_GRB + NEO_KHZ800

enum Direction { UP, DOWN, LEFT, RIGHT, NONE };

class SnakeGame {
public:
  SnakeGame();

  void setup();
  boolean loop();

private:
  Adafruit_NeoMatrix matrix;
  CRGBPalette16 snakePalette;
  unsigned long previousMillis;
  uint8_t interval, startIndex, fruitHue;
  uint32_t count10ms;
  uint8_t snakeLength, snakeX[MAX_SNAKE_LENGTH], snakeY[MAX_SNAKE_LENGTH];
  uint8_t fruitX, fruitY;  
  struct Explode {
    uint8_t x, y, r, hue;
  } ex;
  boolean paused;
  uint16_t PlasmaTime, PlasmaShift;
  const uint8_t PlasmaLowHue = 100;
  const uint8_t PlasmaHighHue = 150;

  Direction currentInput;

  void drawFruit();
  void nextStep();
  void reset();
  boolean inPlayField(int x, int y);
  void makeFruit();
  boolean isPartOfSnake(int x, int y);
  boolean isPartOfSnakeBody(int x, int y);
  void FillSnakeWithColour(uint8_t colourIndex);
  void explodeFruit();
};

SnakeGame::SnakeGame()
  : matrix(matrixWidth, matrixHeight, tilesNum, tilesNum, DATA_PIN,
            NEO_MATRIX_BOTTOM + NEO_MATRIX_RIGHT + NEO_MATRIX_COLUMNS + NEO_MATRIX_ZIGZAG
            + NEO_TILE_TOP + NEO_TILE_RIGHT + NEO_TILE_ROWS + NEO_TILE_PROGRESSIVE,
            LED_TYPE) {
  previousMillis = 0;
  interval = 250;
  snakeLength = 1;
  startIndex = 0;
  fruitHue = 0;
  ex.r = 10;
  count10ms = 0;
  paused = false;
}

void SnakeGame::setup() {
  matrix.begin(); // Initialize NeoMatrix
  matrix.setTextWrap(false); // Allow text to run off edges
  matrix.setBrightness(50); // Set matrix brightness

  currentInput = NONE;

  PlasmaShift = (random8(0, 5) * 32) + 64;
  PlasmaTime = 0;

  // Start snake in the middle
  snakeX[0] = matrixWidth / 2;
  snakeY[0] = matrixHeight / 2;

  makeFruit();
}

boolean Snake::loop() {
  // Fill background with dim plasma
  for (int16_t x = 0; x < matrixWidth; x++) {
    for (int16_t y = 0; y < matrixHeight; y++) {
      int16_t r = sin16(PlasmaTime) / 256;
      int16_t h = sin16(x * r * SNAKE_PLASMA_X_FACTOR + PlasmaTime) + cos16(y * (-r) * SNAKE_PLASMA_Y_FACTOR + PlasmaTime) + sin16(y * x * (cos16(-PlasmaTime) / 256) / 2);
      int16_t hue = ((h / 256) + 128);
      matrix.drawPixel(x, y, CHSV((uint8_t)hue, 255, 64));
    }
  }
  uint16_t OldPlasmaTime = PlasmaTime;
  PlasmaTime += PlasmaShift;
  if (OldPlasmaTime > PlasmaTime) {
    PlasmaShift = (random8(0, 5) * 32) + 64;
  }

  EVERY_N_MILLISECONDS(10) {
    count10ms++;
  }

  unsigned long currentMillis = millis();
  
  if (paused) {
    // Code for handling game pause (not shown)
    for (int i = 48; i < 191; i++) {
      matrix.drawPixel(i, 0, 0); // Black bar behind text
    }
	//hould be modified
    if (ScrollingMsg.UpdateText() == -1) {
      ScrollingMsg.SetText((unsigned char *)txtSnake, sizeof(txtSnake)-1);
    }
    // Code for handling Firebase data (not shown)
  } else {
    matrix.fillScreen(0); // Clear the matrix

    explodeFruit();
    drawFruit();
    
	(startIndex);
    if (currentMillis - previousMillis >= interval) {
      previousMillis = currentMillis;
      nextStep();
    }

    char keyPress = fbdo.getData();
	switch(keyPress) {
    case 'w':
      currentInput = UP;
      break;
    case 'a':
      currentInput = LEFT;
      break;
    case 's':
      currentInput = DOWN;
      break;
    case 'd':
      currentInput = RIGHT;
      break;
    case 'm':
      currentApp = AppState_Menu;
      return false;
    case '0':
      currentApp = AppState_Menu;
      return false;
    case '1':
      currentApp = AppState_Tetris;
      return false;
    case '3':
      currentApp = AppState_PixelArt;
      return false;
    case '4':
      currentApp = AppState_GifAnimations;
      return false;
  }

  }
  
  matrix.show(); // Update the LED matrix
  delay(10);
  
  return true;
}

void SnakeGame::drawFruit() {
  matrix.drawPixel(fruitX, fruitY, matrix.ColorHSV(fruitHue, 255, 255));
}

void SnakeGame::nextStep() {
  for(int i=snakeLength-1; i>0; i--){
    snakeX[i] = snakeX[i-1];
    snakeY[i] = snakeY[i-1];
  }
  switch(currentInput){
    case UP:
      snakeY[0] = snakeY[0]+1;
      break;
    case RIGHT:
      snakeX[0] = snakeX[0]+1;
      break;
    case DOWN:
      snakeY[0] = snakeY[0]-1;
      break;
    case LEFT:
      snakeX[0] = snakeX[0]-1;
      break;
  }
  
  // Check if head has hit fruit
  if((snakeX[0] == fruitX) && (snakeY[0] == fruitY)){
    snakeLength++;
    interval -= 5;
    if(interval < 100) interval = 100;

    //Store current fruit values to make explosion
    ex.x = snakeX[0];
    ex.y = snakeY[0];
    ex.r = 1;
    ex.hue = fruitHue;
    
    if(snakeLength < MAX_SNAKE_LENGTH){      
      makeFruit();
    }
  }

  // Check if head has hit body or left play area
  if(isPartOfSnakeBody(snakeX[0], snakeY[0]) || !inPlayField(snakeX[0], snakeY[0])){
    currentInput = NONE;
    matrix.fillScreen(0);
    paused = true;
    // Display score (not shown)
  }
}

void SnakeGame::reset() {
  snakeLength = 1;
  currentInput = UP;
  interval = 250;
  snakeX[0] = matrixWidth / 2;
  snakeY[0] = matrixHeight / 2;
  for(int i=1; i<MAX_SNAKE_LENGTH; i++){
    snakeX[i] = snakeY[i] = -1;
  }
  paused = false;
}

boolean SnakeGame::inPlayField(int x, int y) {
  return (x>=0) && (x<matrixWidth) && (y>=0) && (y<matrixHeight);
}

void SnakeGame::makeFruit() {
  uint8_t x, y;
  x = random(0, matrixWidth);
  y = random(0, matrixHeight);
  while(isPartOfSnake(x, y)){
    x = random(0, matrixWidth);
    y = random(0, matrixHeight);
  }
  fruitX = x;
  fruitY = y;
  // Pick a new fruit color
  fruitHue = random8();
}

boolean SnakeGame::isPartOfSnake(int x, int y) {
  for(int i=0; i<snakeLength-1; i++){
    if((x == snakeX[i]) && (y == snakeY[i])){
      return true;
    }
  }
  return false;
}

boolean SnakeGame::isPartOfSnakeBody(int x, int y) {
  for(int i=1; i<snakeLength-1; i++){
    if((x == snakeX[i]) && (y == snakeY[i])){
      return true;
    }
  }
  return false;
}

void SnakeGame::FillSnakeWithColour(uint8_t colourIndex) {
  startIndex = startIndex + 1;
  for (int i = 0; i < snakeLength; i++) {
    matrix.drawPixel(snakeX[i], snakeY[i], matrix.ColorFromPalette(snakePalette, colourIndex));
    colourIndex += 3;
  }
}

void SnakeGame::explodeFruit() {
  if(ex.r < 7) {
    // Draw explosion effect (not shown)
    if(count10ms % 2 == 0) ex.r++;
  }
}

#endif // COMBINED_SNAKE_GAME_H
