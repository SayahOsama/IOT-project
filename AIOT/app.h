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
#define WIFI_SSID "yourwifi"
#define WIFI_PASSOWRD "yourpassowrd"
#include "config.h"

bool Appsetup() {
  fconfig.api_key = API_KEY;
  fconfig.database_url = DATABASE_URL;

  if (Firebase.signUp(&fconfig, &auth, "", "")) {
      Serial.println("ok");
      signupOK = true;
  }else {
      Serial.printf("%s\n", fconfig.signer.signupError.message.c_str());
      return false;
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
  return true;
  // if(!Firebase.RTDB.beginStream(&object,"/DynamicGifJSONObject")){
  //   Serial.printf("stream i begin error, %s\n\n", fbdoM.errorReason().c_str());
  // }
}

void run_app_closed(){
  if (Firebase.RTDB.getString(&fbdo, "/GifName")) {
        if (fbdo.dataType() == "string") {
          GifName = fbdo.stringData();
          Serial.print("gif name is ");
          Serial.println(GifName);
       }
      }else {
        Serial.println("failed to read save");
      }
      if(GifName=="showJump"){
        showJump(&matrix);
      }
      else if(GifName=="showPikachu"){
        showPikachu(&matrix);
      }
      else if(GifName=="showMario"){
        showMario(&matrix);
      }
      else if(GifName=="showPokeBall"){
        showPokeBall(&matrix);
      }
      else 
      if(GifName=="showFlower"){
        showFlower(&matrix);
      }
      else if(GifName=="showFish"){
        showFish(&matrix);
      }
}

void get_app_animation_info(){
  if (Firebase.RTDB.getString(&fbdo, "/GifName")) {
      if (fbdo.dataType() == "string") {
        GifName = fbdo.stringData();
        Serial.print("gif name is ");
        Serial.println(GifName);
      }
    if (Firebase.RTDB.getBool(&fbdo, "/save")) {
      if (fbdo.dataType() == "bool") {
          save = fbdo.boolData();
        Serial.print("save is ");
        Serial.println(save);
      }
    }else {
      Serial.println("failed to read save");
    }
  }
}

bool displayAppGifs(){
  loadConfigurationFromFirebase(config);
  displayFromApp(config);
  return true;
}

bool displayAppImages(){
  loadConfigurationFromFirebase(config);
  displayFromApp(config);
  return true;
}

void run_app_gifs(){
  get_app_animation_info();
  if (save){
    setUpSDAppMode();
    saveGifToSdSDAppMode(GifName);
  }
  displayAppGifs();

}  

void run_app_images(){
  get_app_animation_info();
  if (save){
    setUpSDAppMode();
    saveImageToSd(GifName);
  }
   displayAppImages();
}

void run_app_connected(){
  if(!appConnected){
    Serial.println("app not connected");
    displayMessage("app not connected");
    }else{
      Serial.println("app connected");
  }
}

void run_time_and_date(){

    if(isConnected){
      Serial.print("waiting for time");
      while(!getLocalTime(&timeinfo)){
        Serial.print(".");
      }
      Serial.println();

      String timestring = getTime();
      displayStaticMessage(timestring);
      delay(3000);
      Serial.println(timestring);
      String datestring = getDate();
      displayStaticMessage(timestring);
      delay(3000);
      matrix.clear();
      Serial.println(datestring);
    }

}
//hnadle insert sd
String getFilesInDirName(fs::FS &fs, const char * dirname){
  String filenames = "";
  Serial.printf("Listing directory: %s\n", dirname);

    File root = fs.open(dirname);
    if(!root){
        Serial.println("Failed to open directory");
        return  filenames;
    }
    if(!root.isDirectory()){
        Serial.println("Not a directory");
        return filenames;
    }

    File file = root.openNextFile();
    while(file){
      Serial.print("  FILE: ");
      Serial.print(file.name());
      Serial.print("  SIZE: ");
      Serial.println(file.size());
      filenames.concat(String(file.name()));
      filenames.concat(",");
    }
    file = root.openNextFile();
    return filenames;
  }

void run_get_sd_files(){
  String allFiles = "";
  allFiles.concat(getFilesInDirName(SD, "/gifs"));
  allFiles.concat(getFilesInDirName(SD, "/images"));
  if (Firebase.RTDB.setString(&fbdo,allFiles,"/files")) {
      //Serial.println("sent esp conneced");
  }
  else{
    Serial.print("why!");
  }

}


void checkRTDBUpdates(){
  //mode
    if(Firebase.ready() && signupOK){
      if (!Firebase.RTDB.readStream(&modefbdo))
        Serial.printf("stream 1 read error");
      if(modefbdo.streamAvailable()){
        if (modefbdo.dataType() == "int") {
          state = modefbdo.intData();
          Serial.println(state);
          currMode = static_cast<Mode>(state);
        }
      }
    }
  //text
    if (Firebase.ready() && signupOK){
      if (!Firebase.RTDB.readStream(&textfbdo))
        Serial.printf("stream 1 read error");
      if (textfbdo.streamAvailable())
      {
        if (textfbdo.dataType() == "string")
        {
          TextToShow = textfbdo.stringData();
          Serial.println(TextToShow);
          currMode = app_text;
        }
      }
    }
    //get brighness
    if(Firebase.ready() && signupOK){ //state 11 is set brightness
      if (!Firebase.RTDB.readStream(&brightnessfbdo))
        Serial.printf("stream 1 read error");
      if(brightnessfbdo.streamAvailable()){
        if (brightnessfbdo.dataType() == "int") {
          brightne = brightnessfbdo.intData();
          Serial.println(brightne);
          currMode = app_brightness;
        }
      }
    }
      //AppConnected 
    if(Firebase.ready() && signupOK){
      if (!Firebase.RTDB.readStream(&appConnectedfbdo))
        Serial.printf("stream 1 read error");
      if(appConnectedfbdo.streamAvailable()){
        if (appConnectedfbdo.dataType() == "boolean") {
          appConnected = appConnectedfbdo.boolData();
          Serial.println(appConnected);
          if(!appConnected){
            currMode = app;
          }
          //currMode = app;
          //displayMessage(gifname);
          //displayOneGif("/gifs",gifname);
        }
      }
    }

    //matrix on of
    if(Firebase.ready() && signupOK){ //state 11 is set brightness
      if (!Firebase.RTDB.readStream(&togglefbdo))
        Serial.printf("stream 1 read error");
      if(togglefbdo.streamAvailable()){
        if (togglefbdo.dataType() == "boolean") {
           on = togglefbdo.boolData();
           currMode = toggle;
        }
      }
   }
///////esp connected
    if (Firebase.RTDB.setBool(&fbdo,true,"/Esp32Connected")) {
      //Serial.println("sent esp conneced");
    }






}

void run_app_all_sd(){
  SDSetUp();
  if(CurrSDRet!=SUCCESS){
    return;
  }
  SDCardPresent=true;
  if(DirSetUp("/gifs") == SUCCESS){
    displayFromSD("/gifs");
    GifsDirPresent=true;
  }
  if(DirSetUp("/images") == SUCCESS){
    displayFromSD("/images");
    IamgesDirPresent=true;
  }
}

void runApp() {
 if(!isConnected){
      return false;
  }else{
     Appsetup();
 }

  checkRTDBUpdates();
  
  if(currMode==toggle) {
    Serial.print("on is ");
    Serial.print(on);
    on =! on;
    handleOnOff();
    currMode = none;
   } else if(currMode==app) {
     run_app_connected();
      currMode = none;
   } else if(currMode==app_text) {
      Serial.print("app_text");
      displayMessage(TextToShow);
      Serial.print(TextToShow);
   } else if(currMode==app_brightness) {
      matrix.setBrightness(brightne);
      run_time_and_date();
      Serial.print(" mod is");
      Serial.println(currMode);
   } else if(currMode==app_gifs) {
      run_app_gifs();
   } else if(currMode==app_images) {
      run_app_images();
   } else if(currMode==app_closed) {
      run_app_closed();
   } else if(currMode==app_all_sd) {
      run_app_all_sd();
   }  
  else if(currMode==files_names){
    run_get_sd_files();
  }
}


void setUpSDAppMode() {
  toggledModl=WiFiM;
  toggledMod=app_gifs;
  SDSetUp();
  if(CurrSDRet!=SUCCESS){
    return;
  }
  SDCardPresent=true;

  if(DirSetUp("/gifs")==SUCCESS){
    GifsDirPresent=true;
  }
  if(DirSetUp("/images")==SUCCESS){
    GifsDirPresent=true;
  }
  
}
void saveToSDSDAppMode(String strData,const char * dirname ){
  if(!SDCardPresent)return;
  if (!GifsDirPresent){
    createDir(SD,dirname);
  }
  const char* data = strData.c_str();
  writeFile(SD,dirname,data);
}

void saveGifToSdSDAppMode(String gif){
  saveToSDSDAppMode(gif,"/gifs");

}
void saveImageToSd(String gif){
  saveToSDSDAppMode(gif,"/images");

}
