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
      
  ApsSetup()
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
if(!isconnected){
  connectToWifi();
}
}

   
