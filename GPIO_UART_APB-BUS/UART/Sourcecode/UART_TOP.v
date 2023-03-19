module UART_TOP(
  input rxd,
  input PCLK,
  input PRESET,   
  input PSEL,
  input PENABLE,
  input PWRITE,        //if PWRITE == 1 --> allow writing (Transmitting) else if PWRITE == 0 --> allow reading (Receiving)
  input [7:0] PADDR,
  input [7:0] PWDATA, 
  output wire PREADY,
  output wire [7:0] PRDATA,
  output wire txd
);

// Clock frequency in hertz.
parameter CLK_HZ = 50_000_000;
parameter BIT_RATE =  9600;


//----------------------- Internal Connections -----------------------//

wire uart_tx_enable;

wire uart_tx_start;

wire uart_rx_start;

wire uart_rx_enable;

wire uart_TX;

wire uart_RX;

//---------------------------------------------------------------------------//

assign PREADY = (PENABLE)?((PSEL)? 1'b1: 1'b0):
                              ((PSEL)? 1'b0: 1'b0);

assign uart_tx_enable = (PENABLE)?((PWRITE)? 1'b1: 1'b0):
                                  ((PWRITE)? 1'b0: 1'b0);

assign uart_rx_enable = (PENABLE)?((!PWRITE)? 1'b1: 1'b0):
                                  ((!PWRITE)? 1'b0: 1'b0);

assign uart_tx_start = uart_tx_enable;

assign uart_rx_start = uart_rx_enable;

assign uart_TX = txd;

assign uart_RX = rxd;

//--------------------------------- Modules Instantiation ------------------------------------// 


//UART Reciever module.

UART_Receiver i_uart_rx(
.clk      (PCLK),
.RST      (PRESET),
.in       (uart_RX),
.enable   (uart_rx_enable),
.RX_start (uart_rx_start),
.out      (PRDATA) 
);


// UART Transmitter module.

UART_Transmitter i_uart_tx(
.clk      (PCLK),
.RST      (PRESET),
.TX       (uart_TX),
.enable   (uart_tx_enable),
.TX_start (uart_tx_start),
.data_byte (PWDATA) 
);

endmodule