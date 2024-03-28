#ifndef MENU_H
#define MENU_H
#include "config.h"

class Menu : public Mode {
    Module toggledModl;
public:
    void setUp() override {
        toggledModl = SD_card;
    }

    void handleConfirmButton() override {
        module = toggledModl;
    }

    void handleNavigateButton() override {
        toggledModl = (toggledModl == SD_card) ? WiFi : SD_card;
    }

    bool begin() override {
      currPress = NoPress;
      while (currPress != Confirm) {
          String text = (toggledModl == WiFi) ? "WiFi" : "SD_card";
          displayNavigationMessage(text);
      }
    }
};
class Menu {
public:
  Menu() : menuItem(AppState_Tetris) {}

  void setup() {
    sprintf((char *)txtMenu, "              ");
    matrix.begin(); // Initialize NeoMatrix
    matrix.setTextWrap(false); // Allow text to run off edges
    matrix.setBrightness(50); // Set matrix brightness
    matrix.setFont(&FreeMonoBold9pt7b); // Set your desired font
    matrix.setTextColor(matrix.Color(255, 255, 255)); // Set text color
    matrix.setCursor(0, 0); // Set text cursor position
    menuChanged(AppState_Tetris);
  }

  boolean loop() {
    // Rainbow background
    uint32_t ms = millis();
    int32_t yHueDelta32 = ((int32_t)cos16( ms * 27 ) * (350 / matrix.width()));
    int32_t xHueDelta32 = ((int32_t)cos16( ms * 39 ) * (310 / matrix.height()));
    DrawOneFrame( ms / 65536, yHueDelta32 / 32768, xHueDelta32 / 32768);

    // Black bar behind text
    uint8_t blackBarStartRow = (matrix.width() - matrix.fontHeight()) / 2;
    uint8_t blackBarWidth = matrix.fontHeight();
    for(uint8_t row = 0; row < blackBarWidth + 2; ++row){
      for(uint8_t col = 0; col < matrix.width(); ++col){
        matrix.drawPixel(col, blackBarStartRow + row - 1, matrix.Color(0, 0, 0)); // Black color
      }
    }

    displayMenu();
    
    // Firebase logic to handle button presses
    if (Firebase.available()) {
      String keyPress = Firebase.getString("keyPress"); // Assuming keyPress is the variable holding button press data
      if (!keyPress.isEmpty()) {
        switch(keyPress.charAt(0)) {
          case 'a':
            menuItem = (ApplicationState)((AppState_Menu + 1) == menuItem ? (AppState_Amount - 1) : (menuItem - 1));
            menuChanged(menuItem);
            break;
          case 'd':
            menuItem = (ApplicationState)((AppState_GifAnimations == menuItem) ? (AppState_Menu + 1) : (menuItem + 1));
            menuChanged(menuItem);
            break;
          case 'y':
            currentApp = menuItem; // Assuming currentApp is the variable holding the selected application state
            return false;
          case '1':
            currentApp = AppState_Tetris;
            return false;
          case '2':
            currentApp = AppState_Snake;
            return false;
          case '3':
            currentApp = AppState_PixelArt;
            return false;
          case '4':
            currentApp = AppState_GifAnimations;
            return false;
        }
      }
    }

    return true;
  }

  void DrawOneFrame(byte startHue8, int8_t yHueDelta8, int8_t xHueDelta8) {
    byte lineStartHue = startHue8;
    for(byte y = 0; y < matrix.height(); y++) {
      lineStartHue += yHueDelta8;
      byte pixelHue = lineStartHue;      
      for(byte x = 0; x < matrix.width(); x++) {
        pixelHue += xHueDelta8;
        matrix.drawPixel(x, y, HsvToRgb(pixelHue * 256, 255, 255));
      }
    }
  }

private:
  Adafruit_NeoMatrix matrix = Adafruit_NeoMatrix(8, 8, 1, 1, 6,
      NEO_MATRIX_TOP     + NEO_MATRIX_LEFT +
      NEO_MATRIX_COLUMNS + NEO_MATRIX_ZIGZAG,
      NEO_GRB            + NEO_KHZ800);

  char txtMenu[15];
  ApplicationState menuItem;

  void menuChanged(ApplicationState menuItem) {
    switch (menuItem) {
      case AppState_Tetris:
        //Tetris highlighted
        sprintf((char *)txtMenu, "      TETRIS  ");
        break;
      case AppState_Snake:
        //Snake highlighted
        sprintf((char *)txtMenu, "       SNAKE  ");
        break;
      case AppState_GifAnimations:
        //Breakout highlighted
        sprintf((char *)txtMenu, "      GIFS    ");
        break;
      case AppState_PixelArt:
        //Animation highlighted
        sprintf((char *)txtMenu, "   PIXEL ART  ");
        break;
    }
  }
  
  void displayMenu() {
    matrix.fillScreen(matrix.Color(0, 0, 0)); // Clear the matrix
    matrix.setCursor(0, (matrix.height() - matrix.fontHeight()) / 2); // Center text vertically
    matrix.print(txtMenu);
    matrix.show(); // Update the matrix
  }
};
#endif