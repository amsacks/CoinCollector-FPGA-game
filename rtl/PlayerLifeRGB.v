`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer:        Adrian Sacks
// Create Date:     05/15/2022 09:28:48 PM 
// Module Name:     PlayerLifeRGB
// Project Name:    CoinCollector
// Description:     Outputs Green at 3 lives; Yellow at 2 lives; Red at 1 life. 
// Revision 0.01 -  File Created
//////////////////////////////////////////////////////////////////////////////////

`define ThreeLives 2'b00
`define TwoLives   2'b01
`define OneLife    2'b10
`define Dead       2'b11

module PlayerLifeRGB
    (
        input       clk,
        input       rst, 
        input       wasHit, 
        output      greenPWM, bluePWM, redPWM
    );
    reg [3:0] RedDutyTmp, GreenDutyTmp, BlueDutyTmp; 
    reg       RedPWMTmp,  GreenPWMTmp,  BluePWMTmp;
    reg [2:0] SM_Life = `ThreeLives;
    always@(posedge clk or posedge rst)
        begin
            if(rst) 
                begin
                    RedPWMTmp    <= 0;
                    GreenPWMTmp  <= 0;
                    BluePWMTmp   <= 0;
                    RedDutyTmp   <= 0;
                    GreenDutyTmp <= 4'b1111; 
                    BlueDutyTmp  <= 0;
                    SM_Life <= 0;
                end 
            else 
                begin
                    case(SM_Life)
                    `ThreeLives:
                        begin
                            if(wasHit) 
                                begin
                                    GreenPWMTmp  <= 0;
                                    RedDutyTmp   <= 4'b1111;
                                    GreenDutyTmp <= 4'b1111; 
                                    SM_Life    <= `TwoLives;
                                end
                            else 
                                begin
                                    GreenDutyTmp <= GreenDutyTmp - 1'b1; 
                                    if(GreenDutyTmp == 0) GreenDutyTmp <= 4'b1111; 
                                    if(GreenDutyTmp > 0)  GreenPWMTmp <= 1;
                                    else GreenPWMTmp <= 0; 
                                end
                        end
                    `TwoLives:
                        begin
                            if(wasHit) 
                                begin
                                    RedPWMTmp    <= 0;
                                    GreenPWMTmp  <= 0;
                                    GreenDutyTmp <= 0; 
                                    RedDutyTmp   <= 4'b1111; 
                                    SM_Life      <= `OneLife;
                                end
                            else 
                                begin
                                    RedDutyTmp   <= RedDutyTmp   - 1'b1; 
                                    GreenDutyTmp <= GreenDutyTmp - 1'b1; 
                                    if(GreenDutyTmp == 0) GreenDutyTmp <= 4'b1111; 
                                    if(RedDutyTmp == 0)   RedDutyTmp   <= 4'b1111; 
                                    
                                    if(GreenDutyTmp > 0)  GreenPWMTmp <= 1;
                                    else GreenPWMTmp <= 0; 
                                    if(RedDutyTmp > 0)    RedPWMTmp <= 1;
                                    else RedPWMTmp <= 0; 
                                end
                        end
                    `OneLife:
                        begin
                            if(wasHit) 
                                begin
                                    RedPWMTmp    <= 0; 
                                    RedDutyTmp   <= 0; 
                                    SM_Life      <= `Dead;
                                end 
                             else 
                                begin
                                    RedDutyTmp   <= RedDutyTmp   - 1'b1; 
                                    if(RedDutyTmp == 0)   RedDutyTmp   <= 4'b1111; 
                                    if(RedDutyTmp > 0)    RedPWMTmp <= 1;
                                    else RedPWMTmp <= 0; 
                                end       
                        end
                     `Dead:
                        begin
                            RedPWMTmp   <= 0;
                            GreenPWMTmp <= 0; 
                            BluePWMTmp  <= 0;
                        end
                    endcase  
                end
        end
    assign greenPWM = GreenPWMTmp;
    assign redPWM   = RedPWMTmp;
    assign bluePWM  = BluePWMTmp;
endmodule