/*
 * 
 * teleClient_n
 * 
 * simple teleClient -- connects to teleServer to obtain sensor data passes it to ARDUINO
 *
 * all messages are parsed and assembled with SCISSORS and GLUE
 *
 * based on server example in Shiffman -- learning processing
 *
 * 
 */


import processing.net.* ;        // import the net library

Client teleClient ;              // declare a CLIENT object
String serverIP = "127.0.0.1";   // set to MATCH the IP of the SERVER (where is the server?)
int    serverPORT = 12345;       // set to MATCH the PORT on which the SERVER is listening?

Scissors parseMessagesFromServer;  // create a SCISSORS object to parse INCOMING messages from SERVER



import processing.serial.*;   // import the serial library
Serial clientSerialPort;      // setup a Serial PORT

Glue messageToArduino = new Glue();  // create a GLUE OBJECT to to help assemble OUTGOING SERIAL messages



int greyValueFromServer ;   // variable to store the value originating in the arduino and coming from the SERVER
PFont f;

void setup(){
  
  size( 700,700 );
  background(67);
  
  // start client to get messages
  teleClient = new Client( this, serverIP, serverPORT );     // connect client to SERVER IP and SERVER PORT
  parseMessagesFromServer = new Scissors( teleClient );      // attach parser (SCISSORS) to the CLIENT
  
  // start the serial port
  println(Serial.list());  // List all the available serial ports

  // connect this sketch to the USB port of your Arduino at specified BAUD
  clientSerialPort = new Serial(this, Serial.list()[99], 19200);  // match baud and PORT 
  
  f = createFont( "Arial",  18,  true );
  textFont (f, 18);
 
}

void draw(){
 
    if (  parseMessagesFromServer.update() > 0 ) {   //  polls CLIENT and returns number of ELEMENTS in MESSAGEs
        
        background(67);
        
        greyValueFromServer = parseMessagesFromServer.getInt(1);  // extract ELEMENT one (1) from the MESSAGE -- it is an INT
        
        // draw and fill rectangle with data from server
        fill(greyValueFromServer);  
        rect(width/2-300,height/2-300,600,600);
        
        // put text at bottom
        fill(255);
        textAlign(RIGHT);
        text( greyValueFromServer, 650 , 670 );
        
        // use GLUE to build a new message to be passed to local Arduino
         messageToArduino.clear();                         // start fresh :: clear the last OUTGOING message
         messageToArduino.add( "teleClient" );             // add a prefix to our message -- BE POLITE -- tell recipient who is talking
         
         
         messageToArduino.add(  greyValueFromServer );       // add the VALUE from the SERVER to our OUTGOING message
      
     
         String messageToSend = messageToArduino.getPackage();     // put the WHOLE message in a STRING
           //messageToArduino.debug();                             // debug message to screen ( un/comment )
         clientSerialPort.write( messageToSend );                  // use SERIAL method .write() to send a message to local ARDUINO
        
    }
    
  // YOUR CODE HERE
  
} // end draw





class Glue {
  
  // default package variables
  char START_BYTE  =  '*' ;   //  42 = * 
  char DELIMITER   =  ',' ;   //  44 = ,  
  char END_BYTE    =  '#' ;   //  35 = # 
  char WHITE_SPACE =  ' ' ;   //  32 = ' ' 
  
  String serverID;
  
  String gluePackage;
  

  Glue () {
    // probbly need to do something here 
    clear();
    
  } 
 
  

  // clear the current message
  void clear( ) {
    gluePackage = "";
    gluePackage += START_BYTE ;
  }
  
   // function to send messages over the server
  void add( int i ) {
    gluePackage += i;
    gluePackage += DELIMITER;
  }
  
  void add( float f ) {
     gluePackage += f ;
     gluePackage += DELIMITER ;
    
  }
  
  void add ( String stringToAdd ) {
   gluePackage += stringToAdd ;
   gluePackage += DELIMITER ;
   
  } 
    
  String getPackage() {
    gluePackage += END_BYTE ;
    return gluePackage;
  } 
  
  String debug() {
    println( "Glue debug: " + gluePackage);
    return gluePackage;
  } 
  
  
  // getters and setters
  void setStartByte(char s) {
    START_BYTE = s;
  }
   void setEndByte(char e) {
     END_BYTE = e;
  }
  
   void setDelimiter(char d) {
     DELIMITER = d;
  }
 
  
  char getStartByte() {
      return START_BYTE;
  }
  
  char getEndByte() {
     return END_BYTE;
  }
  
  char getDelimiter() {
     return DELIMITER;
  }
  
  String getID () {
    return serverID;
  }
 
  
  
  
} // end class 


import processing.net.* ;
import processing.serial.*;

class Scissors {
  
 // package variables
  char START_BYTE  =  '*' ;   //  42 = * 
  char DELIMITER   =  ',' ;   //  44 = ,  
  char END_BYTE    =  '#';   //  35 = # 
  char WHITE_SPACE =  ' ';   //  32 = ' ' 
  
  String TOKENS = new String( "" + START_BYTE + DELIMITER + END_BYTE);  // MAKE A STRING OF TOKENS
  
  String incomingData;
  String[] parsedData;
  
  int TYPE = -1;

  Server server;
  Client c;
  Serial s;

  
  boolean DEBUG = false;
  
  // some error protection
  // sometimes incomplete MESSAGES arrive -- and text tries to become a number
  int   oldInt;
  float oldFloat;

  Scissors (Client _c ) {
       TYPE = 1; 
       c= _c;
    
  }
  
  Scissors (Serial _s) {
      TYPE = 2;
      s = _s;
  }

	Scissors (Server _server) {
      TYPE = 3;
      server = _server;
  }
  
  int update(){
	
		if (TYPE == 3 ) {
			// see if any clients have spoken to the server.
			  Client serverClient = server.available();

		      if (serverClient != null ) {
			
				incomingData = serverClient.readStringUntil( END_BYTE );
				
				if (DEBUG) {
					println("SERVER INCOMING data stream (raw)  " +incomingData);
				}
				
			    serverClient.clear();
		         
		      }  // if serverClient
		
		      
		
	    } // end type = 3
          
       
          if (TYPE == 1 ) {
              incomingData = c.readStringUntil( END_BYTE );
              if (DEBUG) {
              println("CLIENT INCOMING data stream (raw)  " +incomingData);
              }
          }  /// end type =2 
          
          
          if (TYPE == 2 ) {
              incomingData = s.readStringUntil( END_BYTE );
              if (DEBUG) {
              println("SERIAL data stream (raw)  " +incomingData);
              }
              
          }
        
        
          if( incomingData != null ){   // make sure you have something
          
            int startPos = incomingData.indexOf( START_BYTE );
            int endPos   = incomingData.indexOf( END_BYTE )  ;
            if (DEBUG) {
            println( "start " + startPos + " end " + endPos);
            }
            
                if ( ( startPos >= 0 ) && ( endPos > startPos ) ){ // make sure the something has a start and end
                 
                    incomingData = incomingData.substring(startPos,endPos);
                    parsedData = splitTokens( incomingData, TOKENS  ); 
                } 
                else {
                    if (DEBUG) {
                      println("incomplete message");
                    }
                     return -1;
                }
              
          } // end IF
          else {
            if(DEBUG) {
            println("Stream Error");
            }
            return -1;
          }
      
      
     if (TYPE == 1)  c.clear();
     if (TYPE == 2)  s.clear();
    
     
     return parsedData.length;
      
   }  // end read net packet
 
 
  String getString(int position) {
    return parsedData[position];
  } 
  
  float getFloat(int position) {
    
    float newFloat;
      try {
        newFloat = Integer.parseInt( parsedData[position] );
      }
      catch (NumberFormatException e) {
        println("err --> expected FLOAT got :: " +  parsedData[position]);
        newFloat= oldFloat;
      }
    oldFloat = newFloat;
    
    return newFloat;
  } 
  
  int getInt(int position) {
    
    int newInt;
      try {
        newInt = Integer.parseInt( parsedData[position] );
      }
      catch (NumberFormatException e) {
        println("err --> expected INT got :: " +  parsedData[position]);
        newInt = oldInt;
      }
    oldInt = newInt;
    
    return newInt;
  } 
 
  // getters and setters
  void setStartByte(char s) {
    START_BYTE = s;
  }
   void setEndByte(char e) {
     END_BYTE = e;
  }
   void setDelimiter(char d) {
     DELIMITER = d;
  }
 
 
  char getStartByte() {
      return START_BYTE;
  }
  
  char getEndByte() {
     return END_BYTE;
  }
  
  char getDelimiter() {
     return DELIMITER;
  }

  String getRaw() {
	      
	      return incomingData;
  }
  
  
} // end class

