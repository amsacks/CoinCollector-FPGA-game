`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer:        Adrian Sacks
// Create Date:     05/25/2022 08:11:59 PM 
// Module Name:     LFSR
// Project Name:    CoinCollector   
// Description:     LFSR (Linear-Feedback Shift Register) is used as a 
//                  pseudorandom number generator for the x and/or y 
//                  coordinates of sprite's spawn location in the
//                  640 x 480 display area. 
// Revision 0.01 -  File Created
//////////////////////////////////////////////////////////////////////////////////

module LFSR
    (
        input             clk,
        input             rst,
        output reg [49:0] Q1,
        output reg [19:0] Q2
    );
    
    // Taps for a 50-bit long LFSR: 50, 49, 24, 23 
    // Taps for a 20-bit long LFSR: 20, 17
    
    wire feedback1 = ~(Q1[49] ^ Q1[48] ^ Q1[23] ^ Q1[22]);
    wire feedback2 = ~(Q2[19] ^ Q2[16]);
    
    always @(posedge clk or posedge rst)
        begin
            if(rst)
                begin
                    Q1 <= 50'b0;
                    Q2 <= 20'b0; 
                end
            else begin
                Q1 <= {Q1[48:0], feedback1};
                Q2 <= {Q2[18:0], feedback2};
            end  
        end  
endmodule