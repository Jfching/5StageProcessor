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

    reg [9:0] pc;
    
    wire [9:0] branch_out;
    wire [9:0] jump_out;

    always @(posedge clk or posedge reset)
    begin
        if (reset)
            begin
                pc <= 10'b0000000000;
            end
        
        else if (en)
            begin
                pc <= jump_out;
            end
    end 

    assign pc_plus4 = pc + 10'b0000000100;

    instruction_mem instr_mem 
    (
        .read_addr(pc),
        .data(instr)
    );

    mux2 #(.mux_width(10)) branch_mux
    (   
        .a(pc_plus4),
        .b(branch_address),
        .sel(branch_taken),
        
        .y(branch_out)
    );

    mux2 #(.mux_width(10)) jump_mux
    (   
        .a(branch_out),
        .b(jump_address),
        .sel(jump),
        
        .y(jump_out)
    );

endmodule