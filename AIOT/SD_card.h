#ifndef SD_CARD_H
#define SD_CARD_H
#include "FS.h"
#include "SD.h"
#include "SPI.h"
#include "config.h"

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


class SDMode : public Mode {
  mode toggledMod;
  bool SDCardPresent = false;
  bool GifsDirPresent = false;
  bool IamgesDirPresent = false;

public:
    void setUp() override {
      toggledModl=SD_card;
      toggledMod=sd_gifs;
      SDSetUp();
      if(CurrSDRet!=SUCCESS){
        toggledMod=flash_gifs;
        displayMessage("DISPLAYING DEFAULT");
        displayFromFlash();
      }
      SDCardPresent=true;
      if(DirSetUp("/gifs")==SUCSESS){
        GifsDirPresent=true;
      }
      if(DirSetUp("/images")==SUCSESS){
        GifsDirPresent=true;
      }
      
    }
    void handleConfirmButton() override {
      mode=toggledMod;
    }

    void handleNavigateButton() override {
      toggledMod = (toggledMod == sd_gifs) ? sd_images : sd_gifs;
    }

    bool begin() override {
      currPress=NoPress;
      if (GifsDirPresent && IamgesDirPresent) {
        //both exist
        while(currPress!=Confirm){
         String text= (toggledMod == sd_gifs) ? "GIFS" : "IMAGES";
         displayNavigationMessage(text);
        }

      }else if (GifsDirPresent && !IamgesDirPresent) {
        //play only gifs
        while(currPress!=Confirm){
          String text= (toggledMod == sd_gifs) ? "GIFS" : "NO IMAGES";
          displayNavigationMessage(text);
        }

      }else if (!GifsDirPresent && IamgesDirPresent) {
        //play only images
        while(currPress!=Confirm){
          String text= (toggledMod == sd_images) ? "NO GIFS" : "IMAGES";
          displayNavigationMessage(text);
        }

      } else if(!GifsDirPresent && !IamgesDirPresent) {
        //play from mem
        toggledMod=flash_gifs;
        mode=toggledMod;
        displayMessage("NO DIRS");
        displayMessage("DISPLAYING DEFAULT");
        displayFromFlash(); 
      }

      String dir= (toggledMod == sd_images) ? "/gifs" : "/images";
      bool run=true;
      while(run){
        displayFromSD(dir);
      }
      return run;
    }  

};
class SDAppMode : public Mode {
  mode toggledMod;
  bool SDCardPresent = false;
  bool GifsDirPresent = false;
  bool IamgesDirPresent = false;

public:
    void setUp() override {
      toggledModl=WiFi;
      toggledMod=app_gifs;
      SDSetUp();
      if(CurrSDRet!=SUCCESS){
        return;
      }
      SDCardPresent=true;

      if(DirSetUp("/gifs")==SUCSESS){
        GifsDirPresent=true;
      }
      if(DirSetUp("/images")==SUCSESS){
        GifsDirPresent=true;
      }
      
    }
    void saveToSD(string data,const char * dirname ){
      if(!SDCardPresent)return;
      if (!GifsDirPresent){
        createDir(SD,dirname);
      }
      writeFile(SD,dirname,data);
    }

    void saveGifToSd(String gif){
      saveToSD(gif,"/gifs");

    }
    void saveImageToSd(String gif){
      saveToSD(gif,"/images");

    }
};


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


    void renameFile(fs::FS &fs, const char * path1, const char * path2){
        Serial.printf("Renaming file %s to %s\n", path1, path2);
        if (fs.rename(path1, path2)) {
            Serial.println("File renamed");
        } else {
            Serial.println("Rename failed");
        }
    }

    void deleteFile(fs::FS &fs, const char * path){
        Serial.printf("Deleting file: %s\n", path);
        if(fs.remove(path)){
            Serial.println("File deleted");
        } else {
            Serial.println("Delete failed");
        }
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
        //Serial.begin(9600);
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

    bool SDGifsValid(){
      CurrSDRet = DirSetUp("/gifs");
      if(CurrSDRet==SUCCESS){
        GifsDirPresent=true;
        return true;
      }
      GifsDirPresent=false;
      return false;
    }
    bool SDImagesValid(){
      CurrSDRet = DirSetUp("/images");
      if(CurrSDRet==SUCCESS){
        IamgesDirPresent=true;
        return true;
      }
      IamgesDirPresent=false;
      return false;
    }

    void SDCheckAndUpdate(){
      Serial.println("SD Check And Update");
      CurrSDRet = SDSetUpInitial();
      if (CurrSDRet==SUCCESS){
        SDCardPresent=true;
      }else{
        SDCardPresent=false;
      }


    }

    void SDSetUp(){
      Serial.println("SD Set Up");
      SDCheckAndUpdate();
      if (!SDCardPresent){
        handleSDCardFail(CurrSDRet);
      }
    }

    bool CheckSDInsertion(){
      if (SDCheckAndUpdate()==SUCCESS){
        displayMessage("SD INSERTED");
        return true;
      }
      return false;
    }

    bool displayFromSD( const char * dir){
      Serial.println("got to display");
      File directory = SD.open(dir); // Open the "gifs" directory
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
        gifFile.close();
      }
      Serial.println("done with display");
      //gifsDirectory.rewindDirectory();
      gifsDirectory.close();
      return true;
    
    }





// void loop(){

// }
