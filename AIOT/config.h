#ifndef config_h
#define config_h


#include "neoMatrix.h"
// #include "AnimationDisplay.h"
// #include "SD_card.h"

typdef enum{
  Menu,
  SD_card,
  WiFi
}Module;

typdef enum{
  flash_gifs,
  flash_images,
  sd_gifs,
  sd_images,
  time_stamp,
  app,
  app_gifs,
  app_images,
  app_text,
  app_game_tetris,
  app_game_snake,
  none
}Mode;


Module module=Menu;
Mode mode=none;

class Mode {
public:
    virtual void setUp() = 0;
    virtual bool begin() = 0;
    virtual bool handleConfirmButton() = 0;
    virtual void handleNavigateButton() = 0;
    virtual void handleOnOffButton() {
        handleButtonOnOff();
    }

    virtual PressType handleAllButtonsInMode() {
        return handleAllButtons(handleOnOffButton, handleNavigateButton, handleConfirmButton);
    }

    virtual void displayNavigationMessage(String text) {
        int16_t textWidth = matrix.width() * text.length();
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
        while (currPress == NoPress) {
            currPress = handleAllButtonsInMode();
        }
    }
};

typedef enum{
  NONE, 
  UP, 
  DOWN, 
  LEFT, 
  RIGHT,
  ACTION
}btnInput;




#endif