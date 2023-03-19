`timescale 1ns/1ns

module gpio #(
  parameter PDATA_SIZE = 32  //must be a multiple of 8
)
(
    input PCLK,
    input PRESETn,
    input PSEL,
    input PENABLE,
    input PWRITE,
    input [PDATA_SIZE-1:0]PADDR,
    input [PDATA_SIZE-1:0]PWDATA,
    output reg [PDATA_SIZE-1:0]PRDATA,
    output reg PREADY,
    inout [31:0] PINS ); // pins external to the world
	
    reg temp;
    localparam gpio_id = 1;
    reg [31:0] reg_addr;
    reg [31:0] addresses [1:0] ; /// 2 registers each one is 8 bits
	localparam  DATA = 1'b0,
                DIRECTION = 1'b1;

    reg [31:0] data, direction, pins1 ;
	
    always @(posedge PCLK)
    begin
        pins1 = PINS;
        data = addresses[DATA];
        direction = addresses[DIRECTION];
        addresses[DATA] = (data & direction) | (pins1 & ~direction);
    end


    always @(posedge PCLK)
    begin
        if(!PRESETn)
            PREADY = 0;
        else
        begin
            if (PSEL == gpio_id) 
            begin
                if(!PENABLE)
                begin
                    PREADY = 0;
                end
                else
                begin
                    if(!PWRITE)
                    begin  
                        PREADY = 1;
                        reg_addr =  PADDR; 
                        PRDATA <= addresses[reg_addr];
                         
                    end

                    else if(PWRITE)
                    begin
                        PREADY = 1;
                        addresses[PADDR] = PWDATA; 
                    end
                end
            end
            else
            begin
                PREADY = 0;
            end

        end
    end
endmodule