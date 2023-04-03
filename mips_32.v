`timescale 1ns / 1ps


module mips_32(
    input clk, reset,  
    output[31:0] result
    );
    
// define all the wires here. You need to define more wires than the ones you did in Lab2
    wire Data_Hazard;
    wire [9:0] branch_address;
    wire [9:0] jump_address;
    wire branch_taken;
    wire jump;
    wire [9:0] pc_plus4;
    wire [31:0] instr;
    wire IF_Flush;
    wire mem_wb_reg_write;
    wire [4:0] mem_wb_destination_reg;
    wire [31:0] write_back_data;
    wire [31:0] reg1, reg2;
    wire [31:0] imm_value;
    wire [4:0] destination_reg;
    wire mem_to_reg;
    wire [1:0] alu_op;
    wire mem_read;
    wire mem_write;
    wire alu_src;
    wire reg_write;
    wire [41:0] if_id_registers_input;
    wire [41:0] if_id_registers_output;
    wire [9:0] if_id_pc_plus4;
    wire [31:0] if_id_instr;
    wire [139:0] id_ex_registers_input;
	wire [139:0] id_ex_registers_output;
	wire [31:0] id_ex_instr;
	wire [31:0] id_ex_reg1;
	wire [31:0] id_ex_reg2;
	wire [31:0] id_ex_imm_value;
	wire [4:0] id_ex_destination_reg;
	wire id_ex_mem_to_reg;
	wire [1:0] id_ex_alu_op;
	wire id_ex_mem_read;
	wire id_ex_mem_write;
	wire id_ex_alu_src;
	wire id_ex_reg_write;
    wire[31:0] ex_mem_alu_result;
	wire [1:0] Forward_A, Forward_B;
	wire [31:0] alu_in2_out;
	wire [31:0] alu_result;
	wire [104:0] ex_mem_registers_input;
	wire [104:0] ex_mem_registers_output;
	wire [31:0] ex_mem_instr;
	wire [4:0] ex_mem_destination_reg;
	wire [31:0] ex_mem_alu_result;
	wire [31:0] ex_mem_alu_in2_out;
	wire ex_mem_mem_to_reg;
	wire ex_mem_mem_read;
	wire ex_mem_mem_write;
	wire ex_mem_reg_write;
    wire [31:0] mem_read_data;
    wire [70:0] mem_wb_registers_input;
	wire [70:0] mem_wb_registers_output;
	wire [31:0] mem_wb_alu_result;
	wire [31:0] mem_wb_mem_read_data;
	wire mem_wb_mem_to_reg;
    
    assign result = write_back_data;
   


// Build the pipeline as indicated in the lab manual

///////////////////////////// Instruction Fetch    
    // Complete your code here   
    IF_pipe_stage IF_pipe_stage_inst (
        .clk(clk), 
        .reset(reset),
        .en(Data_Hazard),
        .branch_address(branch_address),
        .jump_address(jump_address),
        .branch_taken(branch_taken),
        .jump(jump),
        .pc_plus4(pc_plus4),
        .instr(instr));   

        
///////////////////////////// IF/ID registers
    // Complete your code here
    // q = sum of pc + inst_addr
    // the order matters
    assign if_id_registers_input = {pc_plus4, instr};
    assign if_id_pc_plus4 = if_id_registers_output[41:32];
    assign if_id_instr = if_id_registers_output[31:0];
    
    pipe_reg_en #(.WIDTH(42)) if_id_registers (
        .clk(clk), 
        .reset(reset),
        .en(Data_Hazard),
        .flush(IF_Flush),
        .d(if_id_registers_input),
        .q(if_id_registers_output));


///////////////////////////// Instruction Decode 
	// Complete your code here
	ID_pipe_stage ID_pipe_stage_inst (
        .clk(clk), 
        .reset(reset),
        .pc_plus4(if_id_pc_plus4),
        .instr(if_id_instr),
        .mem_wb_reg_write(mem_wb_reg_write),
        .mem_wb_write_reg_addr(mem_wb_destination_reg),
        .mem_wb_write_back_data(write_back_data),
        .Data_Hazard(Data_Hazard),
        .Control_Hazard(IF_Flush),
        .reg1(reg1), 
        .reg2(reg2),
        .imm_value(imm_value),
        .branch_address(branch_address),
        .jump_address(jump_address),
        .branch_taken(branch_taken),
        .destination_reg(destination_reg), 
        .mem_to_reg(mem_to_reg),
        .alu_op(alu_op),
        .mem_read(mem_read),  
        .mem_write(mem_write),
        .alu_src(alu_src),
        .reg_write(reg_write),
        .jump(jump));

             
///////////////////////////// ID/EX registers 
	// Complete your code here
	assign id_ex_registers_input = {if_id_instr,reg1,reg2,imm_value,destination_reg,mem_to_reg,alu_op,mem_read,mem_write,alu_src,reg_write};
	assign id_ex_instr = id_ex_registers_output[139:108];
	assign id_ex_reg1 = id_ex_registers_output[107:76];
	assign id_ex_reg2 = id_ex_registers_output[75:44];
	assign id_ex_imm_value = id_ex_registers_output[43:12];
	assign id_ex_destination_reg = id_ex_registers_output[11:7];
	assign id_ex_mem_to_reg = id_ex_registers_output[6];
	assign id_ex_alu_op = id_ex_registers_output[5:4];
	assign id_ex_mem_read = id_ex_registers_output[3];
	assign id_ex_mem_write = id_ex_registers_output[2];
	assign id_ex_alu_src = id_ex_registers_output[1];
	assign id_ex_reg_write = id_ex_registers_output[0];
	
	pipe_reg #(.WIDTH(140)) id_ex_registers (
        .clk(clk), 
        .reset(reset),
        .d(id_ex_registers_input),
        .q(id_ex_registers_output));
	

///////////////////////////// Hazard_detection unit
	// Complete your code here    
    Hazard_detection Hazard_detection_inst(
        .id_ex_mem_read(id_ex_mem_read),
        .id_ex_destination_reg(id_ex_destination_reg),
        .if_id_rs(if_id_instr[25:21]), 
        .if_id_rt(if_id_instr[20:16]),
        .branch_taken(branch_taken), 
        .jump(jump),
        .Data_Hazard(Data_Hazard),
        .IF_Flush(IF_Flush));
    
           
///////////////////////////// Execution    
	// Complete your code here
	EX_pipe_stage EX_pipe_stage_inst (
        .id_ex_instr(id_ex_instr),
        .reg1(id_ex_reg1), 
        .reg2(id_ex_reg2),
        .id_ex_imm_value(id_ex_imm_value),
        .ex_mem_alu_result(ex_mem_alu_result),
        .mem_wb_write_back_result(write_back_data),
        .id_ex_alu_src(id_ex_alu_src),
        .id_ex_alu_op(id_ex_alu_op),
        .Forward_A(Forward_A), 
        .Forward_B(Forward_B),
        .alu_in2_out(alu_in2_out),
        .alu_result(alu_result));
	
        
///////////////////////////// Forwarding unit
	// Complete your code here 
	
	EX_Forwarding_unit EX_Forwarding_unit_inst (
        .ex_mem_reg_write(ex_mem_reg_write),
        .ex_mem_write_reg_addr(ex_mem_destination_reg),
        .id_ex_instr_rs(id_ex_instr[25:21]),
        .id_ex_instr_rt(id_ex_instr[20:16]),
        .mem_wb_reg_write(mem_wb_reg_write),
        .mem_wb_write_reg_addr(mem_wb_destination_reg),
        .Forward_A(Forward_A),
        .Forward_B(Forward_B));

     
///////////////////////////// EX/MEM registers
	// Complete your code here 
	assign ex_mem_registers_input = {id_ex_instr,id_ex_destination_reg,alu_result,alu_in2_out,id_ex_mem_to_reg,id_ex_mem_read,id_ex_mem_write,
	   id_ex_reg_write};
	assign ex_mem_instr = ex_mem_registers_output[104:73];
	assign ex_mem_destination_reg = ex_mem_registers_output[72:68];
	assign ex_mem_alu_result = ex_mem_registers_output[67:36];
	assign ex_mem_alu_in2_out = ex_mem_registers_output[35:4];
	assign ex_mem_mem_to_reg = ex_mem_registers_output[3];
	assign ex_mem_mem_read = ex_mem_registers_output[2];
	assign ex_mem_mem_write = ex_mem_registers_output[1];
	assign ex_mem_reg_write = ex_mem_registers_output[0];
	
	
	pipe_reg #(.WIDTH(105)) ex_mem_registers (
        .clk(clk), 
        .reset(reset),
        .d(ex_mem_registers_input),
        .q(ex_mem_registers_output));

    
///////////////////////////// memory    
	// Complete your code here	
	data_memory data_mem (
        .clk(clk),
        .mem_access_addr(ex_mem_alu_result),
        .mem_write_data(ex_mem_alu_in2_out),
        .mem_write_en(ex_mem_mem_write),
        .mem_read_en(ex_mem_mem_read),
        .mem_read_data(mem_read_data));
     

///////////////////////////// MEM/WB registers  
	// Complete your code here
	assign mem_wb_registers_input = {ex_mem_alu_result,mem_read_data,ex_mem_mem_to_reg,ex_mem_reg_write,ex_mem_destination_reg};
	assign mem_wb_alu_result = mem_wb_registers_output[70:39];
	assign mem_wb_mem_read_data = mem_wb_registers_output[38:7];
	assign mem_wb_mem_to_reg = mem_wb_registers_output[6];
	assign mem_wb_reg_write = mem_wb_registers_output[5];
	assign mem_wb_destination_reg = mem_wb_registers_output[4:0];
	
	pipe_reg #(.WIDTH(71)) mem_wb_registers (
        .clk(clk), 
        .reset(reset),
        .d(mem_wb_registers_input),
        .q(mem_wb_registers_output));
    

///////////////////////////// writeback    
	// Complete your code here
    mux2 #(.mux_width(32)) writeback (   
    .a(mem_wb_alu_result),
    .b(mem_wb_mem_read_data),
    .sel(mem_wb_mem_to_reg),
    .y(write_back_data));

    
endmodule
