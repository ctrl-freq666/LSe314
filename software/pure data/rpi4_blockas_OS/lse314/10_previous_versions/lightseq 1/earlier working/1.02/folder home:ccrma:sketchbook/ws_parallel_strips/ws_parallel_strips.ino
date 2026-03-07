
// + Includes {{{

// Arduino
#include <Arduino.h>

// + }}}


// Number of Adafruit 'LED pixels'
static const int PIXEL_COUNT = 16;


// + PD -> Arduino communication {{{

// Number of colour component (R,G,B,A) values in a message.
static const int COLOUR_COMPONENT_COUNT = PIXEL_COUNT * 4;

// Number of bits in a message, since each colour component is 8 bits
static const int MESSAGE_BIT_COUNT = (COLOUR_COMPONENT_COUNT * 8);
// Number of bytes in a message
static const int MESSAGE_BYTE_COUNT = COLOUR_COMPONENT_COUNT;

// Global variables that are maintained in between calls to loop()
// to keep track of the current progress in receiving a message
//   How many message start bytes in a row we've seen, immediately previous to now
int g_incomingMessage_startBytesSeen;
//   Either -1:
//    a message is not currently being received at the moment (haven't encountered start bytes)
//   or [0 .. MESSAGE_BYTE_COUNT]
//    a message is being received, and this is how many bytes we've got already
int g_incomingMessage_currentSize;
//   Buffer to store the bytes as they come in
uint8_t g_incomingMessage_bytes[MESSAGE_BYTE_COUNT];

// Function which is called when a full message is finally received
// (definition at the bottom)
void onMessageReceived(uint8_t * i_bytes);

// + }}}


// + Arduino -> LED communication {{{

// Choose which pins to use for output.
// Can use any valid output pins.

// Yellow wires on Adafruit Pixels
//uint8_t g_dataPins[PIXEL_COUNT] =  { 23, 25, 27, 29, 31, 33, 35, 37, 39, 41, 43, 45, 47, 49, 51, 53 };
// Green wires on Adafruit Pixels
//uint8_t g_clockPins[PIXEL_COUNT] = {22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52 };
uint8_t g_dataPins[PIXEL_COUNT] =  { 3, 5, 25, 29, 31, 33, 35, 37, 39, 41, 43, 45, 47, 49, 51, 53 };
uint8_t g_clockPins[PIXEL_COUNT] = { 2, 4, 24, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52 };



// The colors of the wires may be totally different so
// BE SURE TO CHECK YOUR PIXELS TO SEE WHICH WIRES TO USE!

// Don't forget to connect the ground wire to Arduino ground,
// and the +5V wire to a +5V supply.

// + }}}


void setup()
{
    // + Setup PD -> Arduino communication {{{

    Serial.begin(115200);
    //Serial.println("Done setup!");

    // To begin with, we haven't seen any message start bytes
    // and a message receipt is not in progress
    g_incomingMessage_startBytesSeen = 0;
    g_incomingMessage_currentSize = -1;

    // + }}}


    // + Setup Arduino -> LED communication {{{

    // Set all data and clock pins to output mode
    for (int pixelNo = 0; pixelNo < PIXEL_COUNT; ++pixelNo)
    {
        pinMode(g_dataPins[pixelNo], OUTPUT);
        pinMode(g_clockPins[pixelNo], OUTPUT);
    }

    // + }}}
}


void loop()
{
    // For as long as there are new bytes waiting in the serial receive buffer
    while (Serial.available() > 0)
    {
        // Get the next one
        int incomingByte = Serial.read();

        // (For debugging) Echo byte back out
        //Serial.write("[");
        //Serial.write(incomingByte);
        //Serial.write("]");

        // If it looks like a message start byte (255) then count it.
        // If we've received four of these in succession then reset flags and counters
        // in expectation of new message contents to come
        if (incomingByte == 255)
        {
            ++g_incomingMessage_startBytesSeen;
            if (g_incomingMessage_startBytesSeen == 4)
            {
                g_incomingMessage_currentSize = 0;

                // Jump straight back to the top of the loop to get the next byte,
                // instead of carrying on below which would mistakenly process the second 255 as message content
                continue;
            }
        }
        else
        {
            g_incomingMessage_startBytesSeen = 0;
        }

        // If a message is in progress
        if (g_incomingMessage_currentSize != -1)
        {
            // Save the incoming byte at the appropriate position in the full message buffer
            // and bump the position counter forward
            g_incomingMessage_bytes[g_incomingMessage_currentSize] = incomingByte;
            ++g_incomingMessage_currentSize;

            // If we've now received the full number of bytes of a message,
            // call out to our seperate function to actually do something with the message,
            // then reset the 'in progress' state as in setup() so that we continue as if
            // a message receipt is not in progress and we haven't seen any message start bytes
            if (g_incomingMessage_currentSize == MESSAGE_BYTE_COUNT)
            {
                onMessageReceived(g_incomingMessage_bytes);
                g_incomingMessage_startBytesSeen = 0;
                g_incomingMessage_currentSize = -1;
            }
        }
    }
}


// + Arduino digital pin utilities {{{

inline void setDigitalPin(uint8_t i_pinNo, int i_value)
// Set a digital pin to a specific value.
//
// Params:
//  i_pinNo:
//   Digital pin number to write to.
//  i_value:
//   0 or 1.
{
    volatile uint8_t * port = portOutputRegister(digitalPinToPort(i_pinNo));
    uint8_t mask = digitalPinToBitMask(i_pinNo);

    if (i_value)
        *port |= mask;
    else
        *port &= ~mask;
}

inline void pulseDigitalPin(uint8_t i_pinNo)
// Set a digital pin HIGH, then LOW.
//
// Params:
//  i_pinNo:
//   Digital pin number to pulse.
{
    volatile uint8_t * port = portOutputRegister(digitalPinToPort(i_pinNo));
    uint8_t mask = digitalPinToBitMask(i_pinNo);

    *port |= mask;
    *port &= ~mask;
}

// + }}}


// + WS2801 utilities {{{

void ws2801WriteColour(uint8_t i_dataPinNo, uint8_t i_clockPinNo,
                       uint8_t i_red, uint8_t i_green, uint8_t i_blue)
// Write an RGB colour value to a WS2801 LED strip.
//
// Call this multiple times in succession to set the colours of multiple successive pixels on the strip -
// first call sets pixel 1, second call pixel 2, etc.
//
// When finished setting pixels, wait 500 microseconds (leaving clock pin low, as it is when this function
// returns) for the LED strip to 'latch' the input and actually change to the new colours. At this point
// the LED strip also resets itself ready to receive another set of colour values.
//
// Params:
//  i_dataPinNo:
//   Arduino digital pin number that is connected to the LED strip's data pin.
//  i_clockPinNo:
//   Arduino digital pin number that is connected to the LED strip's clock pin.
//  i_red, i_green, i_blue:
//   Colour component values, [0 .. 255]
{
    // For each bit in red byte value ([7 .. 0])
    for (int bitNo = 7; bitNo >= 0; --bitNo)
    {
        // Write it to the data pin
        setDigitalPin(i_dataPinNo, i_red & _BV(bitNo));
        // Pulse clock pin
        pulseDigitalPin(i_clockPinNo);
    }

    // For each bit in green byte value ([7 .. 0])
    for (int bitNo = 7; bitNo >= 0; --bitNo)
    {
        // Write it to the data pin
        setDigitalPin(i_dataPinNo, i_green & _BV(bitNo));
        // Pulse clock pin
        pulseDigitalPin(i_clockPinNo);
    }

    // For each bit in blue byte value ([7 .. 0])
    for (int bitNo = 7; bitNo >= 0; --bitNo)
    {
        // Write it to the data pin
        setDigitalPin(i_dataPinNo, i_blue & _BV(bitNo));
        // Pulse clock pin
        pulseDigitalPin(i_clockPinNo);
    }
}

// + }}}


void onMessageReceived(uint8_t * i_bytes)
// Function which is called when a full message is finally received.
// Code to eg. extract values from the message and send them to LEDs would go in here.
//
// Params:
//  i_bytes:
//   The bytes of the received message.
//   This does not include the 'start pattern'.
{
    // (For debugging) Echo a status message back to PD
    //Serial.write("MESSAGE RECEIVED");

    // (For debugging) Echo all bytes back to PD
    uint8_t * bytes = i_bytes;
    for (int pixelNo = 0; pixelNo < PIXEL_COUNT; ++pixelNo)
    {
        Serial.write(bytes[0]);
        Serial.write(bytes[1]);
        Serial.write(bytes[2]);
        Serial.write(bytes[3]);
    
        bytes += 4;
    }

    // For each pixel (ie. each LED strip)
    for (int pixelNo = 0; pixelNo < PIXEL_COUNT; ++pixelNo)
    {
        // Write out the R, G, B colour component values for this pixel,
        // getting the component values from the received buffer of bytes,
        // using that pixel's specific data and clock pins
        ws2801WriteColour(g_dataPins[pixelNo], g_clockPins[pixelNo],
                          i_bytes[0], i_bytes[1], i_bytes[2]);

        // Move i_bytes forward to the next pixel
        i_bytes += 4;
    }

    // Latch data by waiting some time with clock pins low -
    // datasheet says 500 microseconds, but actually wait 1 millisecond to be sure
    delay(1);
}

