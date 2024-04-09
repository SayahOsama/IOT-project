#ifndef MENU_H
#define MENU_H

#include "config.h"
#include "SD_card.h"

Module InitCurrModule() { return Menu; }
Mode InitcurrMode() { return sd_gifs;}
Module InittoggledModl() { return Menu;}
Mode InittoggledMod(){return sd_gifs;}
bool InitSDCardPresent() { return false;}
bool InitGifsDirPresent() { return false;}
bool InitIamgesDirPresent() { return false;}


Module currModule=Menu;
Mode currMode=sd_gifs;
Module toggledModl=Menu;
Mode toggledMod=sd_gifs;
bool SDCardPresent = false;
bool GifsDirPresent = false;
bool IamgesDirPresent = false;

Global functions
void handleConfirmButtonTEST() {
  currMode = toggledMod;
  if( currMode == sd_gifs ){
    navigateText = "IMAGES";
  }else if( currMode == sd_images){
    navigateText = "GIFS";
  }
  Serial.print(" ****confirmed mod in SD is  ");
  Serial.print(navigateText);
  Serial.println("****");
  Serial.println();
}

void handleNavigateButtonTEST() {
    Serial.print("***got to navigate in SD***");
    if(toggledMod == sd_gifs){
        toggledMod = sd_images;
        navigateText = "IMAGES";
    }else {
        toggledMod = sd_gifs;
        navigateText = "GIFS";
    }
}

PressType handleAllButtonsInTEST() {
    PressType pres = handleAllButtons(handleOnOffButton, handleNavigateButtonTEST, handleConfirmButtonTEST);
    return pres;
}

void displayNavigationMessagTEST(String text) {
    displayNavigationMessage(text, handleAllButtonsInTEST);
}


/********************************************/
void handleConfirmButtonDISPLAY() {

}

void handleNavigationButtonDISPLAY() {
    Serial.print("***got to navigate in SD***");
    if(toggledMod == sd_gifs){
        toggledMod = sd_images;
        navigateText = "IMAGES";
    }else {
        toggledMod = sd_gifs;
        navigateText = "GIFS";
    }
    currMode = toggledMod;
}

PressType handleAllButtonsDISPLAY() {
    PressType pres = handleAllButtons(handleOnOffButton, handleNavigationButtonDISPLAY, handleConfirmButtonDISPLAY);
    return pres;
}


bool displayFromSD( const char * dir){
  Serial.println("got to display");
  File directory = SD.open(dir); // Open the "gifs" directory
  if (!directory) { 
    Serial.println("Error opening gifs directory!");// print/handle no Gifs Dir 
    return false;
  }

  File currFile;
  char fileName[256]; // Define fileName variable
  char filePath[256]; // Define filePath variable
  while (currFile = directory.openNextFile()) {
    memset(fileName, 0x0, sizeof(fileName));                
    strncpy(fileName, currFile.name(), sizeof(fileName) - 1);
    fileName[sizeof(fileName) - 1] = '\0'; // Ensure null-termination
    snprintf(filePath, sizeof(filePath), "%s/%s", dir, currFile.name());
    loadConfiguration(SD,filePath, config);
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
              handleAllButtonsDISPLAY();
              if(currPress == Navigate){
                currFile.close();
                directory.close();
                return true;
              }else if (currPress == OnOff){
                return false;
              }
          }
        }
        delay(5);
        matrix.show();
        delay(100);
      }
          
    }
    currFile.close();
  }
  Serial.println("done with display");
    //gifsDirectory.rewindDirectory();
  directory.close();
  return true;    
}

bool SDModedisplayFromSDInTEST( const char * dir){
  return displayFromSD(dir); 
}




void handleConfirmButtonMenu() {
  currModule = toggledModl;
  if( currModule == SD_card ){
    navigateText = "SD_card";
  }else if( currModule == WiFiM){
    navigateText = "WiFi";
  }
  Serial.print(" ****confirmed mod is  ");
  Serial.print(navigateText);
  Serial.println("****");
  Serial.println();
}

void handleNavigateButtonMenu() {
    Serial.print("***got to navigate in menu***");
    if(toggledModl == SD_card){
        toggledModl = WiFiM;
        navigateText = "WiFiM";
    }else {
        toggledModl = SD_card;
        navigateText = "SD_card";
    }
}

PressType handleAllButtonsInMenu() {
    PressType pres = handleAllButtons(handleOnOffButton, handleNavigateButtonMenu, handleConfirmButtonMenu);
    return pres;
}

void displayNavigationMessagMenu(String text) {
    displayNavigationMessage(text, handleAllButtonsInMenu);
}


void MenuSetUp() {
  // Serial.begin(115200);
  Serial.println("got to menu setup");
  toggledModl = SD_card;
  navigateText = "SD CARD";
  ///////////////////////////////////////////////
    Serial.println("got to sd setup");
    // toggledModl = SD_card;
    // toggledMod = sd_gifs;
    // navigateText = "GIFS";
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



bool MenuBegin() {
  Serial.println();
  Serial.println("got to menu begin");
  currPress = NoPress;
  while(currPress !=Confirm ){  
    currPress = NoPress;
    Serial.print("current modle is: ");
    Serial.print(navigateText);
    Serial.println();
    displayNavigationMessagMenu(navigateText);
  }
  toggledMod = sd_gifs;
  navigateText = "GIFS";
  currPress = NoPress;
  if(IamgesDirPresent && GifsDirPresent){
    while(currPress !=Confirm ){  
    currPress = NoPress;
    Serial.print("current mod is: ");
    Serial.print(navigateText);
    Serial.println();
    displayNavigationMessagTEST(navigateText);
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
  if(currModule == WiFiM){
    ///time and date
    return true;
  }
  bool run=true;
  
  while(run){
    currPress = NoPress;
    String strDir = (toggledMod == sd_images) ? "/images" : "/gifs" ;
    const char* dir = strDir.c_str();
    Serial.print("currently about to display dir : ");
    Serial.println(strDir);
    run = displayFromSD(dir);
    if(!run){
      //matrix hvbeen turned of
      return false;
    }
  }      
  Serial.println("done with sd begin"); 
  return true;
}


#endif
