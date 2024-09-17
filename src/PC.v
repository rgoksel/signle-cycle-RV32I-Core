`timescale 1ns / 1ps

module PC(
    input clk,
    input reset,
    input [31:0] pc_next,
    output reg [31:0] PC
    );
    
    initial begin
        PC <= 32'h80000000;
    end 
    
    always @(posedge clk) begin
//        if(reset)
//            PC <= 32'h80000000;
//        else
            PC <= pc_next;
    end
endmodule

module plus_four (
    input [31:0] PC,
    output [31:0] PC_plus4
);

assign PC_plus4 = PC + 32'd4;
endmodule

module plus_imm_ext1 (
    input [31:0] PC,
    input [31:0] Imm_Ext,
    output [31:0] PC_Target
);

wire [31:0] C;

//assign PC_Taget = PC + Imm_Ext;

    genvar i;
    generate 
        for (i = 0; i < 32 ; i = i +1) begin
            if ( i == 0) begin
                full_adder fa_1(.A_i(PC[i]), .B_i(Imm_Ext[i]), .Cin(0), .Sum(PC_Target[i]), .Cout(C[i]));
            end
            else  if ( i > 0) begin
                full_adder fa_1(.A_i(PC[i]), .B_i(Imm_Ext[i]), .Cin(C[i-1]), .Sum(PC_Target[i]), .Cout(C[i]));
            end
        end
    endgenerate

endmodule
