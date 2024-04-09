#ifndef SD_CARD_H
#define SD_CARD_H

#include "config.h"
//#include "animation_display.h"
#include <FS.h>
#include <SD.h>
#include <SPI.h>



enum SD_RET{
  SUCCESS,
  MOUNT_FAILED,
  NO_SD,
  SD_EMPTY,
  DIR_NOT_FOUND,
  OPEN_FAILED,
  NOT_A_DIR,
  DIR_EMPTY
};

SD_RET CurrSDRet=SUCCESS;



void listDir(fs::FS &fs, const char * dirname, uint8_t levels){
    Serial.printf("Listing directory: %s\n", dirname);

    File root = fs.open(dirname);
    if(!root){
        Serial.println("Failed to open directory");
        return;
    }
    if(!root.isDirectory()){
        Serial.println("Not a directory");
        return;
    }

    File file = root.openNextFile();
    while(file){
        if(file.isDirectory()){
            Serial.print("  DIR : ");
            Serial.println(file.name());
            if(levels){
                listDir(fs, file.path(), levels -1);
            }
        } else {
            Serial.print("  FILE: ");
            Serial.print(file.name());
            Serial.print("  SIZE: ");
            Serial.println(file.size());
        }
        file = root.openNextFile();
    }
}

void createDir(fs::FS &fs, const char * path){
    Serial.printf("Creating Dir: %s\n", path);
    if(fs.mkdir(path)){
        Serial.println("Dir created");
    } else {
        Serial.println("mkdir failed");
    }
}

void removeDir(fs::FS &fs, const char * path){
    Serial.printf("Removing Dir: %s\n", path);
    if(fs.rmdir(path)){
        Serial.println("Dir removed");
    } else {
        Serial.println("rmdir failed");
    }
}


void writeFile(fs::FS &fs, const char * path, const char * message){
    Serial.printf("Writing file: %s\n", path);

    File file = fs.open(path, FILE_WRITE);
    if(!file){
        Serial.println("Failed to open file for writing");
        return;
    }
    if(file.print(message)){
        Serial.println("File written");
    } else {
        Serial.println("Write failed");
    }
    file.close();
}

SD_RET SDMount(){
  if(!SD.begin()){
    Serial.println("Card Mount Failed");
    return MOUNT_FAILED;
  }
  Serial.println("SD CARD MOUNT SUCCESS");
  return SUCCESS;
}

SD_RET  SDExists(){
  uint8_t cardType = SD.cardType();
    if(cardType == CARD_NONE){
        Serial.println("No SD card attached");
        return NO_SD;
    }
    Serial.println("SD CARD EXISTS SUCCESS");
    return SUCCESS;
}

SD_RET  DirExists(fs::FS &fs, const char * dirname){

    File root = fs.open(dirname);
    if(!root){
        Serial.println("Failed to open directory");
        return OPEN_FAILED;
    }
    if(!root.isDirectory()){
        Serial.println("Not a directory");
        return NOT_A_DIR;
    }
    Serial.println("DIR EXISTS SUCCESS");
    return SUCCESS;
}

SD_RET  DirNotEmpty(fs::FS &fs, const char * dirname){
  bool empty=true;

  File root = fs.open(dirname);
  File file = root.openNextFile();
  if(file) empty=false;
  Serial.println("DIR EMPTY OR NOT");
  return empty==true ? DIR_EMPTY : SUCCESS;
}

SD_RET DirSetUp(const char * dirname){
  SD_RET ret=SUCCESS;
  ret = DirExists(SD,dirname);
  if(ret!=SUCCESS) return ret;
  ret = DirNotEmpty(SD,dirname);
  return ret;

}

SD_RET SDSetUpInitial(){
  SD_RET ret=SUCCESS;
    //Serial.begin(115200);
    delay(2000);
    ret = SDMount();
    if(ret!=SUCCESS) return ret;
    ret = SDExists();
    if(ret!=SUCCESS) return ret;
    // ret = DirExists(SD,dirname);
    // if(ret!=SUCCESS) return ret;
    // ret = DirNotEmpty(SD,dirname);  
    return ret;
}

void handleSDCardFail(SD_RET fail){
    switch (fail) {
    MOUNT_FAILED:
      Serial.println("MOUNT_FAILED");
      displayMessage("MOUNT FAILED");
      break;
    NO_SD:
      Serial.println("NO_SD");
      displayMessage("NO SD");
      break;
    OPEN_FAILED;
      Serial.println("OPEN_FAILED");
      displayMessage("NO DIR");     
      break;
    NOT_DIR:
      Serial.println("NOT_A_DIR");
      displayMessage("NOT A DIR");
      break;
    DIR_EMPTY:
      Serial.println("DIR_EMPTY");
      displayMessage("DIR EMPTY"); 
        break;   
  }

}

bool SDSetUpSuccess(){
  Serial.println("SD Check And Update");
  CurrSDRet = SDSetUpInitial();
  if (CurrSDRet==SUCCESS){
    return true;
  }
  return false;
}

bool SDSetUp(){
  Serial.println("SD Set Up");
  
  if (!SDSetUpSuccess()){
    handleSDCardFail(CurrSDRet);  
    return false; 
 }
 return true;
}

bool CheckSDInsertion(){
  if (SDSetUpSuccess()){
    displayMessage("SD INSERTED");
    return true;
  }
  return false;
    
}

void handleConfirmButtonSDcard() {
  Serial.println("***confirm***");
  currMode = toggledMod;
}

void handleNavigateButtonSDcard()  {
  if(toggledMod == sd_gifs){
    toggledMod = sd_images;
    navigateText = "IMAGE";
  }else {
    toggledMod = sd_gifs;
    navigateText = " GIFS"; 
  }
  
  Serial.print("the new mod is ");
  Serial.print(navigateText);

  
}

PressType handleAllButtonsInSDMode(){
  currPress = NoPress;
  //Serial.println("got to handleAllButtonsInSDMode");
  PressType pres = handleAllButtons(handleOnOffButton, handleNavigateButtonSDcard, handleConfirmButtonSDcard);
  //delay(1000);
  return pres;
}

void displayNavigationMessageSDMode(String text){
  //Serial.println("got to displayNavigationMessageSDMode");
  displayNavigationMessage(text,handleAllButtonsInSDMode);
}

bool SDModeSDGifsValid(){
  CurrSDRet = DirSetUp("/gifs");
  if(CurrSDRet==SUCCESS){
    GifsDirPresent=true;
    return true;
  }
  GifsDirPresent=false;
  return false;
}

bool SDModeSDImagesValid(){
  CurrSDRet = DirSetUp("/images");
  if(CurrSDRet==SUCCESS){
    IamgesDirPresent=true;
    return true;
  }
  IamgesDirPresent=false;
  return false;
}



#endif
