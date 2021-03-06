`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/07 15:22:20
// Design Name: 
// Module Name: hazard
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module hazard(
    //Fetch stage
    output stallF,
    
    //decode stage
    input [4:0] rsD, rtD,
    input branchD,
    output forwardAD, forwardBD,
    output stallD,

    //excute stage
    input [4:0] rsE, rtE,
    input [4:0] writeRegE,
    input regWriteE,
    input memToRegE,
    output [1:0] forwardAE, forwardBE,
    output flushE,

    //mem stage
    input [4:0] writeRegM,
    input regWriteM,
    input memToRegM,

    //write back stage
    input [4:0] writeRegW,
    input regWriteW
    );
    
    //数据冒险 R型指令，前推
    assign forwardAE = ((rsE!=0) && (rsE==writeRegM) && regWriteM) ? 2'b10 : 
                        ((rsE!=0) && (rsE==writeRegW) && regWriteW) ? 2'b01:
                        2'b00;
                    
    assign forwardBE = ((rtE!=0) && (rtE==writeRegM) && regWriteM) ? 2'b10 : 
                        ((rtE!=0) && (rtE==writeRegW) && regWriteW) ? 2'b01:
                        2'b00;

    //数据冒险 load指令的，前推并且阻塞一周期
    wire lwStall;
    assign lwStall = ((rsD==rtE) || (rtD==rtE)) && memToRegE;
    
    //结构冒险 beq指令, 前推阻塞一周期并且刷新
    assign forwardAD = (rsD!=0) && (rsD==writeRegM) && regWriteM;
    assign forwardBD = (rtD!=0) && (rtD==writeRegM) && regWriteM;

    wire branchStall;
    assign branchStall = (branchD && regWriteE && (writeRegE==rsD || writeRegE==rtD))
                        | (branchD && memToRegM && (writeRegM==rsD || writeRegM==rtD));
    
    // control output
    assign stallD = (lwStall | branchStall);
    assign stallF = (lwStall | branchStall);
    assign flushE = (lwStall | branchStall);
endmodule

