`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer:        Adrian Sacks 
// Create Date:     05/25/2022 09:16:15 PM
// Module Name:     PRNG
// Project Name:    CoinCollector 
// Description:     Using LFSR (Linear Feedback Shift Register) for 
//                  pseudo random generation of numbers for x and/or y 
//                  coordinates of sprites.
// Revision 0.01 -  File Created 
//////////////////////////////////////////////////////////////////////////////////

// NOTE: FLOOR is the top of the bottom blocks in the display. 
//       FLOOR = (vDisp - BlockHEIGHT)

module PRNG
    #(  parameter hDisp = 640,
        parameter vDisp = 480,
        parameter FLOOR = 450
     )
     (  input            clk,                // 100 MHz
        input            clkFIFOread,        // 25 MHz
        input            rst,
        input            thwompNewLocation,  // Read enable of asynchronous FIFO 
        output  [1:10]   prng_yBill,
        output  [1:10]   prng_xThwomp,
        output  [1:10]   prng_xShell,
        output  [1:10]   prng_xCoin,
        output  [1:10]   prng_yCoin,
        output  [1:10]   prng_xDragonCoin,
        output  [1:10]   prng_yDragonCoin,
        output  [1:0]    FIFOempty_full      
    );
// Dimensions of sprites 
localparam ThwompWIDTH  = 24;
localparam ThwompHEIGHT = 32; 

localparam BillWIDTH  = 64;
localparam BillHEIGHT = 64;

localparam ShellWIDTH  = 16;
localparam ShellHEIGHT = 16; 

localparam CoinWIDTH  = 12;
localparam CoinHEIGHT = 16;

localparam DragonCoinWIDTH  = 17;
localparam DragonCoinHEIGHT = 26;

/** ----------------------------------------------------------         
        Using LFSR (Linear Feedback Shift Register) for 
        pseudo random generation of numbers for x and/or y 
        coordinates of sprites. 
    ---------------------------------------------------------- **/

// Output of LFSRs
wire [1:50] LFSR1;
wire [1:20] LFSR2; 
    
LFSR NumberGenerator 
    (
        .clk(clk),
        .rst(rst),
        .Q1(LFSR1),
        .Q2(LFSR2) 
    );

// Thwomp coordinates will be stored in a FIFO and read only when Thwomp
// reaches the floor.

// I/O data of FIFO
wire [1:10] FIFOin = LFSR1[11:20];
wire [1:10] FIFOout;

FIFOv2 
    #(  .WIDTH(10),
        .DEPTH(16)
     )
     (
        .clk1(clk), 
        .clk2(clkFIFOread),
        .rst(rst),
        .i_wren(1),
        .i_wrdata(FIFOin),
        .o_full(FIFOempty_full[0]),
        .i_rden(thwompNewLocation),
        .o_rddata(FIFOout),
        .o_empty(FIFOempty_full[1])
    );
       
// Is pseudo-random number within bounds of display 

// Tap into LFSR output in 10-bit increments 
wire [1:10] RNG_Bill        = LFSR1[1:10];
wire [1:10] RNG_Thwomp      = FIFOout;
wire [1:10] RNG_xCoin       = LFSR1[31:40]; 
wire [1:10] RNG_yCoin       = LFSR2[1:10];
wire [1:10] RNG_Shell       = LFSR1[21:30];  
wire [1:10] RNG_xDragonCoin = LFSR1[41:50];
wire [1:10] RNG_yDragonCoin = LFSR2[11:20];  

// Interally register the PRNG 
reg [1:10]  prng_yBill_tmp;
reg [1:10]  prng_xThwomp_tmp;
reg [1:10]  prng_xShell_tmp;
reg [1:10]  prng_xCoin_tmp;
reg [1:10]  prng_yCoin_tmp;
reg [1:10]  prng_xDragonCoin_tmp;
reg [1:10]  prng_yDragonCoin_tmp;

    always @(RNG_Bill, RNG_Thwomp, RNG_Shell, RNG_xCoin, RNG_yCoin, RNG_xDragonCoin, RNG_yDragonCoin)
        begin
            if(RNG_Bill > FLOOR - BillHEIGHT)       prng_yBill_tmp   = (RNG_Bill)%(FLOOR - BillHEIGHT); 
            else                                    prng_yBill_tmp   = RNG_Bill;
            
            if(RNG_Thwomp > hDisp - ThwompWIDTH)    prng_xThwomp_tmp = (RNG_Thwomp)%(hDisp - ThwompWIDTH); 
            else                                    prng_xThwomp_tmp = RNG_Thwomp;
            
            if(RNG_Shell > hDisp - ShellWIDTH)      prng_xShell_tmp  = (RNG_Shell)%(hDisp - ShellWIDTH);
            else                                    prng_xShell_tmp  = RNG_Shell; 
            
            if(RNG_xCoin > hDisp - CoinWIDTH)       prng_xCoin_tmp = 5*CoinWIDTH;
            else if(RNG_xCoin < CoinWIDTH)          prng_xCoin_tmp = 10*CoinWIDTH;
            else                                    prng_xCoin_tmp = RNG_xCoin;
            
            if(RNG_yCoin > FLOOR - CoinHEIGHT)      prng_yCoin_tmp = 5*CoinHEIGHT;
            else if(RNG_yCoin < CoinHEIGHT)         prng_yCoin_tmp = FLOOR-10*CoinHEIGHT;
            else                                    prng_yCoin_tmp = RNG_yCoin;
            
            if(RNG_xDragonCoin > hDisp - DragonCoinWIDTH)  prng_xDragonCoin_tmp = 3*DragonCoinWIDTH;
            else if(RNG_xDragonCoin < DragonCoinWIDTH)     prng_xDragonCoin_tmp = 6*DragonCoinWIDTH;
            else                                           prng_xDragonCoin_tmp = RNG_xDragonCoin;
            
            if(RNG_yDragonCoin > FLOOR - DragonCoinHEIGHT) prng_yDragonCoin_tmp = 3*DragonCoinHEIGHT;
            else if(RNG_yDragonCoin < DragonCoinHEIGHT)    prng_yDragonCoin_tmp = FLOOR-3*DragonCoinHEIGHT;
            else                                           prng_yDragonCoin_tmp = RNG_yDragonCoin;      
        end
        
// Continuously Assign Outputs
assign prng_yBill        = prng_yBill_tmp;
assign prng_xThwomp      = prng_xThwomp_tmp; 
assign prng_xShell       = prng_xShell_tmp;
assign prng_xCoin        = prng_xCoin_tmp;
assign prng_yCoin        = prng_yCoin_tmp;
assign prng_xDragonCoin  = prng_xDragonCoin_tmp; 
assign prng_yDragonCoin  = prng_yDragonCoin_tmp;      
     
endmodule