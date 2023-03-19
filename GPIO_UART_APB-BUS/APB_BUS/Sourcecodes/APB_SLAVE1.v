

`timescale 1ns/1ns



module APB_SLAVE1(
         input PCLK,PRESETn,
         input PSEL,PENABLE,PWRITE,
         input [31:0]PADDR,PWDATA,
        output [31:0]PRDATA1,
        output reg PREADY );
    
     reg [31:0]reg_addr;
     reg [31:0] mem [0:63];

    assign PRDATA1 =  mem[reg_addr];

    always @(*)
       begin
         if(!PRESETn)
              PREADY = 0;
          else
	  if(PSEL && !PENABLE && !PWRITE)
	     begin PREADY = 0; end
	         
	  else if(PSEL && PENABLE && !PWRITE)
	     begin  PREADY = 1;
                    reg_addr =  PADDR; 
	       end
          else if(PSEL && !PENABLE && PWRITE)
	     begin  PREADY = 0; end

	  else if(PSEL && PENABLE && PWRITE)
	     begin  PREADY = 1;
	            mem[PADDR] = PWDATA; end

           else PREADY = 0;
        end
    endmodule