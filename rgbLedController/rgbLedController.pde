/*
 * 
 
 * all messages are parsed and assembled with SCISSORS and GLUE
 *
 * based on server example in Shiffman -- learning processing
 *
 * 
 */


import processing.serial.*;   // import the serial library
Serial serialPort;      // setup a Serial PORT


Glue messageToArduino = new Glue();  // create a GLUE OBJECT to to help assemble OUTGOING SERIAL messages

Slider r, gr, b;
int newRed, newGreen, newBlue;
int oldRed, oldGreen, oldBlue; 

PFont f;

void setup() {

  size( 700, 250 );
  background(67);


  // start the serial port
  println(Serial.list());  // List all the available serial ports

  // connect this sketch to the USB port of your Arduino at specified BAUD
  serialPort = new Serial(this, Serial.list()[6], 19200);  // match baud and PORT 

  // define the slider for interface
  r =  new Slider(width - 360, 20, 100, 200, 0, 255, color(255, 0, 0), false);
  gr = new Slider(width - 240, 20, 100, 200, 0, 255, color(0, 255, 0), false);
  b =  new Slider(width - 120, 20, 100, 200, 0, 255, color(0, 0, 255), false);


  f = createFont( "Arial", 18, true );
  textFont (f, 18);
}

void draw() {

  // get new fill color
  newRed   = r.update();
  newGreen = gr.update();
  newBlue  = b.update();

  // check to see if ANY of the sliders changed
  if (  newRed != oldRed  ||  newGreen != oldGreen  ||  newBlue != oldBlue  ) {

    // something changed so need to update the LEDs

    // display the slider state -- mixed.
    fill(newRed, newGreen, newBlue);
    rect ( 20, 20, 275, 200, 5, 5, 5, 5);

    // use GLUE to build a new message to be passed to local Arduino
    messageToArduino.clear();                         // start fresh :: clear the last OUTGOING message
    messageToArduino.add( "rgb" );             // add a prefix to our message -- BE POLITE -- tell recipient who is talking

    messageToArduino.add(  newRed    );       // add the VALUE from the SERVER to our OUTGOING message
    messageToArduino.add(  newGreen  );   
    messageToArduino.add(  newBlue   );   

    String messageToSend = messageToArduino.getPackage();     // put the WHOLE message in a STRING
    messageToArduino.debug();
    // debug message to screen ( un/comment )
    serialPort.write( messageToSend );                  // use SERIAL method .write() to send a message to local ARDUINO
  } // end if change


  oldRed = newRed;
  oldGreen = newGreen;
  oldBlue = newBlue;
} // end draw

