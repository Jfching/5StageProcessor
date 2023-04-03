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
    
    output [31:0] alu_in_out,
    output [31:0] alu_result
    );

    wire [3:0] ALU_Control;
    
    wire [31:0] reg1_output; 
    wire [31:0] reg2_output;
    wire [31:0] fin;

    mux4 #(.mux_width(32)) reg1_mux
    (   
        .a(reg1),
        .b(mem_wb_write_back_result),
        .c(ex_mem_alu_result),
        .d(32'b0),
        .sel(Forward_A),
        
        .y(reg1_output)
    );

    mux4 #(.mux_width(32)) reg2_mux
    (   
        .a(reg2),
        .b(mem_wb_write_back_result),
        .c(ex_mem_alu_result),
        .d(32'b0),
        .sel(Forward_B),
        
        .y(reg2_output)
    );

    mux2 #(.mux_width(32)) imm_mux
    (   
        .a(reg2_output),
        .b(id_ex_imm_value),
        .sel(id_ex_alu_src),
        
        .y(fin)
    );

    ALUControl ALUctrl
    (   
        .Function(id_ex_instr[5:0]),
        .ALUOp(id_ex_alu_op),
        .ALU_Control(ALU_Control)
    );

    ALU EX_ALU
    (   
        .a(reg1_output),
        .b(fin),
        .alu_control(ALU_Control),
        .alu_result(alu_result),
        .zero()
    );

    assign alu_in_out = reg2_output;
    
endmodule
        
        
       