`include "UART_Receiver.v"

module TB_Receiver();
  reg clk, RX_start, in, RST, enable;
  wire RX_done, RX_busy, error;
  wire [7:0]out;
  
  UART_Receiver Receiver(.clk(clk), .RX_start(RX_start), .in(in), .out(out), .RX_busy(RX_busy), .error(error), .RX_done(RX_done), .enable(enable), .RST(RST));
  
  always #1 clk = ~clk;
  
  initial begin
    clk <= 0; RX_start <= 1; in <= 0; RST <= 1; enable <= 1;
    #3 in = 0;  
    #2 RX_start = 1;
    #32 in = 1;
    #32 in = 1;
    #32 in = 1;
    #32 in = 1; 
    #32 in = 1;
    #32 in = 0;
    #32 in = 1;
    #32 in = 1;
    #32 in = 1;   // Parity bit (no parity error)
    #32 in = 0;   //stop bit
  end
endmodule