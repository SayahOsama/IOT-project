#ifndef ANIMATION_DISPLAY_H
#define ANIMATION_DISPLAY_H


typedef struct {
  uint8_t width;
  uint8_t height;
  uint8_t frames;
  uint16_t colors;
  uint8_t colors_palette[LED_NUM][RGB_NUM];
  uint16_t frame_sizes[MAX_ANIMATION_FRAMES_ACCEPTED];
  uint16_t animation[MAX_ANIMATION_FRAMES_ACCEPTED][LED_NUM][LED_DATA_SIZE];
}Config;

Config config;

void loadConfigurationFromFlashMem(uint8_t index) {
  // uint32_t delay_val;
  // uint8_t width;
  // uint8_t height;
  // uint8_t frames;
  // uint16_t colors;
  // const uint16_t (*colors_palette)[LED_NUM][RGB_NUM];
  // const uint16_t (*frame_sizes)[MAX_ANIMATION_FRAMES_ACCEPTED];
  // const uint16_t (*animation)[MAX_ANIMATION_FRAMES_ACCEPTED][LED_NUM][LED_DATA_SIZE];
  switch (index) {
    case 0:
      showJump(&matrix);
      break;
    case 1:
      showPikachu(&matrix);
      break;
    case 2:
      showMario(&matrix);
      break;
    case 3:
      showPokeBall(&matrix);
      break;
    case 4:
      showFlower(&matrix);
      break;
    case 5:
      showFish(&matrix);
      break;
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

void displayFromFlash(){
    uint8_t index =0;
    while(index<7){
    loadConfigurationFromFlashMem(index);
    index++;
    matrix.fillScreen(BLACK);
  }
}



#endif