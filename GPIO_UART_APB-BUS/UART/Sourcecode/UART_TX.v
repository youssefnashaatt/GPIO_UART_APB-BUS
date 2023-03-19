module UART_Transmitter #(parameter CLKS_PER_BIT = 2604)
  (
    input [7:0] data_byte,          //data_byte register is used to take the data bits from the Data register parallelly
    input TX_start,                 //The TX_start flag is used to exit the IDLE state and start sending the data 
    input clk,
    input enable,
    input RST,                      //The reset signal
    output reg TX_busy,            //
    output reg TX,                  //The TX line to send data through it serially
    output reg TX_done              //The TX_done flag is used to indicate that all data has been sent
  );           
  
  parameter CLK_HZ = 25_000_000;
  parameter BIT_RATE =  9600;
  
  parameter integer CYCLES_WAIT = 15;

  parameter RESET = 0;
  parameter IDLE = 1;
  parameter START = 2;
  parameter DATA = 3;
  parameter STOP = 4;
        
  reg [2:0] State = 0;        //State register is used to update the current state value with the default being RESET
  reg [15:0] Counter = 0;     //Counter register is used to count the number of cycles of the clock to wait till doing something [0 --> 15] (16 ticks)
  reg [3:0] bitsNum = 0;      //a register to count the number of bits transmitted [0 --> 7] (8 bits)
  reg [7:0] Data;             //Data register is used to save the data byte we want to send inside it
      
        
  always @(posedge clk or negedge RST) begin       //At every tick of the system clock or when reset is LOW
    
    if(!RST)    //If Reset signal is LOW go to RESET State
      begin
        State <= RESET;
      end
    
    else begin    //If Reset signal is HIGH, Proceed normally
        
    if (!enable) begin    //Check the enable signal
      State = RESET;      //If LOW go to RESET
    end
   
    case(State)

//////////////////////////////// The RESET Case ////////////////////////////////

      RESET: begin
        TX_done <= 0;
        TX_busy <= 0;
        Counter <= 0;
        bitsNum <= 0;
        Data <= 0;
        if (enable) begin   //If HIGH go to IDLE
          State <= IDLE;
         end
      end

//////////////////////////////// The IDLE Case ////////////////////////////////
          
      IDLE : begin
            
        TX <= 1;           //Drive the TX line HIGH while in IDLE
        TX_done <= 0;      //Return the TX_done flag to zero
        Data <= 0;
        Counter <= 0;      //Set the cycles counter to zero
        bitsNum <= 0;      //Set the bits counter to zero
            
        if(TX_start)    //Wait till the (TX_start) flag is HIGH then load the data parallelly from the system (data_byte) into UART datat register (Data) then switch to the START state
          begin
            Data <= data_byte;
            TX_busy <= 1;
            State <= START;
          end
              
        else    //If TX_start is not HIGH stay in the IDLE state
          State = IDLE;     
      end
          
//////////////////////////////// The START Case ////////////////////////////////          

      START : begin
        
        TX <= 0;    //Drive the TX line LOW (start bit = 0)
        
        //Wait 16 cycles for the Start bit to finish
        if(Counter == CYCLES_WAIT)   //If the Counter's final value is reached
          begin
            Counter <= 0;       //Set the cycles counter to zero
            bitsNum <= 0;       //Set the bits counter to zero
            State <= DATA;  //Switch to the DATA state
          end
          
        else      //If not reached then increase the Counter by one and stay in the START state
          begin
            Counter <= Counter + 1;
            State <= START;
          end
      end

//////////////////////////////// The DATA Case ////////////////////////////////

      DATA : begin
        
        TX <= Data[bitsNum];    //Send the data bit by bit on the TX line
        
        //Wait 16 cycles for the Data bits to finish
        if(Counter == CYCLES_WAIT)   //If the Counter's final value is reached
          begin
            Counter <= 0;   //Set the Counter to zero
            
            if(bitsNum == 7)     //If all eight bits are transmitted switch to the STOP state
              begin
                bitsNum <= 0;
                State <= STOP;
              end
              
            else
              begin             //If not then increase the counter by one and stay in the DATA state
                bitsNum <= bitsNum + 1;
                State <= DATA;
              end
          end
          
        else      //If the Counter's final value is not reached, increase it by one and stay in the DATA state
          begin
            Counter <= Counter + 1;
            State <= DATA;
          end
      end
 
//////////////////////////////// The STOP Case ////////////////////////////////  
         
      STOP : begin
        
        TX <= 1;     //Drive the TX line HIGH (stop bit = 1)
        
        //Wait 16 cycles the Stop bit to finish
        if(Counter == CYCLES_WAIT)   //If the counter's final value is reached
          begin
            TX_done <= 1;     //Set the (TX_done) flag HIGH
            Counter <= 0;     //Set the Counter to zero
            Data <= 0;
            TX_busy <= 0;
            State <= IDLE;    //Switch to the IDLE state
          end
          
        else    //If the Counter's final value is not reached, increase it by one and stay in the STOP state
          begin
            Counter <= Counter + 1;
            State <= STOP;
          end
      end
      
//////////////////////////////// The Default Case ////////////////////////////////  
      
      default :
        State <= RESET;     
    
    endcase
  end       //end of else: !if(!RST)
  end     //end of alwyas block
endmodule