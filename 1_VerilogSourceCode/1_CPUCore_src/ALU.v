`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC ESLAB (Embeded System Lab)
// Engineer: Haojun Xia
// Create Date: 2019/02/08
// Design Name: RISCV-Pipline CPU
// Module Name: ALU
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: ALU unit of RISCV CPU
//////////////////////////////////////////////////////////////////////////////////
`define SLL  4'd0
    `define SRL  4'd1
    `define SRA  4'd2
    `define ADD  4'd3
    `define SUB  4'd4
    `define XOR  4'd5
    `define OR  4'd6
    `define AND  4'd7
    `define SLT  4'd8
    `define SLTU  4'd9
    `define LUI  4'd10

`include "Parameters.v"   
module ALU(
    input wire [31:0] Operand1,
    input wire [31:0] Operand2,
    input wire [3:0] AluContrl,
    output reg [31:0] AluOut
    );
    wire signed [31:0] a;
    wire signed [31:0] b;
    assign a = Operand1;
    assign b = Operand2;
always @(*) begin
    case(AluContrl)
    `SLL:AluOut<=Operand1<<Operand2[4:0];
    `SRL:AluOut<=Operand1>>Operand2[4:0];
    `SRA:AluOut<=($signed(Operand1))>>>Operand2[4:0];
    `ADD:AluOut<=Operand1+Operand2;
    `SUB:AluOut<=Operand1-Operand2;
    `XOR:AluOut<=Operand1^Operand2;
    `OR:AluOut<=Operand1|Operand2;
    `AND:AluOut<=Operand1&Operand2;
    `SLT:AluOut<=a<b?1:0;
    `SLTU:AluOut<=Operand1<Operand2?1:0;
    `LUI:AluOut<=Operand2;//AUIPC使用ADD
    default:AluOut <= 32'hxxxxxxxx;
    endcase
end

endmodule    

//功能和接口说明
	//ALU接受两个操作数，根据AluContrl的不同，进行不同的计算操作，将计算结果输出到AluOut
	//AluContrl的类型定义在Parameters.v中
//推荐格式：
    //case()
    //    `ADD:        AluOut<=Operand1 + Operand2; 
    //   	.......
    //    default:    AluOut <= 32'hxxxxxxxx;                          
    //endcase
//实验要求  
    //实现ALU模块