`timescale 1ns / 1ps

module EX_Forwarding_unit(
    input ex_mem_reg_write,
    input [4:0] ex_mem_write_reg_addr,
    input [4:0] id_ex_instr_rs,
    input [4:0] id_ex_instr_rt,
    input mem_wb_reg_write,
    input [4:0] mem_wb_write_reg_addr,
    output reg [1:0] Forward_A,
    output reg [1:0] Forward_B
    );

    always @(*)
    begin
        if ((ex_mem_reg_write == 1'b1)  & 
            (ex_mem_write_reg_addr != 5'b00000) & 
               (ex_mem_write_reg_addr == id_ex_instr_rs)) 
        begin
            Forward_A = 2'b10;
        end

        else if ((ex_mem_reg_write == 1'b1) & 
            (ex_mem_write_reg_addr != 5'b00000) & 
                (ex_mem_write_reg_addr == id_ex_instr_rt)) 
        begin
            Forward_B = 2'b10;
        end

        else if 
            ((mem_wb_reg_write == 1'b1) &
                (mem_wb_write_reg_addr != 5'b00000) &!
                    ((ex_mem_reg_write == 1'b1) & 
                        (ex_mem_write_reg_addr != 5'b00000) &
                            (ex_mem_write_reg_addr == id_ex_instr_rs)) &&
                                (mem_wb_write_reg_addr == id_ex_instr_rs))
        begin
            Forward_A = 2'b01;
        end

        else if 
            ((mem_wb_reg_write == 1'b1) &
                (mem_wb_write_reg_addr != 5'b00000) &!
                    ((ex_mem_reg_write == 1'b1) & 
                        (ex_mem_write_reg_addr != 5'b00000) &
                            (ex_mem_write_reg_addr == id_ex_instr_rt)) & 
                                (mem_wb_write_reg_addr == id_ex_instr_rt))
        begin
            Forward_B = 2'b01;
        end

        else 
        begin
            Forward_A = 2'b00;
            Forward_B = 2'b00;
        end

    end 

/*    always @(*)
    begin

    if((ex_mem_reg_write == 1'b1) &
       (ex_mem_write_reg_addr != 5'b00000) &
          (ex_mem_write_reg_addr == id_ex_instr_rs))
               Forward_A=2'b10;

     else if((ex_mem_reg_write == 1'b1) &
       (ex_mem_write_reg_addr != 5'b00000) &
          (ex_mem_write_reg_addr == id_ex_instr_rt))
               Forward_B=2'b10;

     else if((ex_mem_reg_write == 1'b1) &
           (ex_mem_write_reg_addr != 5'b00000) &!
               (ex_mem_reg_write == 1'b1) & 
                   (id_ex_instr_rs != 5'b00000) &
                       (ex_mem_write_reg_addr == id_ex_instr_rs))
                           Forward_A = 2'b01;

      else if((ex_mem_reg_write == 1'b1) &
           (ex_mem_write_reg_addr != 5'b00000) &!
               (ex_mem_reg_write == 1'b1) & 
                   (id_ex_instr_rs != 5'b00000) &
                       (ex_mem_write_reg_addr == id_ex_instr_rt))
                           Forward_B = 2'b01;

     else
       begin
           Forward_A = 2'b00;
           Forward_B = 2'b00;
       end */

endmodule