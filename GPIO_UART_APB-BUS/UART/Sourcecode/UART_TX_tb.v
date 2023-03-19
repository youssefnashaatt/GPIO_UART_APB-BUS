`timescale 1ns/1ns
`define WAVES_FILE "D:/T/Verilog Codes/work/waves-tx.vcd"
 
`include "UART_TX.v"
 
module UART_TX_tb();
  
//----------------- Ports -----------------// 

reg        clk            ;    // Top level system clock input.
reg        resetn         ;    // Reset signal
reg        uart_tx_start  ;    // TX_start Flag

wire       uart_txd       ;    // UART transmit pin.
wire       uart_tx_busy   ;    // Module busy sending previous item.
wire       uart_tx_done   ;    // Module done sednig the item

reg        uart_tx_en     ;    // Enable signal
reg  [7:0] uart_tx_data   ;    // The recieved data from the system.


//Frequency of the system clock.
localparam CLK_HZ   = 150_000_000;

parameter CLKS_PER_BIT = 2604;



//--------------------------- Clock Generator ---------------------------//

parameter CLK_PERIOD = 1000_000_000 / CLK_HZ;

initial begin
    clk = 0;
  end

always #(CLK_PERIOD / 2) begin
    clk = ~clk;
  end
//-----------------------------------------------------------------------//


//
// Sends a single byte down the UART line.
task send_byte;
    input [7:0] to_send;
    begin
        $display("Send data %b at time %d", to_send,$time);
        uart_tx_data = to_send;
        uart_tx_start = 1;
    end
endtask


//
// Run the test sequence.
reg [7:0] to_send;
initial begin
    resetn  = 0;
    #40 resetn = 1;
    uart_tx_en = 0;
    #10 uart_tx_en = 1;
    
    $dumpfile(`WAVES_FILE);
    $dumpvars(0,UART_TX_tb);
    to_send = $random;
    send_byte(to_send);
    uart_tx_start = 0;
    #500;
    to_send = $random;
    send_byte(to_send);
    #500;
    to_send = $random;
    send_byte(to_send);
end


//------------------ Instance of the DUT ------------------//
UART_Transmitter #(.CLKS_PER_BIT(CLKS_PER_BIT)) i_uart_tx
(
  .clk        (clk),
  .RST        (resetn),
  .TX_start   (uart_tx_start),
  .TX         (uart_txd),
  .enable     (uart_tx_en),
  .TX_busy    (uart_tx_busy),
  .data_byte  (uart_tx_data),
  .TX_done    (uart_tx_done) 
);

endmodule