/*
  XBee terminal
  Language: processing

  This program is a basic serial terminal program.  
  It replaces newline characters from the keyboard 
  with return characters.  It's designed for use with 
  Linux, Unix, and OS X and XBee radios, because the 
  XBees don't send newline characters back.
*/
import processing.serial.*;

Serial myPort;           // the serial port you're using
String portnum;          // name of the serial port
String outString = "";   // the string being sent out the serial port
String inString = "";    // the string coming in from the serial port
int receivedLines = 0;   // how many lines have been received 
int bufferedLines = 10;  // number of incoming lines to keep

void setup() {
  size(400, 300);        // window size

  // create a font with the second font available to the system:
  PFont myFont = createFont(PFont.list()[2], 14); //<-- not this one
  textFont(myFont);

  // list all the serial ports:
  println(Serial.list());

  // based on the list of serial ports printed from the 
  //previous command, change the 0 to your port's number:
  portnum = Serial.list()[99];
  // initialize the serial port:
  myPort = new Serial(this, portnum, 19200);

}

void draw() {
  // clear the screen:
  background(0); 
  // print the name of the serial port:
  text("Serial port: " + portnum, 10, 20);
  // Print out what you get:
  text("typed: " + outString, 10, 40);
  text("received:\n" + inString, 10, 80);
}

// This method responds to key presses when the 
// program window is active:
void keyPressed() {
  switch (key) {
    // in OSX, if the user types return, 
    // a linefeed is returned.  But to 
    // communicate with the XBee, you want a carriage return:

  case '\n':        
    myPort.write(outString + "\r");
    outString = "";
    break;
  case 8:    // backspace
    // delete the last character in the string:
    outString = outString.substring(0, outString.length() -1);
    break;
  case '+':  // we have to send the + signs even without a return:
    myPort.write(key);
    // add the key to the end of the string:
    outString += key;
    break; 
  case 65535:  // If the user types the shift key, don't type anything:
    break;
    // any other key typed, add it to outString:
  default: 
    // add the key to the end of the string:
    outString += key;
    break;
  }
}

// this method runs when bytes show up in the serial port:
void serialEvent(Serial myPort) {
  // read the next byte from the serial port:
  int inByte = myPort.read();
  // add it to  inString:
  inString += char(inByte);
  if (inByte == '\r') {
    // if the byte is a carriage return, print 
    // a newline and carriage return:
    inString += '\n';
    // count the number of newlines:
    receivedLines++;
    // if there are more than 10 lines, delete the first one:
    if (receivedLines >  bufferedLines) {
      deleteFirstLine();
    }
  }
} 
// deletes the top line of inString so that it all fits on the screen:
void deleteFirstLine() { 
  // find the first newline:
  int firstChar = inString.indexOf('\n');
  // delete it:
  inString= inString.substring(firstChar+1);
}
