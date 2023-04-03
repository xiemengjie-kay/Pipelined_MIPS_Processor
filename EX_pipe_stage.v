`timescale 1ns / 1ps

module EX_pipe_stage(
    input [31:0] id_ex_instr,
    input [31:0] reg1, reg2,
    input [31:0] id_ex_imm_value,
    input [31:0] ex_mem_alu_result,
    input [31:0] mem_wb_write_back_result,
    input id_ex_alu_src,
    input [1:0] id_ex_alu_op,
    input [1:0] Forward_A, Forward_B,
    output [31:0] alu_in2_out,
    output [31:0] alu_result
    );
    
    // Write your code here
    wire [31:0] alu_input1;
    wire [31:0] alu_input2;
    wire [3:0] ALU_Control;
    
    mux4#(.mux_width(32)) alu_input1_mux (
        .a(reg1),
        .b(mem_wb_write_back_result),
        .c(ex_mem_alu_result),
        .d(32'b0),
        .sel(Forward_A),
        .y(alu_input1));
        
    mux4#(.mux_width(32)) alu_in2_out_mux (
        .a(reg2),
        .b(mem_wb_write_back_result),
        .c(ex_mem_alu_result),
        .d(32'b0),
        .sel(Forward_B),
        .y(alu_in2_out));
        
    mux2#(.mux_width(32)) alu_input2_mux (
        .a(alu_in2_out),
        .b(id_ex_imm_value),
        .sel(id_ex_alu_src),
        .y(alu_input2));
        
    ALU ALU_inst(
        .a(alu_input1),
        .b(alu_input2),
        .alu_control(ALU_Control),
        .alu_result(alu_result));
    
    ALUControl ALUControl_inst (
        .ALUOp(id_ex_alu_op), 
        .Function(id_ex_instr[5:0]),
        .ALU_Control(ALU_Control));
        
       
endmodule
