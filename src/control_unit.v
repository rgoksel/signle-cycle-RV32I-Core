`timescale 1ns / 1ps

module control_unit(
    input [6:0] op_code,
    input [2:0] func3,
    input [6:0] func7,
    input zero,
    output PC_src,
    output [1:0] Res_src,
    output mem_write,
    output [3:0] ALU_Control,
    output u_s,
    output ALU_src,
    output [3:0] wstrb,
    output [3:0] wstrb_load,
    output [2:0] Imm_src,
    output reg_write,
    output pc_in_sel
    );
    
    wire branch, jump;
    wire [1:0] ALU_op;
    
    main_decoder md(
        .op_code(op_code),
        .func3(func3),
        .Res_src(Res_src),
        .mem_write(mem_write),
        .ALU_src(ALU_src),
        .Imm_src(Imm_src),
        .reg_write(reg_write),
        .branch(branch),
        .wstrb(wstrb),
        .wstrb_load(wstrb_load),
        .jump(jump),
        .ALU_op(ALU_op),
        .pc_in_sel(pc_in_sel)
    );
    
    ALU_decoder ad(
        .ALU_op(ALU_op),
        .op_code(op_code),
        .func3(func3),
        .func7_5(func7[5]), 
        .ALU_control(ALU_Control),
        .u_s(u_s)
    );
    
    assign PC_src = (zero & branch) | jump;
    
    
endmodule


module main_decoder (
    input [6:0] op_code,
    input [2:0] func3,
    output [1:0] Res_src,
    output mem_write,
    output ALU_src,
    output [2:0] Imm_src,
    output reg_write,
    output branch,
    output [3:0] wstrb,
    output [3:0] wstrb_load,
    output jump,
    output [1:0] ALU_op,
    output pc_in_sel
);


    reg [1:0] Res_src_r;
    reg mem_write_r;
    reg ALU_src_r;
    reg [2:0] Imm_src_r;
    reg reg_write_r;
    reg branch_r;
    reg [3:0] wstrb_r;
    reg [3:0] wstrb_r_load;
    reg jump_r;
    reg [1:0] ALU_op_r;
    reg pc_in_sel_r;
    
    

    localparam [6:0] LOAD = 7'b0000011,
                     ALU_i = 7'b0010011, 
                     AUIPC = 7'b0010111, 
                     LUI = 7'b0110111,
                     STORE = 7'b0100011, 
                     ALU = 7'b0110011, 
                     BRANCH_OP = 7'b1100011, 
                     JALR = 7'b1100111, 
                     JAL = 7'b1101111;
                     
    always @(*) begin
        case (op_code)
            LOAD: begin
                Res_src_r <= 2'b01; //-
                mem_write_r <= 0; //-
                // u_s <=  
                ALU_src_r <= 1; //-
                Imm_src_r <= 3'b000; //-
                reg_write_r <= 1; //-
                branch_r <= 0;//-
                ALU_op_r <= 2'b00; //-
                jump_r <= 0; //-
                wstrb_r <= 4'b1111;
                pc_in_sel_r <= 0;
                if (func3 == 000)
                    wstrb_r_load <= 4'b0001;
                else if (func3 == 001)
                    wstrb_r_load <= 4'b0011;
                else if (func3 == 010)
                    wstrb_r_load <= 4'b1111;
                else if (func3 == 100)
                    wstrb_r_load <= 4'b1001;
                else if (func3 == 101)
                    wstrb_r_load <= 4'b1011;
                else
                    wstrb_r_load <= 4'b1111;
            end
            ALU_i: begin
                Res_src_r <= 2'b00;
                mem_write_r <= 0;
                // u_s <=  
                ALU_src_r <= 1;
                Imm_src_r <= 3'b000; //� type
                reg_write_r <= 1;
                branch_r <= 0;
                ALU_op_r <= 2'b10; //Alu operasyolar� i�in ama lw, sw, veya branch_rler yok
                jump_r <= 0;
                wstrb_r <= 4'b1111;
                pc_in_sel_r <= 0;
                wstrb_r_load <= 4'b1111;
            end
            AUIPC: begin
                Res_src_r <= 2'b11;
                mem_write_r <= 0;
                ALU_src_r <= 1'b0;
                Imm_src_r <= 3'b100;
                reg_write_r <= 1;
                branch_r <= 0;
                ALU_op_r <= 2'b00; //xx asl�nda kullanmicam 
                jump_r <= 0;
                wstrb_r <= 4'b1111;
                wstrb_r_load <= 4'b1111;
                pc_in_sel_r <= 0;
            end
            LUI: begin
                Res_src_r <= 2'b00;
                mem_write_r <= 0; 
                ALU_src_r <= 1'b1;
                Imm_src_r <= 3'b101;
                reg_write_r <= 1;
                branch_r <= 0;
                ALU_op_r <= 2'b10; //aluya gidiyo for toplama 
                jump_r <= 0;
                wstrb_r <= 4'b1111;
                wstrb_r_load <= 4'b1111;
                pc_in_sel_r <= 0;
            end
            STORE: begin
                Res_src_r <= 2'b00;
                mem_write_r <= 1;
                // u_s <=  
                ALU_src_r <= 1;
                Imm_src_r <= 3'b001;
                reg_write_r <= 0;
                branch_r <= 0;
                ALU_op_r <= 2'b00; //alu store
                jump_r <= 0;
                pc_in_sel_r <= 0;
                wstrb_r_load <= 4'b1111;
                if (func3 == 000)
                    wstrb_r <= 4'b0001;
                else if (func3 == 001)
                    wstrb_r <= 4'b0011;
                else if (func3 == 010)
                    wstrb_r <= 4'b1111;
                else
                    wstrb_r <= 4'b1111;
            end
            ALU: begin
                Res_src_r <= 2'b00;
                mem_write_r <= 0;
                pc_in_sel_r <= 0;
                // u_s <=  
                ALU_src_r <= 0;
                Imm_src_r <= 3'b000; //3'bxxx asl�nda kullanmicam ��nk�
                reg_write_r <= 1; 
                branch_r <= 0;
                ALU_op_r <= 2'b10; //alu
                jump_r <= 0;
                wstrb_r <= 4'b1111;
                wstrb_r_load <= 4'b1111;
            end
            BRANCH_OP : begin
                Res_src_r <= 2'b00; //
                mem_write_r <= 0;
                pc_in_sel_r <= 0;
                // u_s <=  
                ALU_src_r <= 0;
                Imm_src_r <= 3'b010;
                reg_write_r <= 0;
                branch_r <= 1;
                ALU_op_r <= 2'b01; //alu branch_res ama unsigned i�in bi�eyler g�ndercem ve smaller ya da grater i�in bular� d���n
                jump_r <= 0;
                wstrb_r <= 4'b1111;
                wstrb_r_load <= 4'b1111;
            end
            JALR : begin
                Res_src_r <= 2'b10;
                mem_write_r <= 0;
                pc_in_sel_r <= 1;
                // u_s <=  
                ALU_src_r <= 1;
                Imm_src_r <= 3'b000;
                reg_write_r <= 1;
                branch_r <= 0;
                ALU_op_r <= 2'b10;
                jump_r <= 1;
                wstrb_r <= 4'b1111;
                wstrb_r_load <= 4'b1111;
            end
            JAL : begin
                Res_src_r <= 2'b10;
                mem_write_r <= 0;
                pc_in_sel_r <= 0;
                // u_s <=  
                ALU_src_r <= 1'b0;
                Imm_src_r <= 3'b011;
                reg_write_r <= 1;
                branch_r <= 0;
                ALU_op_r <= 2'b10; //xx
                jump_r <= 1;
                wstrb_r <= 4'b1111;
                wstrb_r_load <= 4'b1111;
            end
            default : begin
                wstrb_r <= 4'b1111;
                wstrb_r_load <= 4'b1111;
                pc_in_sel_r <= 0;
            end
        endcase
    end
    
    assign  Res_src = Res_src_r;
    assign mem_write = mem_write_r;
    assign ALU_src = ALU_src_r;
    assign  Imm_src = Imm_src_r;
    assign reg_write = reg_write_r ;
    assign branch = branch_r;
    assign  wstrb = wstrb_r;
    assign  wstrb_load = wstrb_r_load;
    assign jump = jump_r;
    assign  ALU_op = ALU_op_r;
    assign pc_in_sel = pc_in_sel_r;
    
endmodule

module ALU_decoder (
    input [1:0] ALU_op,
    input [6:0] op_code,
    input [2:0] func3,
    input func7_5, 
    output reg [3:0] ALU_control,
    output reg u_s
);

    localparam [1:0] load_store = 2'b00, 
                     branch_r = 2'b01,
                     alu = 2'b10;

    always @(*) begin
        case (ALU_op)
            load_store: begin
                ALU_control = 4'b0000; //toplama for loadstroe
                if (func3[2] == 1)
                    u_s = 1;
                else 
                    u_s = 0;
            end
            branch_r : begin
                if (func3 == 3'b000) begin 
                    ALU_control = 4'b0101; //eq
                    u_s = 0;
                end
                if (func3 == 3'b001) begin 
                    ALU_control = 4'b0111; //neq
                    u_s = 0;
                end
                if (func3 == 3'b100) begin 
                    ALU_control = 4'b1001; //smaller
                    u_s = 0;
                end
                if (func3 == 3'b101) begin 
                    ALU_control = 4'b1011; //grater
                    u_s = 0;
                end
                if (func3 == 3'b110) begin 
                    ALU_control = 4'b1001; //smaller unsigned
                    u_s = 1;
                end
                if (func3 == 3'b111) begin 
                    ALU_control = 4'b1011; //grater unsigned
                    u_s = 1;
                end
            end
            alu : begin
                if (((func3 == 3'b000) && (({op_code[5], func7_5} == 2'b00) || ({op_code[5], func7_5} == 2'b01) || ({op_code[5], func7_5} == 2'b10))))  begin
                    u_s = 0; 
                    ALU_control = 4'b0000; //toplama
                end
                if (op_code == 7'b0110111)  begin
                    u_s = 0; 
                    ALU_control = 4'b1110; //toplama for lui
                end
                if ((func3 == 3'b000) && ({op_code[5], func7_5} == 2'b11))  begin
                    ALU_control = 4'b0001; //��karma
                    u_s = 0;
                end
                if (func3 == 3'b011) begin 
                    ALU_control = 4'b0011; //sltu
                    u_s = 1;
                end
                if ((func3 == 3'b010))  begin
                    ALU_control = 4'b0011; //slt
                    u_s = 0;
                end
                if ((func3 == 3'b110))  begin
                    ALU_control = 4'b1100; //or
                    u_s = 0;
                end
                if ((func3 == 3'b111))  begin
                    ALU_control = 4'b1000; //and
                    u_s = 0;
                end
                if ((func3 == 3'b100))  begin
                    ALU_control = 4'b1010; //xor
                    u_s = 0;
                end
                if (func3 == 3'b001 && ({op_code[5], func7_5} == 2'b10))  begin
                    ALU_control = 4'b0010; //sll
                    u_s = 0;
                end
                if (func3 == 3'b001 && ({op_code[5], func7_5} == 2'b00))  begin
                    ALU_control = 4'b0010; //slli
                    u_s = 0;
                end
                if (func3 == 3'b101 && ({op_code[5], func7_5} == 2'b00))  begin
                    ALU_control = 4'b0100; //srli
                    u_s = 0;
                end
                if (func3 == 3'b101 && ({op_code[5], func7_5} == 2'b10))  begin
                    ALU_control = 4'b0100; //srl
                    u_s = 0;
                end
                if (func3 == 3'b101 && ({op_code[5], func7_5} == 2'b01))  begin
                    ALU_control = 4'b0110; //srai
                    u_s = 0;
                end
                if (func3 == 3'b101 && ({op_code[5], func7_5} == 2'b11))  begin
                    ALU_control = 4'b0110; //sra
                    u_s = 0;
                end
            end
        endcase
    
    
    end
endmodule
