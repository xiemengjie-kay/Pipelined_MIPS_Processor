`timescale 1ns / 1ps

// This module is for Load-Use Data Hazard: stall the processor for 1 clock cycle
module Hazard_detection(
    input id_ex_mem_read,
    input [4:0]id_ex_destination_reg,
    input [4:0] if_id_rs, if_id_rt,
    input branch_taken, jump,
    output reg Data_Hazard,
    output reg IF_Flush
    );
    
    always @(*)  
    begin
        
	// Copy the code of this module from the lab manual.  
        if (( id_ex_mem_read == 1'b1) & (( id_ex_destination_reg == if_id_rs ) | ( id_ex_destination_reg == if_id_rt )) )
            Data_Hazard = 1'b0;
        else
            Data_Hazard = 1'b1;
            
        IF_Flush = branch_taken | jump ;
	
    end
endmodule

