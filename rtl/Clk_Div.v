`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer:        Adrian Sacks
// Create Date:     05/24/2022 02:04:00 PM 
// Module Name:     Clk_Div
// Project Name:    CoinCollector
// Description:     Takes a 100 MHz system clock and reduces the
//                  frequency to 25 MHz in order to be used as the
//                  the pixel clock for VGA. 
//                  
// Revision 0.01 -  File Created
//////////////////////////////////////////////////////////////////////////////////

module Clk_Div
    (
        input  clk_in, 
        output clk_out
    );
    reg [1:0] counter; 
    always@(posedge clk_in)
        begin
            counter <= counter + 1'd1;
        end
    assign clk_out = counter[1]; 
endmodule
