`timescale 1ns / 1ps

module risc32i(
    input clk,
    input rst
    //output [31:0] Result
    );
    
    wire [31:0] data_out_instr;
    wire  [6:0] op_code = data_out_instr[6:0];
    wire  [2:0] func3 = data_out_instr[14:12];
    wire  [6:0] func7 = data_out_instr[31:25];
    
    wire [31:0] PC;
    wire [31:0] pc_next;
    
    wire [31:0] Result;
    wire [4:0] addr1_r = data_out_instr[19:15];
    wire [4:0] addr2_r = data_out_instr[24:20];
    wire [4:0] addr3_w = data_out_instr[11:7];
    wire [31:0] rd1, rd2, Src_B;
    
    wire zero, PC_src, we, u_s, reg_write;
    wire [1:0] Res_src;
    wire [3:0] ALU_Control;
    wire ALU_src;
    wire [3:0] wstrb, wstrb_load;
    wire [2:0] Imm_src;
    
    wire [31:0] ALU_res;
    
    wire [31:0] Read_Data;
    
    wire [31:0] PC_plus4, PC_target;
    
    wire [31:0] Imm_Ext;
    
    wire [31:0] PC_in;
    wire pc_in_sel;
        
    PC pc(
        .clk(clk),
        .reset(rst),
        .pc_next(pc_next),
        .PC(PC)
    );
    
    instr_mem #(.w(32), .d(2000)) i_mem(
        .addr_instr(PC),
        .data_out_instr(data_out_instr)
    );
    
    RF rf(
        .clk(clk), 
        .rst(rst),
        .we(reg_write),
        .data_in(Result),
        .addr1_r(addr1_r), 
        .addr2_r(addr2_r), 
        .addr3_w(addr3_w),
        .data_out_1(rd1), 
        .data_out_2(rd2)
    );
    
    control_unit cont_unit(
        .op_code(op_code),
        .func3(func3),
        .func7(func7),
        .zero(zero),
        .PC_src(PC_src),
        .Res_src(Res_src),
        .mem_write(we),
        .ALU_Control(ALU_Control),
        .u_s(u_s),
        .ALU_src(ALU_src),
        .wstrb(wstrb),
        .wstrb_load(wstrb_load), //bunu eklemeyi unutmaa
        .Imm_src(Imm_src),
        .reg_write(reg_write),
        .pc_in_sel(pc_in_sel)
    );
    
    ALU alu(
        .A(rd1), 
        .B(Src_B),
        .op(ALU_Control),
        .u_s(u_s),
        .FU(ALU_res),
        .zero(zero)
    );
        
    extend extenddd(
        .Instr(data_out_instr), //12 bit imm
        .imm_src(Imm_src),
        .Imm_Ext(Imm_Ext) //sign extended imm
    );

    plus_four plusfour(
        .PC(PC),
        .PC_plus4(PC_plus4)
    );
    
    plus_imm_ext1 plus_imm_nextt(
        .PC(PC_in),
        .Imm_Ext(Imm_Ext),
        .PC_Target(PC_target)
    );
    
    data_mem  #(.w(32), .d(256)) d_mem(
        .clk(clk),
        .data_in(rd2),
        .addr_in(ALU_res),
        .we(we),
        .wstrb(wstrb),
        .wstrb_load(wstrb_load),
        .data_out(Read_Data)
    );    
    
    mux_pcnext mux_pcnexttt(
        .PC_Src(PC_src),
        .PC_plus4(PC_plus4),
        .PC_target(PC_target),
        .PC_next(pc_next)
    );
    
    mux_Bin mux_b_in(
        .ALU_Src(ALU_src),
        .RD_2(rd2),
        .Imm_Ext(Imm_Ext),
        .Src_B(Src_B)
    );
    
    mux_result mux_res(
        .Res_Src(Res_src),
        .ALU_res(ALU_res),
        .read_data(Read_Data),
        .PC_plus4(PC_plus4),
        .PC_target(PC_target),
        .Result(Result)
    );
    

    mux_jalr mux_j(
    .rs1(rd1), 
    .pc(PC),
    .pc_in_sel(pc_in_sel),//controlden pc_in_sel çýkcak
    .PC_in(PC_in)
    );
    
    integer f;
    initial begin
        f = $fopen("spike_rtl.log");
    end
    
    
    integer i = 0;
    
    always @(posedge clk) begin
        i = i + 1;
        $display("%d   0x%x (0x%x) x%d 0x%x", i , PC, data_out_instr, addr3_w, Result);
        $fwrite(f, "0x%x (0x%x) x%d 0x%x\n", PC, data_out_instr, addr3_w, Result);
    end
    
endmodule
