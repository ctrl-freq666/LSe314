// prubuje kontrolowac led na tlc z maxa / pd
#include "Tlc5940.h"
 int channel = 0;
 int value = 0;
String myString;
//float razem[4];
// byte buffer[8]; // buffer to stare serial input from pd
 
void setup()
{
   Serial.begin(9600); //Baud set at 9600 for compatibility, CHANGE!
  Tlc.init();
}
void loop() {
  // if there's any serial available, read it:
  while (Serial.available() > 0) {
        // look for the next valid integer in the incoming serial stream:
 //channel = Serial.parseFloat();
 for (int i = 0; i <= 100; i++) {
myString[i] = Serial.read(); 
Serial.println(myString[i]);
}
Serial.println('\n');
//myString = Serial.readString();
//channel = Serial.parseInt();
//channel = Serial.read();
//if (Serial.read() == 
        // do it again:
//value = Serial.parseInt();
//value = Serial.read();

    // do it again:
      // look for the newline. That's the end of your sentence:
     if (Serial.read() == ('\n')) {
    // channel = Serial.read();
   Serial.println(myString);
   //  Serial.println(value);
  // Tlc.clear();
 //    Tlc.set(channel, value);
//  Serial.println(razem[0]);
  
   //    Tlc.update();

    }
}}
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
