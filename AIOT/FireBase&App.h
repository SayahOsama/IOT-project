#ifndef APP_H
#define APP_H

#include <WiFi.h>
#include <Firebase_ESP_Client.h>

//Provide the token generation process info.
#include <addons/TokenHelper.h>
//Provide the RTDB payload printing info and other helper functions.
#include <addons/RTDBHelper.h>
#include "AnimationDisplay.h"
  
// const char* ssid     = "BeSpotEE6B_2.4";
// const char* password = "8B00EE6B";
// const char* ssid     = "AndroidAP";
// const char* password = "050688746";

//network credentials
// #define WIFI_SSID "BeSpotEE6B_2.4"
// #define WIFI_PASSWORD "8B00EE6B"


//RTDB URLefine the RTDB URL
#define DATABASE_URL "https://esp32-connect-za-default-rtdb.europe-west1.firebasedatabase.app/"
// Firebase project API Key
#define API_KEY "AIzaSyDyLFYOYAZmXcouFG2F8akGvTTsgnWFWrg"



//Define Firebase Data object
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig baseConfig;
FirebaseDtring fbdoM;

FirebaseJson json;
FirebaseObject object;

unsigned long sendDataPrevMillis = 0;
bool signupOK = false;
// int RValue =0;
// int GValue =0;
// int BValue =0;

bool save=false;


void loadConfigurationApp(Config &config) {
  // Fetch data from Firebase


  // Make sure to specify the correct path to your JSON data in the database
  Firebase.RTDB.getJSON(&object, "/DynamicGifJSONObject");
  

  if (json.parse(object)) {
    config.width = json["width"].as<int>();
    config.height = json["height"].as<int>();
    config.frames = json["frames"].as<int>();
    config.colors = json["colors"].as<int>();
    

    FirebaseJsonArray colorsArray = json["colors_palette"].as<FirebaseJsonArray>();
    for (int i = 0; i < colorsArray.size(); i++) {
      FirebaseJsonArray curr_color = colorsArray[i].as<FirebaseJsonArray>();
      config.colors_palette[i][0] = curr_color[0].as<int>();
      config.colors_palette[i][1] = curr_color[1].as<int>();
      config.colors_palette[i][2] = curr_color[2].as<int>();
    }

    FirebaseJsonArray animationArray = json["animation"].as<FirebaseJsonArray>();
    for (int i = 0; i < animationArray.size(); i++) {
      FirebaseJsonArray curr_frame = animationArray[i].as<FirebaseJsonArray>();
      config.frame_sizes[i] = curr_frame.size();
      for (int j = 0; j < curr_frame.size(); j++) {
        FirebaseJsonArray curr_led = curr_frame[j].as<FirebaseJsonArray>();
        int starting_index = curr_led[1].as<int>();
        int length = curr_led[2].as<int>();
        int stoping_index = starting_index + length;
        for (int k = starting_index; k < stoping_index; k++) {
          int curr = curr_led[0].as<int>();
          config.animation[i][k][0] = config.colors_palette[curr][0];
          config.animation[i][k][1] = config.colors_palette[curr][1];
          config.animation[i][k][2] = config.colors_palette[curr][2];
        }
      }
    }
  } else {
    Serial.println("Failed to fetch JSON data from Firebase");
  }
}
bool displayFromApp(Config &config) {
  // Make sure the Config object is initialized properly

  matrix.fillScreen(BLACK);
  int matWidth = matrix.width();
  int matHeight = matrix.height();
  uint8_t height = (matHeight - config.height) / 2;
  uint8_t width = (matWidth - config.width) / 2;
  for (uint8_t k = 0; k < reps; k++) {
    for (uint8_t j = 0; j < config.frames; j++) {
      for (uint8_t r = height; r < height + config.height; r++) {
        for (uint8_t c = width; c < width + config.width; c++) {
          uint16_t i = r * matWidth + c;
          uint8_t red = pgm_read_dword(&(config.animation[j][i][0]));
          uint8_t green = pgm_read_dword(&(config.animation[j][i][1]));
          uint8_t blue = pgm_read_dword(&(config.animation[j][i][2]));
          matrix.drawPixel(r, c, matrix.Color(red, green, blue));
        }
      }
      delay(5);
      matrix.show();
      delay(100);
    }
  }
  return true;
}


String getTextToShow() {
  // Define a variable to store the fetched string
  String textToShow;

  // Fetch the string from Firebase
  Firebase.RTDB.getString(&fbdo, "/TextToShow");

  // Check if the operation was successful
  if (fbdo.dataType() == "string") {
    // Retrieve the string value
    textToShow = fbdo.stringData();
    Serial.println("TextToShow fetched successfully: " + textToShow);
  } else {
    Serial.println("Failed to fetch TextToShow from Firebase: " + fbdo.errorReason());
  }

  // Return the fetched string
  return textToShow;
}

void updatetMode(){
  int state=10;  
  if (Firebase.RTDB.getInt(&fbdoM, "/Mode")) {
    if (fbdoM.dataType() == "int") {
      state = fbdoM.intData();
      Serial.println("SUCCESSFULL READ from "+ fbdoM.dataPath()+": " + GValue + "(" + fbdoM.dataType() +")" );
    }
  }
 else {
   Serial.println("FAILED: "+ fbdoM.errorReason());
  }
  mode=state;

  if(mode==app_gifs||mode==app_images){
      if (Firebase.RTDB.getBool(&fbdoM, "/save")) {
      if (fbdoM.dataType() == "bool") {
        save = fbdoM.boolData();
        Serial.println("SUCCESSFULL READ from "+ fbdoM.dataPath()+": " + GValue + "(" + fbdoM.dataType() +")" );
      }
    }
  else {
    Serial.println("FAILED: "+ fbdoM.errorReason());
    }
  }


}

void setup() {
  pinMode(RPIN, OUTPUT);
  pinMode(GPIN, OUTPUT);
  pinMode(BPIN, OUTPUT);


  /* Assign the api key  */
  baseConfig.api_key = API_KEY;

  /* Assign the RTDB URL */
  baseConfig.database_url = DATABASE_URL;

  /* Sign up */
  if (Firebase.signUp(&baseConfig, &auth, "", "")) {
    Serial.println("ok");
    signupOK = true;
  }
  else {
    Serial.printf("%s\n", baseConfig.signer.signupError.message.c_str());
  }

  /* Assign the callback function for the long running token generation task */
  baseConfig.token_status_callback = tokenStatusCallback; //see addons/TokenHelper.h

  Firebase.begin(&baseConfig, &auth);
  Firebase.reconnectWiFi(true);


  SDAppMode sdAppMode;

}

bool displayAppGifs(){
  loadConfigurationApp(config);
  displayFromApp(config);

}

bool displayAppImages(){
  loadConfigurationApp(config);
  displayFromApp(config);
  // if (save){
  //   String jsonString;
  //   serializeJson(json, jsonString);


    
  // }
  
  
}


bool showText(){
  String textToShow = getTextToShow();
  displayMessage(textToShow);
  return ;

}


void runApp() {
       
    updatetMode();
    switch (Mode):
    case app_gifs:
      displayAppGifs();    
      break;
    case app_images:
      displayAppImages();
      break;
    case app_text:
      showText();
      break;
    case app_game_snake:
      startGame();

}

#endif





  // if (Firebase.ready() && signupOK && (millis() - sendDataPrevMillis > 15000 || sendDataPrevMillis == 0)) {
  //   sendDataPrevMillis = millis();
  //    Serial.println();
  //   if (Firebase.RTDB.getInt(&fbdo, "/RGB/R")) {
  //     if (fbdo.dataType() == "int") {
  //       RValue = fbdo.intData();
  //       Serial.println("SUCCESSFULL READ from "+ fbdo.dataPath()+": " + RValue + "(" + fbdo.dataType() +")" );
  //       analogWrite(RPIN, RValue);
  //     }
  //   }
  //   else {
  //     Serial.println("FAILED: "+ fbdo.errorReason());
  //   }

    
  //   if (Firebase.RTDB.getInt(&fbdo, "/RGB/G")) {
  //     if (fbdo.dataType() == "int") {
  //       GValue = fbdo.intData();
  //       Serial.println("SUCCESSFULL READ from "+ fbdo.dataPath()+": " + GValue + "(" + fbdo.dataType() +")" );
  //       analogWrite(GPIN, GValue);
  //     }
  //   }
  //   else {
  //     Serial.println("FAILED: "+ fbdo.errorReason());
  //   }