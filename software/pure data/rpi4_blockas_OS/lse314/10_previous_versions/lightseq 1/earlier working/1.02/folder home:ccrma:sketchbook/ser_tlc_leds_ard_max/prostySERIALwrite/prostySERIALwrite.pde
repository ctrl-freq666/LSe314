
#include <Tlc5940.h>
#include <tlc_config.h>

String readString;
int valn = 0;
long c = 0;
//int valn[4];
void setup() {

  Serial.begin(9800);
  Tlc.init();
}
void loop() {
  while (Serial.available()) {
 ////   if (Serial.read() != '\n') 
    long c = Serial.read();  //gets one byte from serial buffer
    readString += c; //makes the string readString
    
    Serial.print(c);
 delay(2);
 }
   //slow looping to allow buffer to fill with next character
  for (int i = 0; i<128 ; i++) {
    if (readString.length() >0) {
     valn = (readString.substring(i,i+1)).toInt();
     Serial.println(c);
     Serial.println('\n');
      valn = map(valn,0,9,0,4095);
    Tlc.set(i, valn);
    }
 // Serial.println(valn[0]);
//Serial.println(valn[1]);
  }
//  Serial.println(valn[2]);
  //  Serial.println(valn[3]);
  //  Serial.monitor
Tlc.update();
 readString = "";
  //Serial.println(valn[0]);
//  Serial.println(valn[2]);

 }



