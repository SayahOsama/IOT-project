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
    navigateText = "IMAGES";
  }else {
    toggledMod = sd_gifs;
    navigateText = "GIFS"; 
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



void SDModeSetUp() {
  Serial.println("got to sd setup");
  toggledModl = SD_card;
  toggledMod = sd_gifs;
  navigateText = "GIFS";
  SDSetUp();
  if(CurrSDRet!=SUCCESS){
    toggledMod=flash_gifs;
    displayMessage("DISPLAYING DEFAULT");
    //displayFromFlash();
  }
  SDCardPresent=true;
  if(DirSetUp("/gifs") == SUCCESS){
    GifsDirPresent=true;
  }
  if(DirSetUp("/images") == SUCCESS){
    IamgesDirPresent=true;
  }
  Serial.print("IamgesDirPresent is  :");
  Serial.print(IamgesDirPresent);
  Serial.println();
  Serial.print("GifsDirPresent is : ");
  Serial.print(GifsDirPresent);
  Serial.println();
  Serial.println("done with sd setup");
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

bool SDModedisplayFromSDInSDMode( const char * dir){
  return displayFromSD(dir,handleAllButtonsInSDMode); 
}

bool SDModebegin() {
  Serial.print("*******got to sd begin *********");
  currPress = NoPress;  
 if (GifsDirPresent && IamgesDirPresent) { 
    //both exist
    while(currPress != Confirm ){  
      currPress = NoPress;
      Serial.print("navigate text in sd begin is :  ");
      Serial.print(navigateText);
      Serial.println();
      displayNavigationMessageSDMode(navigateText);
    }
  }
  }else if (GifsDirPresent && !IamgesDirPresent) {
          //play only gifs
    while(currPress!=Confirm){
      String text= (toggledMod == sd_gifs) ? "GIFS" : "NO IMAGES";
      displayNavigationMessageSDMode(text);
    }
  }else if (!GifsDirPresent && IamgesDirPresent) {
          //play only images
    while(currPress!=Confirm){
      String text= (toggledMod == sd_images) ? "NO GIFS" : "IMAGES";
      displayNavigationMessageSDMode(text);
    }
  }else if(!GifsDirPresent && !IamgesDirPresent) {
      //play from mem
    toggledMod = flash_gifs;
    currMode = toggledMod;
    displayMessage("NO DIRS");
    displayMessage("DISPLAYING DEFAULT");
    //displayFromFlash(); 
  }
  Serial.println("******finished sd buttons********");
  bool run=true;
  while(run){
    String strDir = (toggledMod == sd_images) ? "/images" : "/gifs" ;
    const char* dir = strDir.c_str();
    run = SDModedisplayFromSDInSDMode(dir);
  }      
  Serial.println("done with sd begin"); 
  return true;
}



#endif
