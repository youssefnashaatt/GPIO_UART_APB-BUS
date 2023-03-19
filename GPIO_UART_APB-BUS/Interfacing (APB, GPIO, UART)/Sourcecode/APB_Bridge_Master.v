/*****************************************************************************************
File_name: APB_Bridge.v
Description: Implementation of master APB Bridge
Author: Youssef Nashaat 1900124 & Engy Mohamed 1900630
******************************************************************************************/

module APB_Bridge(
	input [32:0]apb_write_paddr,apb_read_paddr,
	input [31:0] apb_write_data,PRDATA,         
	input PRESETn,PCLK,READ_WRITE,transfer,PREADY,
	output PSEL1,PSEL2,
	output reg PENABLE,
	output reg [32:0]PADDR,
	output reg PWRITE,
	output reg [31:0]PWDATA,apb_read_data_out,
	output PSLVERR ); 
	
	reg [2:0] state, next_state;
	
	reg invalid_setup_error,
	setup_error,
	invalid_read_paddr,
	invalid_write_paddr,
	invalid_write_data ;
	
	localparam IDLE = 3'b001, SETUP = 3'b010, ACCESS = 3'b100 ;
	
	//Jump into next state each positive edge
	always @(posedge PCLK)
	begin
	if(!PRESETn)
		state <= IDLE;
	else
		state <= next_state; 
	end
	
	
	always @(state,transfer,PREADY)
	begin
	
	//PWRITE = READ_WRITE
	if(!PRESETn)
	next_state <= IDLE;
	
	else begin
	
		case(state)
	
		IDLE:
		begin
			PENABLE = 0;
		
			if(transfer)
				next_state = SETUP;
			
			else
				next_state = IDLE;
		end

		SETUP:
		begin
			PENABLE = 0;

			//READ_WRITE = 1 -> APB_Read_Operation
			//READ_WRITE = 0 -> APB_Write_Operation
			if(READ_WRITE) begin
				PADDR = apb_read_paddr;
				PWRITE = 0;
			end
		
			else begin   
				PADDR = apb_write_paddr;
				PWDATA = apb_write_data;
				PWRITE = 1;
			end
			
			
			if(transfer && !PSLVERR)
				next_state = ACCESS;
		            
			else
				next_state = IDLE;
			end
	
	
		ACCESS:
		begin
			if(PSEL1 || PSEL2)
				PENABLE = 1;
			
			if(transfer & !PSLVERR)
			begin
				if(PREADY) begin
				
					if(!READ_WRITE) begin
						next_state = SETUP;
					end
					
					else begin
						next_state = SETUP; 
						apb_read_data_out = PRDATA;   
					end
				end
			
				else next_state = ACCESS;
			end
		             
			else next_state = IDLE;
		
		end
	
		default:
		begin
		next_state = IDLE;
	
		end
	
		endcase
	
	end
	
	end
	
	assign {PSEL1,PSEL2} = ((state != IDLE) ? (PADDR[32] ? {1'b0,1'b1} : {1'b1,1'b0}) : 2'd0);
	
	  
	always @(*)
	begin
       
		if(!PRESETn)
	    begin 
			setup_error = 0;
			invalid_read_paddr = 0;
			invalid_write_paddr = 0;
			invalid_write_paddr = 0 ;
	    end
		
        else begin
		
			if(state == IDLE && next_state == ACCESS)	
				setup_error = 1;
		
			else setup_error = 0;
        
		end
		
		begin
		if((apb_write_data===8'dx) && (!READ_WRITE) && (state==SETUP || state==ACCESS))
			invalid_write_data =1;
			
		else invalid_write_data = 0;
		end
       
		begin
		if((apb_read_paddr===9'dx) && READ_WRITE && (state==SETUP || state==ACCESS))
			invalid_read_paddr = 1;
	  
		else  invalid_read_paddr = 0;
			
		end
        
		begin
		if((apb_write_paddr===9'dx) && (!READ_WRITE) && (state==SETUP || state==ACCESS))
			invalid_write_paddr =1;
				
		else invalid_write_paddr =0;
			
		end
		
		begin
		if(state == SETUP)
       
			begin
			if(PWRITE)
		
				begin
				if(PADDR==apb_write_paddr && PWDATA==apb_write_data)
					setup_error=1'b0;
                         
				else
					setup_error=1'b1;
				end
                 
				else 
				begin
					if (PADDR==apb_read_paddr)
						setup_error=1'b0;
					else
						setup_error=1'b1;
				end    
			end 
         
			else setup_error=1'b0;
			
		end 
		
	  assign invalid_setup_error = setup_error ||  invalid_read_paddr || invalid_write_data || invalid_write_paddr;

	end
       

	assign PSLVERR =  invalid_setup_error ;		
	  
	
endmodule
	
	
	

	

