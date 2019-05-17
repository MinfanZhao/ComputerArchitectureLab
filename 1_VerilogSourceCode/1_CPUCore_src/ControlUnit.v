`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC ESLAB (Embeded System Lab)
// Engineer: Haojun Xia
// Create Date: 2019/02/08
// Design Name: RISCV-Pipline CPU
// Module Name: ControlUnit
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: RISC-V Instruction Decoder
//////////////////////////////////////////////////////////////////////////////////
`include "Parameters.v"   
module ControlUnit(
    input wire [6:0] Op,
    input wire [2:0] Fn3,
    input wire [6:0] Fn7,
    //output wire JalD,
    //output wire JalrD,
    output reg JalD,
    output reg JalrD,

    output reg [2:0] RegWriteD,
    //output wire MemToRegD,
    output reg MemToRegD,
    output reg [3:0] MemWriteD,
    //output wire LoadNpcD,
    output reg LoadNpcD,
    output reg [1:0] RegReadD,
    output reg [2:0] BranchTypeD,
    output reg [3:0] AluContrlD,
    //output wire [1:0] AluSrc2D,
    //output wire AluSrc1D,
    output reg [1:0] AluSrc2D,
    output reg AluSrc1D,

    output reg [2:0] ImmType        
    );

always @(*) begin
    case(Op[6:5])
        2'b00:begin//load
            case(Op[4:2])
                3'b000://Itype
                    begin
                        JalD<=0;
                        JalrD<=0;
                        case(Fn3)
                            3'b000: RegWriteD<= `LB;
                            3'b001:RegWriteD<= `LH ;
                            3'b010:RegWriteD<= `LW ;
                            3'b100:RegWriteD<= `LBU ;
                            3'b101:RegWriteD<= `LHU;
                            default:RegWriteD<= `NOREGWRITE;// TO SOLVE
                        endcase
                        MemToRegD<=1;
                        MemWriteD<=0;
                        LoadNpcD<=0;
                        RegReadD<=2'B10;//TO CONFIG
                        BranchTypeD<=`NOBRANCH;
                        AluContrlD<=`ADD;
                        AluSrc2D<=2'b10;
                        AluSrc1D<=0;
                        ImmType<=`ITYPE;
                    end  
               /* 3'b001://LOAD-FP
                    begin
                          JalD=0;
                          JalrD=0;
                        case(Fn3)
                            3'b000: RegWriteD<= LB;
                            3'b001:RegWriteD<= LH ;
                            3'b010:RegWriteD<= LW ;
                            3'b100:RegWriteD<= LBU ;
                            3'b101:RegWriteD<= LHU;
                            default:RegWriteD<= NOREGWRITE;// TO SOLVE
                        endcase
                          MemToRegD=1;
                        MemWriteD<=0;
                          LoadNpcD=0;
                        RegReadD<=2'B11;//TO CONFIG
                        BranchTypeD<=NOBRANCH;
                        AluContrlD<=ADD;
                          AluSrc2D=2'b10;
                          AluSrc1D=0;
                        ImmType<=ITYPE;
                    end  */
                //3'b010:CUSTOM-0
                //3'b011:MISC-MEM
                3'b100://OP-IMM
                    begin
                          JalD<=0;
                          JalrD<=0;
                        RegWriteD<=`LW;
                          MemToRegD<=0;
                        MemWriteD<=0;
                          LoadNpcD<=0;
                        RegReadD<=2'B10;//TO CONFIG
                        BranchTypeD<=`NOBRANCH;
                        case(Fn3)
                            3'b000: AluContrlD<= `ADD;
                            3'b001:AluContrlD<= `SLL ;
                            3'b010:AluContrlD<= `SLT ;
                            3'b100:AluContrlD<= `XOR ;
                            
                            3'B011:AluContrlD<=`SLTU;
                            3'B110:AluContrlD<=`OR;
                            3'B111:AluContrlD<=`AND;
                            3'B101:if(Fn7[5])
                                        AluContrlD<=`SRA;
                                    else begin
                                        AluContrlD<=`SRL;
                                    end
                            default:AluContrlD<= 4'd11;// TO SOLVE
                        endcase
                          AluSrc2D<=2'b10;
                          AluSrc1D<=0;
                        ImmType<=`ITYPE;
                    end  
                3'b101://AUIPC
                    begin
                          JalD<=0;
                          JalrD<=0;
                        RegWriteD<=`LW;
                          MemToRegD<=0;
                        MemWriteD<=0;
                          LoadNpcD<=0;
                        RegReadD<=2'B00;//TO CONFIG
                        BranchTypeD<=`NOBRANCH;
                        AluContrlD<=`ADD;
                          AluSrc2D<=2'b10;
                          AluSrc1D<=1;
                        ImmType<=`UTYPE;
                    end  
                //3'b110:OP-IMM-32
                default:;//TO SOLVE
            endcase
        end
        2'b01:begin//store
            case(Op[4:2])
                3'b000://store
                    begin
                          JalD<=0;
                          JalrD<=0;
                        RegWriteD<=`NOREGWRITE;
                          MemToRegD<=0;
                        case(Fn3)
                            3'b000:MemWriteD<=4'b0001;
                            3'b001:MemWriteD<=4'b0011;
                            3'b010:MemWriteD<=4'b1111;
                            default:;
                        endcase
                          LoadNpcD<=0;
                        RegReadD<=2'B11;//TO CONFIG
                        BranchTypeD<=`NOBRANCH;
                        AluContrlD<=`ADD;
                          AluSrc2D<=2'b10;
                          AluSrc1D<=0;
                        ImmType<=`STYPE;
                    end  
                //3'b001:
                //3'b010:
                //3'b011:
                3'b100://OP
                    begin
                          JalD<=0;
                          JalrD<=0;
                        RegWriteD<=`LW;
                          MemToRegD<=0;
                        MemWriteD<=0;
                          LoadNpcD<=0;
                        RegReadD<=2'B11;//TO CONFIG
                        BranchTypeD<=`NOBRANCH;
                        case(Fn3)
                            3'b000:if(!Fn7[5])
                                        AluContrlD<= `ADD;
                                    else 
                                        AluContrlD<=`SUB;
                            3'b001:AluContrlD<= `SLL ;
                            3'b010:AluContrlD<= `SLT ;
                            3'b100:AluContrlD<= `XOR ;
                            
                            3'B011:AluContrlD<=`SLTU;
                            3'B110:AluContrlD<=`OR;
                            3'B111:AluContrlD<=`AND;
                            3'B101:if(Fn7[5])
                                        AluContrlD<=`SRA;
                                    else begin
                                        AluContrlD<=`SRL;
                                    end
                            default:AluContrlD<= 4'd11;// TO SOLVE
                        endcase
                          AluSrc2D<=2'b00;
                          AluSrc1D<=0;
                        ImmType<=`RTYPE;
                    end  
                3'b101://LUI
                    begin
                          JalD<=0;
                          JalrD<=0;
                        RegWriteD<=`LW;
                          MemToRegD<=0;
                        MemWriteD<=0;
                          LoadNpcD<=0;
                        RegReadD<=2'B00;//TO CONFIG
                        BranchTypeD<=`NOBRANCH;
                        AluContrlD<=`LUI;
                          AluSrc2D<=2'b10;
                          AluSrc1D<=1;
                        ImmType<=`UTYPE;
                    end  
                //3'b110:
                default:;
            endcase
        end
      /* 2'b10:begin//madd
            case(Op[4:2])
                3'b000:
                3'b001:
                3'b010:
                3'b011:
                3'b100:
                3'b101:
                3'b110:
                default:
            endcase
        end*/
        2'b11:begin//branch
            case(Op[4:2])
                3'b000://BRANCH
                     begin
                          JalD<=0;
                          JalrD<=0;
                        RegWriteD<=`NOREGWRITE;
                          MemToRegD<=0;
                        MemWriteD<=0;
                          LoadNpcD<=0;
                        RegReadD<=2'B11;//TO CONFIG
                        case(Fn3)
                            3'B000:BranchTypeD<=`BEQ;
                            3'B001:BranchTypeD<=`BNE;
                            3'B100:BranchTypeD<=`BLT;
                            3'B110:BranchTypeD<=`BLTU;
                            3'B101:BranchTypeD<=`BGE;
                            3'B111:BranchTypeD<=`BGEU;
                            default:BranchTypeD<=`NOBRANCH;
                        endcase
                        AluContrlD<=4'd11;
                          AluSrc2D<=2'b00;
                          AluSrc1D<=0;
                        ImmType<=`BTYPE;
                    end  
                3'b001://JALR
                     begin
                          JalD<=0;
                          JalrD<=1;
                        RegWriteD<=`LW;
                          MemToRegD<=0;
                        MemWriteD<=0;
                          LoadNpcD<=1;
                        RegReadD<=2'B10;//TO CONFIG
                        BranchTypeD<=`NOBRANCH;
                        AluContrlD<=`ADD;
                          AluSrc2D<=2'b10;
                          AluSrc1D<=0;
                        ImmType<=`ITYPE;
                    end 
               // 3'b010:
                3'b011://JAL
                    begin
                          JalD<=1;
                          JalrD<=0;
                        RegWriteD<=`LW;
                          MemToRegD<=0;
                        MemWriteD<=0;
                          LoadNpcD<=1;
                        RegReadD<=2'B00;//TO CONFIG
                        BranchTypeD<=`NOBRANCH;
                        AluContrlD<=4'd11;
                          AluSrc2D<=2'b10;
                          AluSrc1D<=1;
                        ImmType<=`JTYPE;
                    end 
               // 3'b100:
               // 3'b101:
               // 3'b110:
                default:;
            endcase
        end
        default:begin
            JalD<=0;
            JalrD<=0;
            RegWriteD<=`LW;
            MemToRegD<=1'bx;
            MemWriteD<=1'bx;
            LoadNpcD<=1'bx;
            RegReadD<=2'B00;//TO CONFIG
            BranchTypeD<=`NOBRANCH;
            AluContrlD<=4'd11;
            AluSrc2D<=2'bx;
            AluSrc1D<=1'bx;
            ImmType<=3'd6;
        end
    endcase

end





endmodule

//功能说明
    //ControlUnit       是本CPU的指令译码器，组合逻辑电路
//输入
    // Op               是指令的操作码部分
    // Fn3              是指令的func3部分
    // Fn7              是指令的func7部分
//输出
    // JalD==1          表示Jal指令到达ID译码阶段
    // JalrD==1         表示Jalr指令到达ID译码阶段
    // RegWriteD        表示ID阶段的指令对应的 寄存器写入模式 ，所有模式定义在Parameters.v中
    // MemToRegD==1     表示ID阶段的指令需要将data memory读取的值写入寄存器,
    // MemWriteD        共4bit，采用独热码格式，对于data memory的32bit字按byte进行写入,MemWriteD=0001表示只写入最低1个byte，和xilinx bram的接口类似
    // LoadNpcD==1      表示将NextPC输出到ResultM
    // RegReadD[1]==1   表示A1对应的寄存器值被使用到了，RegReadD[0]==1表示A2对应的寄存器值被使用到了，用于forward的处理
    // BranchTypeD      表示不同的分支类型，所有类型定义在Parameters.v中
    // AluContrlD       表示不同的ALU计算功能，所有类型定义在Parameters.v中
    // AluSrc2D         表示Alu输入源2的选择
    // AluSrc1D         表示Alu输入源1的选择
    // ImmType          表示指令的立即数格式，所有类型定义在Parameters.v中   
//实验要求  
    //实现ControlUnit模块   