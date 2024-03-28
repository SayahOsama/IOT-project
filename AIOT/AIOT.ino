#include <ArduinoJson.h>
#include <SD.h>
#include <SPI.h>
#include <StreamUtils.h>
#include <Adafruit_GFX.h>
#include <Adafruit_NeoMatrix.h>
#include <Adafruit_NeoPixel.h>
#include "gifs.h"
#include "images.h"
#include "SDTested.h"
#include "WiFiConnection.h"
#include "timeAndDate.h"
#include "ButtonsTested.h"
#include "realTimeDataBase.h"

// #define MAX_ANIMATION_FRAMES_ACCEPTED (8)
// #define LED_NUM (256)
// #define RGB_NUM (3)
// #define LED_DATA_SIZE (3)
// #define DATA_PIN (13)
// // #define matrixWidth (32)
// // #define matrixHeight (32)
// #define matrixWidth (16)
// #define matrixHeight (16)
// #define tileWidth (16)
// #define tileHeight (16)
// #define tilesNum (2)
// #define Brightness (3)
// #define BLACK (0)
// #define GIF_Repetitions (12)
// #define flashMemGifs (6)


// Adafruit_NeoMatrix matrix = Adafruit_NeoMatrix(matrixWidth, matrixHeight,tilesNum,tilesNum, DATA_PIN,
//   NEO_MATRIX_BOTTOM + NEO_MATRIX_RIGHT + NEO_MATRIX_COLUMNS + NEO_MATRIX_ZIGZAG
//   + NEO_TILE_TOP + NEO_TILE_RIGHT+  NEO_TILE_ROWS + NEO_TILE_PROGRESSIVE,
//   NEO_GRB + NEO_KHZ800);
  // Adafruit_NeoMatrix matrix = Adafruit_NeoMatrix(tileWidth, tileHeight,DATA_PIN,
  // NEO_MATRIX_BOTTOM + NEO_MATRIX_RIGHT +
  // NEO_MATRIX_COLUMNS + NEO_MATRIX_ZIGZAG,
  // NEO_GRB + NEO_KHZ800);
  
// struct Config {
//   uint8_t width;
//   uint8_t height;
//   uint8_t frames;
//   uint16_t colors;
//   uint8_t colors_palette[LED_NUM][RGB_NUM];
//   uint16_t frame_sizes[MAX_ANIMATION_FRAMES_ACCEPTED];
//   uint16_t animation[MAX_ANIMATION_FRAMES_ACCEPTED][LED_NUM][LED_DATA_SIZE];
// };
File root,gifFile;
Config config;                                
// bool SDCardPresent = false;
// bool GifsDirPresent = false;
// bool IamgesDirPresent = false;
// SD_RET CurrSDRet=SUCCESS;


bool on =  false;
//int navigate=0;///default gifs
//
bool paussed=false;


// enum Mode{
//   flash_gifs,
//   flash_images,
//   sd_gifs,
//   sd_images,
//   app_gifs,
//   app_images,
//   app_text,
//   wifi_clock,
//   app_game_tetris,
//   app_game_snake,
//   none
// };
// Module module=Menu;
// Mode mode=none;


/**************************** config & mem ************************************/
// void loadConfigurationFromFlashMem(uint8_t index) {
//   // uint32_t delay_val;
//   // uint8_t width;
//   // uint8_t height;
//   // uint8_t frames;
//   // uint16_t colors;
//   // const uint16_t (*colors_palette)[LED_NUM][RGB_NUM];
//   // const uint16_t (*frame_sizes)[MAX_ANIMATION_FRAMES_ACCEPTED];
//   // const uint16_t (*animation)[MAX_ANIMATION_FRAMES_ACCEPTED][LED_NUM][LED_DATA_SIZE];
//   switch (index) {
//     case 0:
//       showJump(&matrix);
//       break;
//     case 1:
//       showPikachu(&matrix);
//       break;
//     case 2:
//       showMario(&matrix);
//       break;
//     case 3:
//       showPokeBall(&matrix);
//       break;
//     case 4:
//       showFlower(&matrix);
//       break;
//     case 5:
//       showFish(&matrix);
//       break;
//   }
// }

// void loadConfiguration(fs::FS &sd,const char *filename, Config &config) {
//   File file = sd.open(filename);

//   //simpler because we dont need to specify doc size but still not the most stable, but fastest.
//   JsonDocument doc;
//   ReadBufferingStream bufferedFile(file, 64);
//   DeserializationError error = deserializeJson(doc, bufferedFile);

//   if (error)
//     Serial.println(F("Failed to read file, using default configuration"));

//   config.width = doc["width"];
//   config.height = doc["height"];
//   config.frames = doc["frames"];
//   config.colors = doc["colors"];
  
//   for(uint16_t j = 0; j < config.colors; j++){
//     JsonArray curr_color = doc["colors_palette"][j];
//     config.colors_palette[j][0] = curr_color[0];
//     config.colors_palette[j][1] = curr_color[1];
//     config.colors_palette[j][2] = curr_color[2];
//   }

  
//   for(uint16_t j = 0; j < config.frames; j++){
//     config.frame_sizes[j] = doc["frame_sizes"][j];
//     JsonArray curr_frame = doc["animation"][j];
//       for(uint16_t i = 0; i < config.frame_sizes[j]; i++){
//         JsonArray curr_led = curr_frame[i];
//         int starting_index = curr_led[1];
//         int length = curr_led[2];
//         int stoping_index = starting_index + length;
//         for(uint16_t k = starting_index ; k < stoping_index; k++){
//           int curr=curr_led[0];
//           config.animation[j][k][0] = config.colors_palette[curr][0];
//           config.animation[j][k][1] = config.colors_palette[curr][1]; 
//           config.animation[j][k][2] = config.colors_palette[curr][2];
//         }
//       }
//   }

//   file.close();
// }

// void displayFromFlash(){
//     uint8_t index =0;
//     while(index<7){
//     loadConfigurationFromFlashMem(index);
//     index++;
//     matrix.fillScreen(BLACK);
//   }
// }

/******************************** SD ******************************************/
// void handleSDCardFail(SD_RET fail){
//     switch (fail) {
//     MOUNT_FAILED:
//       Serial.println("MOUNT_FAILED");
//       displayMessage("MOUNT FAILED");
//     NO_SD:
//       Serial.println("NO_SD");
//       displayMessage("NO SD");
//     OPEN_FAILED;
//       Serial.println("OPEN_FAILED");
//       displayMessage("NO DIR");     
//     NOT_DIR:
//       Serial.println("NOT_A_DIR");
//       displayMessage("NOT A DIR");
//     DIR_EMPTY:
//       Serial.println("DIR_EMPTY");
//       displayMessage("DIR EMPTY");    
//   }

// }

// bool SDGifsValid(){
//   CurrSDRet = DirSetUp("/gifs");
//   if(CurrSDRet==SUCCESS){
//     GifsDirPresent=true;
//     return true;
//   }
//   GifsDirPresent=false;
//   return false;
// }
// bool SDImagesValid(){
//   CurrSDRet = DirSetUp("/images");
//   if(CurrSDRet==SUCCESS){
//     IamgesDirPresent=true;
//     return true;
//   }
//   IamgesDirPresent=false;
//   return false;
// }

// void SDCheckAndUpdate(){
//   Serial.println("SDCheckAndUpdate");
//   CurrSDRet = SDSetUp();
//   if (CurrSDRet==SUCCESS){
//     SDCardPresent=true;
//   }else{
//     SDCardPresent=false;
//   }


// }

// void SDSetUpInitial(){
//   Serial.println("sdInitialSetup");
//   SDCheckAndUpdate();
//   if (!SDCardPresent){
//     handleSDCardFail(CurrSDRet);
//   }
// }

/**************8**************** Matrix ***************************************/
void matrixSetUp(){```````````````````````````````````
  Serial.println("matrixSetup");
  matrix.begin();
  matrix.setBrightness(Brightness);
  matrix.fillScreen(BLACK);

  matrix.setTextWrap(false); // we don’t want text to wrap so that it can scroll nicely

}



/////////////////////////
// class Mode {
// public:
//     virtual void setUp() = 0;
//     virtual void begin() = 0;
//     virtual bool handleConfirmButton() = 0;
//     virtual void handleNavigateButton() = 0;
//     virtual void handleOnOffButton() {
//         handleButtonOnOff();
//     }

//     virtual PressType handleAllButtonsInMode() {
//         return handleAllButtons(handleOnOffButton, handleNavigateButton, handleConfirmButton);
//     }

//     virtual void displayNavigationMessage(String text) {
//         int16_t textWidth = matrix.width() * text.length();
//         matrix.fillScreen(0); // Clear the screen
//         // Calculate the start position based on text length
//         int16_t startPosition = matrix.width();
//         if (textWidth < matrix.width()) {
//             startPosition = (matrix.width() - textWidth) / 2;
//         }

//         // Calculate the vertical centering position
//         int16_t verticalPosition = (matrix.height() - 7) / 2;
//         // Set the cursor position (x, y) for horizontal centering and vertical centering
//         matrix.setCursor(startPosition, verticalPosition);
//         matrix.print(text); // Print the text
//         matrix.show();
//         while (currPress == NoPress) {
//             currPress = handleAllButtonsInMode();
//         }
//     }
// };

// class Menu : public Mode {
//     Module toggledModl;
// public:
//     void setUp() override {
//         toggledModl = SD_card;
//     }

//     void handleConfirmButton() override {
//         module = toggledModl;
//     }

//     void handleNavigateButton() override {
//         toggledModl = (toggledModl == SD_card) ? WiFi : SD_card;
//     }

//     void begin() override {
//       currPress = NoPress;
//       while (currPress != Confirm) {
//           String text = (toggledModl == WiFi) ? "WiFi" : "SD_card";
//           displayNavigationMessage(text);
//       }
//     }
// };


// class SDMode : public Mode {
//   mode toggledMod;
// public:
//     void setUp() override {
//       toggledModl=SD_card;
//       toggledMod=sd_gifs;
//     }

//     void handleConfirmButton() override {
//       mode=toggledMod;
//     }

//     void handleNavigateButton() override {
//       toggledMod = (toggledMod == sd_gifs) ? sd_images : sd_gifs;
//     }

//     void begin() override {
//       currPress=NoPress;
//       while(currPress!=Confirm){
//         String text= (toggledMod == sd_gifs) ? "GIFS" : "IMAGES";
//         displayNavigationMessage(text);
//     }

// };


class WiFiMode : public Mode {
  mode toggledMod;
public:
    void setUp() override {
      toggledModl=WiFi;
      toggledMod=time_stamp;
    }
    void handleConfirmButton() override {
      mode=toggledMod;
    }

    void handleNavigateButton() override {
      toggledMod = (toggledMod == time_stamp) ? sd_images : time_stamp;

    }

    void begin() override {
      currPress=NoPress;
      while(currPress!=Confirm){

        String text= (toggledMod == time_stamp) ? "TIME STAMP" : "APP";
        displayNavigationMessage(text);
    }

};






class SDGifsMode : public SDMode {
public:
    void enter() override {
        // Enter SD GIFs mode
    }

    void exit() override {
        // Exit SD GIFs mode
    }
    // No need to override navigate() and confirm() since they are handled by SDMode
};
class SDImagsMode : public SDMode {
public:
    void enter() override {
        // Enter SD GIFs mode
    }

    void exit() override {
        // Exit SD GIFs mode
    }
    // No need to override navigate() and confirm() since they are handled by SDMode
};
class TimeAndDateMode : public WiFiMode {
public:
    void enter() override {
        // Enter SD GIFs mode
    }

    void exit() override {
        // Exit SD GIFs mode
    }
    // No need to override navigate() and confirm() since they are handled by SDMode
};

class AppMode : public WiFiMode {
public:
    void enter() override {
        // Enter SD GIFs mode
    }

    void exit() override {
        // Exit SD GIFs mode
    }
    // No need to override navigate() and confirm() since they are handled by SDMode
};
}
/******************************* button ****************************************/
// void turnOff(){
//   // setUp();
//    matrix.fillScreen(BLACK);
// }

// void turnOn(){
//   setUp();
// }
// void handleButtonOnOff() {
//   Serial.println("Button ONOFF");
//   on = !on;
//   if(on){
//     turnOff();
//   }else{
//     tuenOn();
//   }

// }


// void handleButtonNavigate() {
//   Serial.println("button Navigate");
//   switch (mode) {
//     case flash_gifs:
      
//       break;
//     case flash_images:
      
//       break;
//     case sd_gifs:
      
//       break;
//     case sd_images:
      
//       break;
//     case app_gifs:
      
//       break;
//     case app_images:
      
//       break;
//     case app_text:
      
//       break;
//     case wifi_clock:
      
//       break;
//     case app_game_tetris:
      
//       break;
//     case app_game_snake:
      
//       break;



//   }

// }

// void handleConfirmButton() {
//   Serial.println("button Pause Resume");
//   paussed = !paussed;


// }


// void displayMessage(String text){
//   int repetitions=1;
//   int16_t textWidth = matrix.width() * text.length();
  
//   for (int i = 0; i < repetitions; i++) {
//     matrix.fillScreen(0); // Clear the screen

//     // Calculate the start position based on text length
//     int16_t startPosition = matrix.width();
//     if (textWidth < matrix.width()) {
//       startPosition = (matrix.width() - textWidth) / 2;
//     }
    
//     // Calculate the vertical centering position
//     int16_t verticalPosition = (matrix.height() - 7) / 2;   
//     // Set the cursor position (x, y) for horizontal centering and vertical centering
//     matrix.setCursor(startPosition, verticalPosition);
//     matrix.print(text); // Print the text
//     matrix.show(); 

//     // Scroll the text horizontally
//     for (int16_t x = startPosition; x >= -textWidth; x--) {
//       matrix.clear(); // Clear the display
//       matrix.setCursor(x, verticalPosition); // Set the position for the text
//       matrix.print(text); // Print the text
//       matrix.show(); // Show the updated display
//       delay(75); // Adjust scrolling speed
//     }
//   }

// }

/**************************** time & date *************************************/
void displayTime(){
  displayMessage(getTime());
}

void displayDate(){
  displayMessage(getDate());

}
/******************************* set up ***************************************/
void setup() {
  Serial.begin(9600);
  while (!Serial) continue;
  delay(2000);

  buttonsSetUp();

  matrixSetUp();

  SDSetUpInitial();

  wifiSetUp();

  TimeAndDateSetUp();

  //buttonsSetUp();
  
}
bool runMenu(){
   bool isRunning = true;
   Menu menu = Menu();
   menu.setup();
   while (isRunning) {
    isRunning = menu.begin();
  }
}
void setup() {
  Serial.begin(9600);
  while (!Serial) continue;
  delay(2000);
  Menu menu;
  menu.s

  buttonsSetUp();

  matrixSetUp();

  SDSetUpInitial();

  wifiSetUp();

  TimeAndDateSetUp();

  //buttonsSetUp();
  
}

  // if(!SDGifsValid()){
  //   handleSDCardFail(CurrSDRet);
  // }


void displayFromSD(fs::FS &sd, const char * dir){
  Serial.println("got to display");
  File directory = sd.open(dir); // Open the "gifs" directory
  if (!directory) { 
    Serial.println("Error opening gifs directory!");// print/handle no Gifs Dir 
  return;
  }

  File currFile;
  char fileName[256]; // Define fileName variable
  char filePath[256]; // Define filePath variable
  while (currFile = directory.openNextFile()) {
    memset(fileName, 0x0, sizeof(fileName));                
    strncpy(fileName, currFile.name(), sizeof(fileName) - 1);
    fileName[sizeof(fileName) - 1] = '\0'; // Ensure null-termination
    snprintf(filePath, sizeof(filePath), "%s/%s", dir, currFile.name());
    loadConfiguration(filePath, config);
    matrix.fillScreen(BLACK);  


    int matWidth=matrix.width();
    int matHeight=matrix.height();

    uint8_t height = (matHeight-config.height)/2;
    uint8_t width = (matWidth-config.width)/2;
    for(uint8_t k = 0; k < GIF_Repetitions; k++){
      for(uint8_t j = 0; j < config.frames; j++){
        for(uint8_t r = height; r < height+config.height; r++){
          for(uint8_t c = width; c < width+config.width; c++){
              uint16_t i = r*matWidth + c;
              uint8_t red =  pgm_read_dword(&(config.animation[j][i][0]));
              uint8_t green = pgm_read_dword(&(config.animation[j][i][1]));
              uint8_t blue = pgm_read_dword(&(config.animation[j][i][2]));  
              matrix.drawPixel( r, c, matrix.Color(red,green,blue)); 
          }
        }
        delay(5);
        matrix.show();
        delay(100);
      }
      
    }
    //gifFile.close();
   }
   Serial.println("done with display");
   //gifsDirectory.rewindDirectory();
  //gifsDirectory.close();
 
}


void loop() {

    Serial.println("got to loop");
    displayFromSD(SD,"/gifs");
    displayFromSD(SD,"/images");
    //displayImges();



    root.close();   
}