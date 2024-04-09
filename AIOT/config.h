#ifndef config_h
#define config_h

#include <Arduino.h>
#include <FS.h>
#include <SD.h>
#include <SPI.h> 

#include <ArduinoJson.h>
#include <StreamUtils.h>

#include "matrix.h"
#include "butttons.h"
#include "time_date.h"


enum Module{
  Menu,
  SD_card,
  WiFiM
};

enum Mode{
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
};

typedef struct {
  uint8_t width;
  uint8_t height;
  uint8_t frames;
  uint16_t colors;
  uint8_t colors_palette[LED_NUM][RGB_NUM];
  uint16_t frame_sizes[MAX_ANIMATION_FRAMES_ACCEPTED];
  uint16_t animation[MAX_ANIMATION_FRAMES_ACCEPTED][LED_NUM][LED_DATA_SIZE];
}Config;

String navigateText = "notin";
Module currModule=Menu;
Mode currMode=sd_gifs;
Module toggledModl=Menu;
Mode toggledMod=sd_gifs;
bool SDCardPresent = false;
bool GifsDirPresent = false;
bool IamgesDirPresent = false;
extern Config config;



class ProjectMode {
public:
    void setUp();
    bool begin();
};



void displayNavigationMessage(String text,PressType (*buttonsHandlerFunction)()) {
  Serial.println("got to display message");
  currPress = NoPress;
  bool stop=false;
  displayStaticMessage(text); 
  while(!stop){
    //delay(50);
    buttonsHandlerFunction();
    //Serial.println(currPress);
    if(currPress == Navigate){
      stop = true;
    }else if(currPress == Confirm){
      stop = true;    
    }

  }

}



void loadConfiguration(fs::FS &sd,const char *filename, Config &config) {
  File file = sd.open(filename);

  //simpler because we dont need to specify doc size but still not the most stable, but fastest.
  JsonDocument doc;
  ReadBufferingStream bufferedFile(file, 64);
  DeserializationError error = deserializeJson(doc, bufferedFile);

  if (error)
    Serial.println(F("Failed to read file, using default configuration"));

  config.width = doc["width"];
  config.height = doc["height"];
  config.frames = doc["frames"];
  config.colors = doc["colors"];
  
  for(uint16_t j = 0; j < config.colors; j++){
    JsonArray curr_color = doc["colors_palette"][j];
    config.colors_palette[j][0] = curr_color[0];
    config.colors_palette[j][1] = curr_color[1];
    config.colors_palette[j][2] = curr_color[2];
  }

  
  for(uint16_t j = 0; j < config.frames; j++){
    config.frame_sizes[j] = doc["frame_sizes"][j];
    JsonArray curr_frame = doc["animation"][j];
      for(uint16_t i = 0; i < config.frame_sizes[j]; i++){
        JsonArray curr_led = curr_frame[i];
        int starting_index = curr_led[1];
        int length = curr_led[2];
        int stoping_index = starting_index + length;
        for(uint16_t k = starting_index ; k < stoping_index; k++){
          int curr=curr_led[0];
          config.animation[j][k][0] = config.colors_palette[curr][0];
          config.animation[j][k][1] = config.colors_palette[curr][1]; 
          config.animation[j][k][2] = config.colors_palette[curr][2];
        }
      }
  }

  file.close();
}



#endif
