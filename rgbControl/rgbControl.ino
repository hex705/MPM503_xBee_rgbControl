
  #include <Scissors.h>  
  Scissors incomingMessage;   // SCISSORS parse messages
  
  int redPin   = 6;   // was 6
  int greenPin = 5;   // was 5
  int bluePin  = 3;   // was 3
  

  void setup() {
    
    incomingMessage.begin(19200);
    
  
      pinMode(redPin,OUTPUT);  
      pinMode(greenPin,OUTPUT);
      pinMode(bluePin,OUTPUT);
    
    
        // this call starts the serial port at BAUD 19200 and attaches SCISSORS to the incoming serial data
                                                                     
  }
  
  
  void loop(){
    
   
        if (incomingMessage.update() > 0) {         // poll the SCISSOR object -- any new MESSAGES (returns element count)
           
            int r = incomingMessage.getInt(1);       // get ELEMENT 2 from MESSAGE -- assuming ELEMENT(2) is a  float
            int g = incomingMessage.getInt(2);       // get ELEMENT 0 from MESSAGE -- assuming ELEMENT(0) is a  String
            int b = incomingMessage.getInt(3);       // get ELEMENT 1 from MESSAGE -- assuming ELEMENT(1) is an int  
         
           if ( r <= 5 )  r = 0;
           if ( g <= 5 )  g = 0;
           if ( b <= 5 )  b = 0;
           
            analogWrite ( redPin  , r);
            analogWrite ( greenPin, g);
            analogWrite ( bluePin , b);
            
         
        }
         
         
          
  }

