//buffer size for NMEA compliant GPS string
//For Razor, set value to 17 instead
#define DATABUFFERSIZE      80
char dataBuffer[DATABUFFERSIZE+1]; //Add 1 for NULL terminator
char startChar = '$'; // or '!', or whatever your start character is
char endChar = '\r';
boolean storeString = false; //This will be our flag to put the data in our buffer

        
boolean getSerialString(){
    static byte dataBufferIndex = 0;
    while(Serial.available()>0){
        char incomingbyte = Serial.read();
        if(incomingbyte==startChar){
            dataBufferIndex = 0;  //Initialize our dataBufferIndex variable
            storeString = true;
        }
        if(storeString){
            //Let's check our index here, and abort if we're outside our buffer size
            //We use our define here so our buffer size can be easily modified
            if(dataBufferIndex==DATABUFFERSIZE){
                //Oops, our index is pointing to an array element outside our buffer.
                dataBufferIndex = 0;
                break;
            }
            if(incomingbyte==endChar){
                dataBuffer[dataBufferIndex] = 0; //null terminate the C string
                //Our data string is complete.  return true
                return true;
            }
            else{
                dataBuffer[dataBufferIndex++] = incomingbyte;
                dataBuffer[dataBufferIndex] = 0; //null terminate the C string
            }
        }
        else{
        }
    }
   
    //We've read in all the available Serial data, and don't have a valid string yet, so return false
    return false;
}





if(getSerialString()){
    //String available for parsing.  Parse it here
}


//That code would go someplace where it gets called at regular intervals, 
//for example right at the start of your loop().  And there you have your serial input routine.  
//All you need to do is specify a start and terminating delimiter, and the maximum data string 
//size to read in virtually any ASCII based data strings.


/*

JHaskell's Blog

Friday, May 6, 2011
Serial Comm Fundamentals on Arduino
First things first, let's lay the foundation for why things have to be done a certain way when writing Serial communication code on the Arduino:
This guide covers how to handle human readable serial data.  Other forms of serial data are outside the scope of this guide.
Not all code samples posted will be fully functional by themselves. They are only meant as iterative examples to illustrate specific aspects of serial communications leading up to the final and fully functional routine.
This guide covers writing code to read serial data coming in on the serial port.  It does not cover how to physically connect to external devices.

Serial speeds vs Arduino speeds

How fast is serial data transmitted?
Serial communications @ 115200 baud (baud equals bits per second)
10 bits per character (115200,8,N,1) = 11,520 characters per second.
This equals 1 character every 86.8 microseconds.

How fast does the Arduino run?
Arduino runs at 16Mhz (mhz = million hz, or million cycles per second)
This is one cycle/instruction every 62.5 nanoseconds (1 microsecond = 1000 nanoseconds).

So, in the time it takes to transmit a single character over the serial line at 115200 baud, the Arduino running at 16Mhz will execute ~1388 instructions.  At 57600 baud, the Arduino will execute 2777 instructions.  At 9600 baud, the Arduino will execute over 16,000 instructions in the time it takes to transmit one character.

What this means is that proper Serial processing on the Arduino requires some form of synchronization with the incoming data so you know when you have all the data to be processed.  There are a variety of ways to accomplish this.  The method this tutorial is going to cover uses what's called delimiting characters.  These characters will be arbitrarily chosen based on the data we're transmitting and how we need to handle it.

ASCII
American Standard Code for Information Interchange
ASCII Table

ASCII is the format used to transmit human readable data over the serial line.  Each byte of data represents a 'character' in the ASCII table. A numeric value in ASCII form is not the same as it's value as say, an int.  The character '1' and the numeric value 1 are not the same.  If you look up the character '1' in an ASCII chart, you will find that it's decimal value is 49.

int i = '1';
Serial.println(i);
i = 1;
Serial.println(i);

Serial output will be:
49
1


  Characters can be divided into two general categories, printable and non-printable characters.  Non-printable characters can also be referred to as control characters.  Carriage Return is an example of a non-printable character.  It is ASCII code 13 in decimal, but it has no 'printable' representation, though it is often referred to as CR.

One thing that is important to know is how to specify these non-printable 'control' characters within your Arduino code.  There are several ways of doing this.  You can use standard escape sequences in your character strings, or you can specify the non-char value in Dec or Hex form:

The following three lines of code all create a char variable named C, and assign it the Carriage Return value.
char c = '\r'; //Use the backslash 'escape character' followed by the 'control' character for Carriage Return
char c = 13; //Use the decimal value for Carriage Return
char c = 0xD; //Use the hexidecimal value for Carriage Return


Delimiters
What is a delimiter?  A delimiter is one or more characters used to specify the boundary between chunks of data in a block of data
For our purposes, we are looking for three delimiters here.  
We are looking for a header or start character, that uniquely identifies the start of a data string. 
We are looking for a terminating or stop character that uniquely identifies the end of a data string.
We are looking for a field or data delimiter that uniquely separates each discrete piece of data in the string.  This delimiter is not involved with reading in the data string itself, but is necessary when it comes to parsing out the individual data values after the entire string has been read in.


These delimiters will allow our Arduino to know exactly when a data string begins and ends, and how to separate and parse the individual chunks of data within the string.


When choosing our delimiting characters, we have to look at the data we are transmitting and select characters that can be uniquely identified from the data characters 100% of the time.  Printable characters have the advantage of being more easily human readable, but in some instances may not be suitable.  For example, if the data we are receiving can contain any human readable characters, then we can't reliably use human readable characters for delimiting.  We would have to resort to using some non-printable characters.  Typically though, the data you are reading into the Arduino will come from some external sensor that transmits that data in a specific format that you will be unable to change.  So let's look at a couple real world examples.  The first will be a GPS module and the second will be an IMU (two external serial devices I frequently see questions on).

The GPS module will be this one: EM-406A SiRF 3 GPS
The IMU will be this one: Sparkfun Razor 9DOF IMU

Now, I am well aware of the TinyGPS library that is available for interfacing with any NMEA compliant GPS module.  I am only using the GPS module as an example of how to look at serial data coming from a sensor and determine what characters to use for delimiting that data.

Some example data strings from the EM-406A (taken out of it's User Manual) are:
$GPGGA,161229.487,3723.2475,N,12158.3416,W,1,07,1.0,9.0,M,,,,0000*18
$GPGLL,3723.2475,N,12158.3416,W,161229.487,A*2C
$GPGSA,A,3,07,02,26,27,09,04,15,,,,,,1.8,1.0,1.5*33

Example data strings from the Razor IMU:
!ANG:320,33,191
!ANG:0,320,90
!ANG:0,0,0

For the GPS module, it is clear from the manual that each string starts with a $ character.  It also appears that the $ character is never used anywhere else in the string.  This is actually part of the NMEA standard for their protocol headers and is intended to be used as the start character for parsing a GPS data string.

Each EM-406A output string is also terminated with a carriage return and line feed.  Line feed is another non-printable character, ascii code 10, that is typically used in conjuction with carriage return as a line terminator.  Since neither the carriage return or line feed is used anywhere else in the data string, we can use either for our terminating character (and with properly written code, it won't matter which we use).

It also becomes clear that each piece of data is separated by a comma.  This will be used as our data delimiting character (and is also a pretty standard character to use for this purpose).

For the Razor IMU, the apparent candidate for the start character is the !.  An alternative start character would be the semicolon character since The !ANG portion is static, ie never changes.  Either one would suffice and have little impact on the code itself.

The Razor strings are also terminated with CR/LF, so we'll use CR for our terminating character as well.

And yet again, the Razour separates the three angles with commas as well.

So those would be our delimiting characters for reading in the data from those two devices.  For the GPS we'd use $, CR, and comma.  For the Razor we'd use ! (or semicolon), CR, and comma.

A note on strings
The Arduino provides two methods of storing character data.  You have the standard C style character arrays, and you have Arduino's own attempt at a C++ String class.  C style character arrays require a bit more effort on the programmers part while Arduino's String class attempts to provide an easier to use object that handles most of the string manipulation under the hood.  There is one potentially significant pitfall with the String class that you need to be aware of when using it.  The class relies on dynamically allocating buffers to handle different string sizes as well as changes in string sizes.  With the Arduino's limited SRAM, repeated dynamic memory allocation will fragment memory and eventually cause the Arduino to behave unpredictably or lock up completely.  It is for this reason that I utilize C style character arrays.  I'm not saying the String class can't be used, but steps need to be taken to keep it from fragmenting memory at which point you lose much of the advantage the class tries to provide.

Reading in Serial data
Now that we have our delimiters specified, let's have a brief overview of how we're going to read in our full data string.  We'll start this with an overview of the Serial class methods (methods are function associated with a class) we'll be using to read in the data string.

Serial.available():     This method returns the number of characters that are available in the Serial buffer at the moment it is called. 

Serial.read():      This method returns a single character from the Serial buffer, removing it from the buffer as well.  If there is no data available in the buffer, it returns -1.

And that's it.  These are the only two Serial methods we'll need to read in our data string.  So how do we read in that data string.  There are a couple hurdles we need to overcome to accomplish this.  

Recall at the beginning of this guide that the Arduino will run thousands of cycles in the time it takes to receive a single character.  That is our first hurdle.  Also recall that the goal of this guide is to provide a method that is robust, flexible, and efficient. This precludes any use of delay().  As a general rule, any Serial code that uses delay() is neither robust, flexible, or efficient.  Just don't do it.

So then, what is a robust, flexible, and efficient method of reading in Serial code? A method that regularly checks to see if serial data is available, reads the data that's available, and can reliably determine when it has a complete string of data to process.  So let's start turning that into code:

if(Serial.available()>0){
    char incomingbyte = Serial.read();
    buffer[index++] = incomingbyte;
}

The above code is by no means complete, but it's a start.  It checks to see if there are any characters available from the serial port, and if there is, it reads one in, and puts it in a char buffer.  It'll only read a single character though, even if there are more than one.  If this code is executed frequently though (and it would be if located inside the Arduino's loop() function, it will still read in serial data as it is available (keep in mind the Arduino will run thousands of cycles between each serial character).  Let's modify it slightly to read in all available characters anyways:

while(Serial.available()>0){
    char incomingbyte = Serial.read();
    buffer[index++] = incomingbyte;
}

The above code basically turns our previous code into:  While serial data is available, read it into our buffer.  However, we don't want to put just any data into our buffer.  We want to put a complete string of data into our buffer, and our strings all begin with a start/header character.  So we need to check our incoming data and only put it into our buffer when we see the start character.  Something like this:


char startChar = '$'; // or '!', or whatever your start character is
boolean storeString = false; //This will be our flag to put the data in our buffer
while(Serial.available()>0){
    char incomingbyte = Serial.read();
    if(incomingbyte==startChar){
        index = 0;  //Initialize our index variable
        storeString = true;
    }
    if(storeString){
        buffer[index++] = incomingbyte;
    }
}

This code utilizes a boolean variable as a flag to indicate what to do with incomingbyte.  The first thing we do with incomingbyte is check to see if it's our startChar.  If it is, we set storeString true and set our index to 0.  When storeString is true, we store incoming data into our buffer.  If it's false, we do nothing with the character.  Now we need to add code to determine when we've reached the end of our string, which requires looking for our terminating character.  It's at that point that we now have a complete data string and can then parse it and do whatever is necessary with the parsed data.


char startChar = '$'; // or '!', or whatever your start character is
char endChar = '\r';
boolean storeString = false; //This will be our flag to put the data in our buffer
while(Serial.available()>0){
    char incomingbyte = Serial.read();
    if(incomingbyte==startChar){
        index = 0;  //Initialize our index variable
        storeString = true;
    }
    if(storeString){
        if(incomingbyte==endChar){
            buffer[index] = 0; //null terminate the C string
            //Our data string is complete.  Parse it here
            storeString = false;
        }
        else{
            buffer[index++] = incomingbyte;
        }
    }
}

A second check has now been added for the endChar before storing it in our buffer.  When this second check is true, we now have a complete data string in our buffer.  This string can now be parsed to extract the specific pieces of data we want to use, but there are some additional improvements that we can make to our Serial code before we move on to parsing our data string.

Making our code more robust and flexible

One variable that hasn't been explicitly declared in our sample code so far is our buffer array.  This is an important detail that needs to be covered, but like our delimiter characters, there is no one single answer for all solutions.  Obviously our buffer size has to be large enough to contain our data string (plus one character for a null terminator).  So the thing that needs to be determined is how large can/will our data string be?  If we look back at our GPS data strings, we see a lot of variation (and a lot of repeat commas with no data).  Initially it may look as if determining our buffer size could be a bit of a challenge for these strings, but also recall that I mentioned these strings are compliant with an NMEA controlled specification.  As part of that spec, no NMEA compliant data string can be longer than 80 characters.  So this means our buffer does not need to be larger than 81 characters.

If we look at our Razor data strings, we see that the largest is 15 characters long.  It is important to look at the actual values though, and how large they can be.  In the case of the Razor, it is returning 3 angle values, each ranging from 0-360º.  So the maximum character length of each value is 3 characters.  Notice in our longest example one of the values is only two characters long.  So that means our maximum Razor string size is actually 16 characters, but we need to include our non-printable delimiter character as well, so our buffer size should be no smaller than 18 characters..

So let's add in our buffer declaration:

//buffer size for NMEA compliant GPS string
//For Razor, set value to 17 instead
#define DATABUFFERSIZE      80
char dataBuffer[DATABUFFERSIZE+1]; //Add 1 for NULL terminator
byte dataBufferIndex = 0;

Here we use a define to specify the size of our buffer, and then use that define to declare a buffer of the appropriate size.  You may also notice I've changed the name of the buffer.  Our previous examples were using a rather ambiguous name (though the new ones are only a bite less ambiguous).  I've also included the declaration of our index variable, but again with a more descriptive name.  The define serves two purposes here.  First, it'll improve the flexibility of our code.  We can easily modify the size of our data buffer from one location, and while at this moment it may seem that we can accomplish the same by modifying the size of the declared array directly, we will be adding more code that relies on the size of the buffer, and will utilize this define in other locations.  So, let us do that now...

When it comes to serial communications, it is not always safe to assume perfect communications.  In fact, it's rarely safe to do so.  Especially if you are dealing with some form of wireless intermediary.  So what does this mean for our Serial code?  What would end up happening if we happened to drop a block of data containing our terminating and start delimiters?  The code as it stands would just continue to read in the next data string, and continue to stash it in our buffer.  The problem is, our buffer is only large enough to store a single data string.  Without any code to protect against this scenario though, we will continue writing to memory beyond our buffer, and bad things are likely to happen once we start doing that.  So let's put a check in to make sure we never write outside our buffer.

while(Serial.available()>0){
    char incomingbyte = Serial.read();
    if(incomingbyte==startChar){
        dataBufferIndex = 0;  //Initialize our dataBufferIndex variable
        storeString = true;
    }
    if(storeString){
        //Let's check our index here, and abort if we're outside our buffer size
        //We use our define here so our buffer size can be easily modified
        if(dataBufferIndex==DATABUFFERSIZE){
            //Oops, our index is pointing to an array element outside our buffer.
            dataBufferIndex = 0;
            break;
        }
        if(incomingbyte==endChar){
            //Our data string is complete.  Parse it here
            storeString = false;
        }
        else{
            dataBuffer[dataBufferIndex++] = incomingbyte;
            dataBuffer[dataBufferIndex] = 0; //null terminate the C string
        }
    }
}

So now we compare our index value to our buffer size.  C style arrays are zero based arrays, meaning the first index in the array is index 0, which means the last index in the array is index (array size - 1).  Thus, if our index equals our array size, we've exceeded the boundary of our array.  When this happens, we reset our index, and break out of the while loop.  This means we are basically throwing away what we've already read in, but this data is now of unknown integrity.  The reality is this code should almost never be executed, but it's best to have it there to avoid a potential infrequent lockup problem in the future.  There are other options for handling a buffer overflow condition than this one, but this is simple and effective.

The next improvement we can make to this code is to wrap it up into a function call.  This will improve the flexibility and reuseability of the code.  To do this, we will have the function return a boolean value that indicates whether a complete string is ready to parse or not.

boolean getSerialString(){
    static byte dataBufferIndex = 0;
    while(Serial.available()>0){
        char incomingbyte = Serial.read();
        if(incomingbyte==startChar){
            dataBufferIndex = 0;  //Initialize our dataBufferIndex variable
            storeString = true;
        }
        if(storeString){
            //Let's check our index here, and abort if we're outside our buffer size
            //We use our define here so our buffer size can be easily modified
            if(dataBufferIndex==DATABUFFERSIZE){
                //Oops, our index is pointing to an array element outside our buffer.
                dataBufferIndex = 0;
                break;
            }
            if(incomingbyte==endChar){
                dataBuffer[dataBufferIndex] = 0; //null terminate the C string
                //Our data string is complete.  return true
                return true;
            }
            else{
                dataBuffer[dataBufferIndex++] = incomingbyte;
                dataBuffer[dataBufferIndex] = 0; //null terminate the C string
            }
        }
        else{
        }
    }
   
    //We've read in all the available Serial data, and don't have a valid string yet, so return false
    return false;
}

No significant modifications here.  Just put the code into a function called getSerialString(), that returns a boolean value.  Since dataBufferIndex and storeString are only used by our Serial read code in this function, I've also moved their declarations into the function.  Declaring them static means the values will be retained between separate calls to getSerialString().  We have only two points that we return from, one returning true (string is available), and the other returning false (a complete string is not available yet).  The usage of this function is simple:

if(getSerialString()){
    //String available for parsing.  Parse it here
}

That code would go someplace where it gets called at regular intervals, for example right at the start of your loop().  And there you have your serial input routine.  All you need to do is specify a start and terminating delimiter, and the maximum data string size to read in virtually any ASCII based data strings.
Posted by JHaskell at 8:53 AM 
Email This
BlogThis!
Share to Twitter
Share to Facebook
Share to Pinterest

12 comments:

JoshMay 12, 2011 at 3:27 PM
for the last section of code (the one wrapped in a function. you need to add 2 lines
{
storeString = false;
dataBufferIndex=0;
}
after/before "//Our data string is complete. return true" that was hard to find. but excellent over all. thank you so much

Reply

JHaskellMay 12, 2011 at 4:03 PM
Good catch. I've updated the code accordingly.

Reply

samJune 24, 2011 at 7:13 PM
hi

this tutorial is very helpful. thank you so much for it. i am working on a similar project. and this will be definitely helpful. 

i have some questions:

for example, in the Razor IMU data stream that looks like this: 

!ANG:320,33,191

from your tutorial, i understand now how to look for the start char which is (!) in this case. now if i wanted to go further, the net char to check would be the colon (:) after the the letter (G).

my question is how to continue the check after this stage, i.e., treating the colon (:) as the start char for the next part of the data stream, and check or the end char, which is the comma (,) in this case.

form my understanding of the posted code, and this is coming from a newbie, it only checks for one start char and one end char and then parse the stuff in between.

i want to to learn how to do multiple checks in the same one-line data stream.

any input or guidance to the right direction would be much appreciated.

thanks

Reply

JHaskellJune 30, 2011 at 9:30 AM
I just added a short guide to parsing using strtok(). The Serial comm guide did not cover parsing of data.

Reply

zoroastreJuly 17, 2011 at 6:13 AM
Thanks for the code ;)

But i have a problem with it, as sometimes the previous message is longer than the new one, so data are stacked.

I'am looking for a cue, i'm a c++ newbie.

@

Zoroastre.

Reply

WesAugust 11, 2011 at 11:53 AM
This code has been a huge help on my project. 

I have tailored the code to suit the project i am working on...but it is essentially the same. My start character is '<' and my end character is '>'. When it prints the output it will leave off the '>' (that what the null terminate is for i assume?) but i cant seem to get rid of the start character '<'. i have tried setting the first occurrence of it to '0', but i guess i am not doing it correctly because its still there. 

can you point me in the right direction? 

thanks.

Reply

JHaskellAugust 11, 2011 at 12:58 PM
If you don't want to store the start character in your data string, move the check for the start character to after the storestring check, something like this:

if(storestring){
//code in storestring block
}
else{
}
if(incomingbyte == startChar){
//code
}

Reply

WesAugust 11, 2011 at 2:33 PM
Doesn't the storestring check depend on the start character check? 

if(incomingbyte==startChar){
dataBufferIndex = 0; 
storeString = true;
}

Reply

JHaskellAugust 11, 2011 at 2:39 PM
Yup, but keep in mind both these checks are occurring in a loop over and over and over. By changing the order of the checks, the only effective change that occurs is that the startchar will not get stored in our buffer, since you are now checking to see if you need to store the character before you check if the character is our start character. storestring will still be true for the next character you read in, which is the one you want to start with.

Reply

WesAugust 11, 2011 at 2:55 PM
Awesome, switching the statements worked perfectly. It also made me learn to look at loops a bit differently. Thanks so much for you help!

Reply

Darren PruittAugust 15, 2013 at 2:09 PM
Thank you for the post. This is how your code is used:

http://techshorts.ddpruitt.net/2013/08/remote-controlled-robotank/

Reply

Adam KellersonMarch 1, 2014 at 8:10 PM
I wish I found this post weeks ago. This is the clearest example, at least to me, of dealing with serial input data I've found. Thanks a lot.

Reply

Newer Post Home
Subscribe to: Post Comments (Atom)
Followers

Blog Archive
▼  2011 (3)
►  November (1)
►  June (1)
▼  May (1)
Serial Comm Fundamentals on Arduino
About Me
JHaskell
View my complete profile
Awesome Inc. template. Powered by Blogger.
*/
