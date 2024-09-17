`timescale 1ns / 1ps

module RF(
    input clk, 
    input rst,
    input we,
    input [31:0] data_in,
    input [4:0] addr1_r, addr2_r, addr3_w,
    output  [31:0] data_out_1, data_out_2
    );
    
    reg [31:0] reg_file [0:31];
    
    integer i;
    
    assign   data_out_1 = reg_file[addr1_r];
    assign   data_out_2 = reg_file[addr2_r];
    
//    always @(clk) begin
//        if(rst) begin
//            for (i = 0 ; i < 32 ; i = i +1) begin
//                reg_file[i] <= 32'b0;
//            end            
//        end
//    end
    
//    always @(posedge clk) begin
//        if (we && addr3_w != 32'd0) begin
//            reg_file[addr3_w] <= data_in;
//        end
//    end


    
    always @(negedge clk) begin
        if(rst) begin
            for (i = 0 ; i < 32 ; i = i +1) begin
                reg_file[i] <= 32'b0;
            end            
        end else begin
            if (we && addr3_w != 32'd0) begin
                reg_file[addr3_w] <= data_in;
            end
//            data_out_1 <= reg_file[addr1_r];
//            data_out_2 <= reg_file[addr2_r];
        end
    end
    
    
endmodule


module extend (
    input [31:0] Instr, //12 bit imm
    input [2:0] imm_src,
    output [31:0] Imm_Ext //sign extended imm
    
);

    assign Imm_Ext= (imm_src == 3'b000) ? {{20{Instr[31]}}, Instr[31:20]}: // � type
                    (imm_src == 3'b001) ? {{20{Instr[31]}}, Instr[31:25], Instr[11:7]}:  //s typr
                    (imm_src == 3'b010) ? {{20{Instr[31]}}, Instr[7], Instr[30:25], Instr[11:8], 1'b0}: //b type
                    (imm_src == 3'b011) ? {{12{Instr[31]}}, Instr[19:12], Instr[20], Instr[30:21], 1'b0}: ////j typ //21 olabilir
                    (imm_src == 3'b100 || 3'b101) ? ({Instr[31:12], 12'd0}) : 
                    32'd0; //auipc

endmodule
