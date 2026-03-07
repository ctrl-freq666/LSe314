// prubuje kontrolowac led na tlc z maxa / pd
#include "Tlc5940.h"
 int channel = 0;
 int value = 0;
 int d = 0;
void setup()
{
   Serial.begin(115200); //Baud set at 9600 for compatibility, CHANGE!
  Tlc.init();
}
void loop() {
  // if there's any serial available, read it:
  while (Serial.available() > 0) {
  // d = Serial.read();
 //  Serial.println(d);
    //  if (Serial.read() == '\!') {  //jesli poczatek zdania czyli spacja / 33
        // look for the next valid integer in the incoming serial stream:
    int channel = Serial.parseInt();
        // do it again:
        Serial.print("wartosc chan");
         Serial.println(channel);
    int value = Serial.parseInt();
    // do it again:
     Serial.println(value);
     Serial.print("wartosc "); 
      // look for the newline. That's the end of your sentence:
      if (Serial.read() == '\n') {
      Serial.print("endofline");
     Tlc.clear();
      Tlc.set(channel, value);
       Tlc.update();
     // }
    }
  }
}

  /*      
void writeTlc() {  // moja pruba zeby dzialalo z TLC

 int channel;
 int value;
 Tlc.clear();
 
 channel = messageGetInt(); // channnel on tlc 0 - 47 ??
 value = messageGetInt();  // value pwm 0-4085
  Tlc.set(channel, value);

  Tlc.update();
}/*/
