`include "gpio_main.v"

module testing;
  reg PRESETn;
  reg PCLK;
  reg PSEL;
  reg PENABLE;
  reg [7:0] PADDR;
  reg PWRITE;
  reg [7:0] PWDATA;
  wire [7:0] PRDATA;
  wire PREADY;
  wire [7:0] pins;

  localparam DATA = 1'b0,
            DIRECTION = 1'b1;
  
// instance 
gpio test(
  PCLK,
  PRESETn,
  PSEL,
  PENABLE,
  PWRITE,
  PADDR,
  PWDATA,
  PRDATA,
  PREADY,
  pins
);


initial
  begin
    PCLK <= 0;
    forever #5 PCLK = ~PCLK;
  end
 initial
 begin
  // select is disabled
  PRESETn =1'b1;
  PSEL =1'b0;
  PENABLE =1'b1;
  PADDR = DIRECTION;
  PWDATA =8'b11110000;  //first 4 pins output
                        //second four pins input
  
  //writing on DIRECTION reg
  PWRITE =1'b1;
  PSEL =1'b1;
  #10 ;
 
  //writing on DATA reg 
  PSEL = 1'b0;
  PADDR=DATA;
  PWDATA =8'b11100011;
  #10;

  //writing
  PWRITE =1'b1;
  PSEL = 1'b1;
  #10;
  

  //reading from DATA reg 
  PWRITE =1'b0;
  #10;
  
  //reading from DATA after forcing values in the inpu pins
  force pins=8'b11111111;
  PWRITE =1'b0;
  #10;

  //RESET
  PRESETn=1'b0;
  #10 ;

 end 
endmodule
