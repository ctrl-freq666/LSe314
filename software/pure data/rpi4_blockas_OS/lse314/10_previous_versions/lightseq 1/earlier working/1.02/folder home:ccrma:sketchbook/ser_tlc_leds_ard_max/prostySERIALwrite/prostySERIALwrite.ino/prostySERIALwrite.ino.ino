
#include"Tlc5940.h";
//#include"Tlc_config.h";
String readString;

int valn = 0;

void setup() {
 
Serial.begin(115200);
Tlc.init();
}

void loop() {
 
  while (Serial.available()) {
    char c = Serial.read();  //gets one byte from serial buffer
    readString += c; //makes the string readString
   // delay(2);
  } //slow looping to allow buffer to fill with next character
for (int i = 0; i<128 ; i++) {
  if (readString.length() >0) {
    valn = (readString.substring(i,i+1)).toInt();
    valn = map(valn,0,9,0,4095);
    Tlc.set(i , valn);
   
  }
}
      Tlc.update();
      readString = "";
}




