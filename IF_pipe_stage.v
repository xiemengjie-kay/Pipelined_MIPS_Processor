`timescale 1ns / 1ps


module IF_pipe_stage(
    input clk, reset,
    input en,
    input [9:0] branch_address,
    input [9:0] jump_address,
    input branch_taken,
    input jump,
    output [9:0] pc_plus4,
    output [31:0] instr
    );
   
    // write your code here
    reg [9:0] pc;
    
    wire [9:0] branch_address_mux_output;
    wire [9:0] jump_address_mux_output;
    wire [9:0] pc_target;
    
    // instantiated muxes are independent from the clk since they are combinational logics
    mux2 #(.mux_width(10)) branch_address_mux
    (   .a(pc_plus4),
        .b(branch_address),
        .sel(branch_taken),
        .y(branch_address_mux_output));   
        
    mux2 #(.mux_width(10)) jump_address_mux
    (   .a(branch_address_mux_output),
        .b(jump_address),
        .sel(jump),
        .y(jump_address_mux_output));
    
    assign pc_plus4 = pc + 10'b0000000100;
    assign pc_target = en ? jump_address_mux_output : pc;
    
    always @(posedge clk, posedge reset) begin
        if (reset) 
            pc <= 10'b0000000000;
        else 
            pc <= pc_target;
    end
    
    instruction_mem inst_mem (
        .read_addr(pc),
        .data(instr));
           
endmodule
