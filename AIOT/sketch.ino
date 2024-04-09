// #include <Arduino.h>


// #include <FS.h>
// #include <SD.h>
// #include <SPI.h>
#include <Arduino.h>
#include <Wire.h>

#include <FS.h>
#include <SD.h>
#include <SPI.h>

#include <ArduinoJson.h>
#include <StreamUtils.h>

#include <WiFi.h>
#include <Firebase_ESP_Client.h>

//Provide the token generation process info.
#include <addons/TokenHelper.h>
//Provide the RTDB payload printing info and other helper functions.
#include <addons/RTDBHelper.h>

// put function declarations here:
#define WIFI_SSID "AndroidAp"
#define WIFI_PASSOWRD "050688746"



#include "app.h"
#include "butttons.h"
#include "matrix.h"
#include "menu.h"
#include "sd_card.h"
#include "time.h"
#include <Adafruit_GFX.h>
#include <Adafruit_NeoMatrix.h>
#include <Adafruit_NeoPixel.h>
#include "butttons.h"
#include <ezButton.h>
#include "animations.h"


void setup() {

  Serial.begin(115200);
  while (!Serial) continue;
  delay(2000);
  Serial.println("got to setup");

  on = false;
  
  buttonsSetUp();
  //delay(200);

  matrixSetUp();

  MenuSetUp();
  Serial.print("Modle is ");
  Serial.print(currModule);
  

  configTime(gmtOffset_sec, daylightOffset_sec, ntpServer);
  // Serial.println("after time config");
  currModule == Menu;
  isConnected = connectToWifi();
  if(isConnected){
      
  

  fconfig.api_key = API_KEY;
  fconfig.database_url = DATABASE_URL;

  if (Firebase.signUp(&fconfig, &auth, "", "")) {
      Serial.println("ok");
      signupOK = true;
  }else {
      Serial.printf("%s\n", fconfig.signer.signupError.message.c_str());
      return;
  }

  fconfig.token_status_callback = tokenStatusCallback; 

  Firebase.begin(&fconfig, &auth);
  Firebase.reconnectWiFi(true);

  if(!Firebase.RTDB.beginStream(&modefbdo,"/Mode")){
    Serial.printf("stream i begin error, %s\n\n", modefbdo.errorReason().c_str());
  }
  if(!Firebase.RTDB.beginStream(&textfbdo,"/TextToShow")){
    Serial.printf("stream i begin error, %s\n\n", textfbdo.errorReason().c_str());
  }
  if(!Firebase.RTDB.beginStream(&brightnessfbdo,"/Brightness")){
    Serial.printf("stream i begin error, %s\n\n", brightnessfbdo.errorReason().c_str());
  }    
  if(!Firebase.RTDB.beginStream(&appConnectedfbdo,"/appConnected")){
    Serial.printf("stream i begin error, %s\n\n", appConnectedfbdo.errorReason().c_str());
  } 
  if(!Firebase.RTDB.beginStream(&togglefbdo,"/switch")){
    Serial.printf("stream i begin error, %s\n\n", togglefbdo.errorReason().c_str());
  }
  }
  state = 11;
  currModule=Menu;
  //MenuBegin();

  Serial.println("done with set up");
}

void loop() {

  handleOnOffButton();
// //SHOW TIME
  if(isConnected){
    runApp();
    delay(1000);
  }
  if(on){
      runMen = MenuBegin();
      if(!runMen){//matrix is off
        setup();
        handleOnOffButton();
        return;
      }
      if(runMen&& currModule == WiFiM){
        if(!isConnected){
          displayMessage("connect to wifi");
        }else{
          run_time_and_date();
        }
    }
  
}
   
