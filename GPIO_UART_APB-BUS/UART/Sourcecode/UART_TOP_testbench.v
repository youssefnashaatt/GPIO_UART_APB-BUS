`include "UART_TOP.v" 

module UART_TOP_testbench();
  
  reg rxd;
  reg PCLK;
  reg PRESET;
  reg PSEL;
  reg PENABLE;
  reg PWRITE;
  reg [7:0] PWDATA;
    
  wire txd;
  wire PREADY;
  wire [7:0] PRDATA;
  
  
  reg [7:0] uart_tx_data;
  
  
  
  //Frequency of the system clock.
localparam CLK_HZ   = 150_000_000;

parameter CLKS_PER_BIT = 2604;


  
//--------------------------- Clock Generator ---------------------------//

parameter CLK_PERIOD = 1000_000_000 / CLK_HZ;

initial begin
    PCLK = 0;
  end

always #(CLK_PERIOD / 2) begin
    PCLK = ~PCLK;
  end
//-----------------------------------------------------------------------//

             
//-------------------- Testing --------------------//

// Sends a single byte down the UART line.
task send_byte;
    input [7:0] to_send;
    begin
        $display("Send data %b at time %d", to_send,$time);
        uart_tx_data = to_send;
    end
endtask


reg [7:0] to_send;
initial begin
  PCLK <= 0;
  PRESET <= 1;
  PSEL <= 0;
  #2 PSEL <= 1;
  PENABLE <= 0;
  #3 PENABLE <= 1;
  PWRITE <= 1;
  PWDATA <= 8'b10011101; 
  #100 PWRITE <= 0;
  #32 rxd = 0; 
  #32 rxd = 1;
  #32 rxd = 1;
  #32 rxd = 1;
  #32 rxd = 1; 
  #32 rxd = 1;
  #32 rxd = 0;
  #32 rxd = 1;
  #32 rxd = 1;
  #32 rxd = 1;   // Parity bit (no parity error)
  #32 rxd = 0;   //stop bit
  #10;
  to_send = PWDATA;
  send_byte(to_send);
  
  
end



//----------------- Instance of the Design Under Test -----------------//
UART_TOP DUT(.rxd(rxd),.PCLK(PCLK), .PRESET(PRESET), .PSEL(PSEL), .PENABLE(PENABLE),
             .PWRITE(PWRITE), .PWDATA(PWDATA), .PREADY(PREADY), .PRDATA(PRDATA), .txd(txd));

endmodule