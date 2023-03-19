`include "APB_Bridge_Master.v"
`include "gpio_main.v"
`include "UART_TOP.v"



`timescale 1ns/1ns



module APB_Protocol(
				input PCLK,PRESETn,transfer,READ_WRITE,
                input [32:0] apb_write_paddr,
				input [31:0]apb_write_data,
				input [32:0] apb_read_paddr,
				output PSLVERR, 
                output [31:0] apb_read_data_out
				);


	wire [31:0]PWDATA,PRDATA,PRDATA1,PRDATA2;
	wire [32:0]PADDR;

	wire PREADY,PREADY1,PREADY2,PENABLE,PSEL1,PSEL2,PWRITE;
    
      
	assign PREADY = PADDR[32] ? PREADY2 : PREADY1 ;
	assign PRDATA = READ_WRITE ? (PADDR[32] ? PRDATA2 : PRDATA1) : 32'dx ;

    APB_Bridge MASTER(
	        apb_write_paddr,
		    apb_read_paddr,
		    apb_write_data,
		    PRDATA,         
	        PRESETn,
		    PCLK,
		    READ_WRITE,
		    transfer,
		    PREADY,
	        PSEL1,
		    PSEL2,
		    PENABLE,
	        PADDR,
	        PWRITE,
	        PWDATA,
		    apb_read_data_out,
		    PSLVERR
	        ); 


    gpio S1(  PCLK,PRESETn, PSEL1,PENABLE,PWRITE, PADDR[31:0],PWDATA, PRDATA1, PREADY1);
      
	  
	UART_TOP S2(  PCLK,PRESETn, PSEL2,PENABLE,PWRITE, PADDR[31:0],PWDATA, PRDATA2, PREADY2);  


endmodule