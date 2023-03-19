module UART_Receiver #(parameter CLKS_PER_BIT = 2604)
(
  
    input  wire       clk,           // baud rate
    input  wire       enable,
    input  wire       in,            // rx
    input  wire       RX_start,
    input  wire       RST,    
    output reg  [7:0] out,           // received data
    output reg        RX_done,       // end on transaction
    output reg        RX_busy,       // transaction is in process
    output reg        error          // error while receiving data
);

  // Clock frequency in hertz.
  
  parameter CLK_HZ = 25_000_000;
  parameter BIT_RATE =  9600;


    // states of state machine
    parameter RESET = 0;
    parameter IDLE = 1;
    parameter DATA = 2;
    parameter STOP = 3;


    reg [2:0] state = IDLE;           // State register is used to update the current state value with the default being IDLE
    reg [2:0] bitIndex = 3'b0;        // for 8-bit data
    reg [1:0] inShReg = 2'b0;         // shift reg for input signal state
    reg [3:0] clkCount = 4'b0;        // count clocks for 16x oversample
    reg [7:0] receivedData = 8'b0;    // temporary storage for input data

    initial begin
        out <= 8'b0;
        error <= 1'b0;
        RX_done <= 1'b0;
        RX_busy <= 1'b0;
    end

    always @(posedge clk or negedge RST) begin       //At every tick of the system clock 
      if(!RST) begin
        state <= RESET;
      end
      else begin
        inShReg = {inShReg[0], in};
        if (!enable) begin
          state = RESET;
        end

//////////////////////////////// The RESET Case ////////////////////////////////

        case (state)
            RESET: begin
                out <= 8'b0;
                error <= 1'b0;
                RX_done <= 1'b0;
                RX_busy <= 1'b0;
                bitIndex <= 3'b0;
                clkCount <= 4'b0;
                receivedData <= 8'b0;
                if (enable) begin
                    state <= IDLE;
                end
            end
            
//////////////////////////////// The IDLE Case ////////////////////////////////

            IDLE: begin
                RX_done <= 1'b0;
                if (&clkCount) begin
                    state <= DATA;
                    out <= 8'b0;
                    bitIndex <= 3'b0;
                    clkCount <= 4'b0;
                    receivedData <= 8'b0;
                    RX_busy <= 1'b1;
                    error <= 1'b0;
                end 
                else if (!(&inShReg) || |clkCount) begin
                    if (&inShReg) begin             // Check bit to make sure it's still low
                        error <= 1'b1;
                        state <= RESET;
                    end
                    clkCount <= clkCount + 4'b1;    // Wait 8 full cycles to receive serial data
                end
            end

//////////////////////////////// The DATA Case ////////////////////////////////

            DATA: begin
                if (&clkCount) begin // save one bit of received data
                    clkCount <= 4'b0;
                    receivedData[bitIndex] <= inShReg[0];
                    if (&bitIndex) begin
                        bitIndex <= 3'b0;
                        state <= STOP;
                    end 
                    else begin
                        bitIndex <= bitIndex + 3'b1;
                    end
                end 
                else begin
                    clkCount <= clkCount + 4'b1;
                end
            end

//////////////////////////////// The STOP Case ////////////////////////////////

            // Baud clock may not be running at exactly the same rate as the transmitter. 
            // Next start bit is allowed on at least half of stop bit.
            STOP: begin
                if (&clkCount || (clkCount >= 4'h8 && !(|inShReg))) begin
                    state <= IDLE;
                    RX_done <= 1'b1;
                    RX_busy <= 1'b0;
                    out <= receivedData;
                    clkCount <= 4'b0;
                end
                else begin
                    clkCount <= clkCount + 1;
                    if (!(|inShReg)) begin    // Check bit to make sure it's still high
                        error <= 1'b1;
                        state <= RESET;
                    end
                end
            end
            
            default:
             state <= IDLE;
        endcase
        
      end
    end
endmodule