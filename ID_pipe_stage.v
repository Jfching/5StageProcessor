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

    wire reg_destination;
    wire branch;
    wire mem_2_reg;
    wire mem_r;
    wire mem_w; 
    wire alu_s; 
    wire reg_w;
    
    wire [1:0] alu_op1;
    wire [31:0] sign_ext;

    wire ctrl_hazard = (!Data_Hazard) |                 //CHECK BUGTEST
                            Control_Hazard;
    wire [31:0] reg_1;
    wire [31:0] reg_2;
    
    wire eq = ((reg_1 ^ reg_2 ) == 32'd0) ?             //CHECK BUGTEST
                    1'b1: 1'b0;

    assign branch_address = (sign_ext << 2) + pc_plus4;
    assign jump_address = instr[25:0]<<2;
    assign imm_value =  sign_ext;

    control control_unit
    (
        .reset(reset),
        .opcode(instr[31:26]),
        .reg_dst(reg_destination),
        .mem_to_reg(mem_2_reg),
        .alu_op(alu_op1),
        .mem_read(mem_r),
        .mem_write(mem_w),
        .alu_src(alu_s),
        .reg_write(reg_w),
        .branch(branch),
        .jump(jump)
    );

    mux2 #(.mux_width(5)) mux
    (
        .a(instr[20:16]),
        .b(instr[15:11]),
        .sel(reg_destination), 
        .y(destination_reg)
    );

    mux2 #(.mux_width(1)) mem2reg
    (
        .a(mem_2_reg),
        .b(1'b0),
        .sel(ctrl_hazard),
        .y(mem_to_reg)
    );

    mux2 #(.mux_width(1)) mem2r
    (
        .a(mem_r),
        .b(1'b0),
        .sel(ctrl_hazard),
        .y(mem_read)
    );

    mux2 #(.mux_width(1)) mem2w
    (
        .a(mem_w),
        .b(1'b0),
        .sel(ctrl_hazard),
        .y(mem_write)
    );

    mux2 #(.mux_width(1)) alu_s_ctrl
    (
        .a(alu_s),
        .b(1'b0),
        .sel(ctrl_hazard),
        .y(alu_src)
    );

    mux2 #(.mux_width(1)) reg_w_ctrl
    (
        .a(reg_w),
        .b(1'b0),
        .sel(ctrl_hazard),
        .y(reg_write)
    );

    mux2 #(.mux_width(2)) alu_o_ctrl
    (
        .a(alu_op1),
        .b(2'b00),
        .sel(ctrl_hazard),
        .y(alu_op)
    );

    register_file Register
    (
        .clk(clk),
        .reset(reset),
        .reg_read_addr_1(instr[25:21]),
        .reg_read_addr_2(instr[20:16]),
        .reg_read_data_1(reg_1),
        .reg_read_data_2(reg_2),
        .reg_write_en(mem_wb_reg_write),
        .reg_write_dest(mem_wb_write_reg_addr),
        .reg_write_data(mem_wb_write_back_data)
    );

    sign_extend imm
    (
        .sign_ex_in(instr[15:0]),
        .sign_ex_out(sign_ext)
    );

    assign reg1 = reg_1;
    assign reg2 = reg_2;
    assign branch_taken = eq & branch; 

endmodule