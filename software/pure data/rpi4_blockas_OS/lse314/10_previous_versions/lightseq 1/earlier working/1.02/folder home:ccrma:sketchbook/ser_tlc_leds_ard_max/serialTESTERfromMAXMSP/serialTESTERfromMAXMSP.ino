#include <Tlc5940.h>
#include <tlc_config.h>
// Arduino Serial Tester
//long countervalue = 0; // counter value
long serialvalue; // value for serial input
int chan = 0;
int value = 0;
//String serval[];
int started = 0; // flag for whether we've received serial yet
void setup() 
{ 
    Tlc.init();
Serial.begin(9600); // open the arduino serial port
} 

void loop() 
{ 
if(Serial.available()) // check to see if there's serial data in the buffer
{
  
serialvalue = Serial.read();
  //  for (int i = 0; i < 4; i++) {
//serval[i] = Serial.read(); // read a byte of serial data
started = 1; // set the started flag to on
//}
}
if(started) { // loop once serial data has been received
//randomvalue = random(1000); // pick a new random number
//for (int i=0; i < 4; i ++) {
//Serial.print(serval[i]); // print the counter
Serial.print(" "); // print a space
//Serial.print(randomvalue); // print the random value
//Serial.print(" "); // print a space
Serial.print(serialvalue); // echo the received serial value
Serial.println(); // print a line-feed
//countervalue = (countervalue+1)%1000; // increment the counter
delay(500); // pause
}
}

