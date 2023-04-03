`timescale 1ns / 1ps


module ID_pipe_stage(
    input  clk, reset,
    input  [9:0] pc_plus4,
    input  [31:0] instr,
    input  mem_wb_reg_write,
    input  [4:0] mem_wb_write_reg_addr,
    input  [31:0] mem_wb_write_back_data,
    input  Data_Hazard,
    input  Control_Hazard,
    output [31:0] reg1, reg2,
    output [31:0] imm_value,
    output [9:0] branch_address,
    output [9:0] jump_address,
    output branch_taken,
    output [4:0] destination_reg, 
    output mem_to_reg,
    output [1:0] alu_op,
    output mem_read,  
    output mem_write,
    output alu_src,
    output reg_write,
    output jump
    );
    
    // write your code here 
    // Remember that we test if the branch is taken or not in the decode stage. 	
    wire hazard;
    wire mem_to_reg_target;
    wire [1:0] alu_op_target;
    wire mem_read_target;
    wire mem_write_target;
    wire alu_src_target;
    wire reg_write_target;
    wire [6:0] hazard_mux_input_0;
    wire [6:0] hazard_mux_output;
    wire [5:0] instr_31_26;
    wire reg_dst;
    wire [15:0] instr_15_0;
    wire [31:0] sign_extended_imme;
    wire [4:0] instr_20_16;
    wire [4:0] instr_15_11;
    wire [4:0] instr_25_21;
    wire branch;
    wire [31:0] reg_read_data_1;
    wire [31:0] reg_read_data_2;
    wire eq_test;
    
    assign hazard = (!Data_Hazard) || Control_Hazard;
    assign hazard_mux_input_0 = {mem_to_reg_target, alu_op_target, mem_read_target, mem_write_target, alu_src_target, reg_write_target};
    assign mem_to_reg = hazard_mux_output[6];
    assign alu_op = hazard_mux_output[5:4];
    assign mem_read = hazard_mux_output[3];
    assign mem_write = hazard_mux_output[2];
    assign alu_src = hazard_mux_output[1];
    assign reg_write = hazard_mux_output[0];
    assign instr_31_26 = instr[31:26];
    assign instr_15_0 = instr[15:0];
    assign instr_20_16 = instr[20:16];
    assign instr_15_11 = instr[15:11];
    assign instr_25_21 = instr[25:21];
    assign jump_address = instr[25:0] << 2;
    assign branch_address = (sign_extended_imme << 2) + pc_plus4;
    assign branch_taken = branch && eq_test;
    assign eq_test = ((reg_read_data_1 ^ reg_read_data_2) == 32'b0) ? 1'b1 : 1'b0;
    assign reg1 = reg_read_data_1;
    assign reg2 = reg_read_data_2;
    assign imm_value = sign_extended_imme;
    
    mux2 #(.mux_width(7)) hazard_mux (   
    .a(hazard_mux_input_0),
    .b(7'b0),
    .sel(hazard),
    .y(hazard_mux_output));
    
    control control_inst (
        .reset(reset),
        .opcode(instr_31_26),  
        .reg_dst(reg_dst), 
        .mem_to_reg(mem_to_reg_target), 
        .alu_op(alu_op_target),  
        .mem_read(mem_read_target), 
        .mem_write(mem_write_target), 
        .alu_src(alu_src_target), 
        .reg_write(reg_write_target), 
        .branch(branch), 
        .jump(jump));
    
    register_file register_file_inst (
        .clk(clk),
        .reset(reset),  
        .reg_write_en(mem_wb_reg_write),  
        .reg_write_dest(mem_wb_write_reg_addr),  
        .reg_write_data(mem_wb_write_back_data),
        .reg_read_addr_1(instr_25_21), 
        .reg_read_addr_2(instr_20_16),  
        .reg_read_data_1(reg_read_data_1),  
        .reg_read_data_2(reg_read_data_2));
    
    sign_extend sign_extend_inst (
        .sign_ex_in(instr_15_0),
        .sign_ex_out(sign_extended_imme));
    
    mux2 #(.mux_width(5)) reg_dst_mux
    (   .a(instr_20_16),
        .b(instr_15_11),
        .sel(reg_dst),
        .y(destination_reg));
       
endmodule
