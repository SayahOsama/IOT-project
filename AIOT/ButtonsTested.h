#ifndef BUTTONS_TESTED_H
#define BUTTONS_TESTED_H

#include <ezButton.h>

#define  BUTTON_ONOFF_PIN 25
#define  BUTTON_NAVIGATE_PIN 26
#define  BUTTON_PAUSERESUME_PIN 27

ezButton buttonOnOff(25);  
ezButton buttonNavigate(26); 
ezButton buttonConfirm(27); 

enum PressType {
  NoPress,
  OnOff,
  Navigate,
  Confirm
};

enum ButtonState{
  pressed,
  notPressed
};


PressType currPress=NoPress;
ButtonState handleButtonPress(ezButton& button, void (*handlePress)()) {
  button.loop(); // MUST call the loop() function first
  if (button.isPressed()) {
    handlePress();
    return pressed;
  }
  return notPressed;
}




PressType handleAllButtons( void (*handlePress1)(), void (*handlePress2)(),void (*handlePress3)()) {
  currPress=NoPress;                            
  if(handleButtonPress(buttonOnOff,handlePress1)==pressed){
    currPress= OnOff;
  }
  else if (handleButtonPress(buttonNavigate,handlePress2)==pressed){
    currPress= Navigate;
  }
  else if (handleButtonPress(buttonConfirm,handlePress3)==pressed){
    currPress= PauseResume;
  }
  return currPress;

}


// PressType handleAllButtonsPress(){
//   return handleAllButtons(handleButtonOnOff,handleButtonNavigate,handleButtonOk);
  
// }


void buttonsSetUp() {

  Serial.println("buttonSetup");
  buttonOnOff.setDebounceTime(50); // set debounce time to 50 milliseconds
  buttonNavigate.setDebounceTime(50); // set debounce time to 50 milliseconds
  buttonConfirm.setDebounceTime(50);
}

#endif 
// void loop() {

//   handleAllButtonsPress();
// }
