`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer:        Adrian Sacks
// Create Date:     05/24/2022 02:14:08 PM
// Module Name:     top
// Project Name:    CoinCollector
// Description:     Combines all modules in the system.
// 
// Revision 0.01 -  File Created
//////////////////////////////////////////////////////////////////////////////////

module top
    (
        input         MainClk,
        input         rst,
        input   [1:0] SpeedOfPlayer,
        input   [1:0] SpeedOfThwomp,
        input         SpeedOfBill,
        input         SpeedOfShell,
        input         UARTin,
        output        UARTout,
        output        FIFOfull,
        output        FIFOempty,
        output        vga_horiz_pulse,
        output        vga_vert_pulse,
        output  [3:0] vga_red,
        output  [3:0] vga_green,
        output  [3:0] vga_blue,
        output        rPWM, 
        output        gPWM,
        output        bPWM,
        output  [6:0] Cnode,
        output  [7:0] AN,
        output        dp
    );

localparam sysF     = 100_000_000;
localparam baudRate = 9_600;

// ASCII value of key pressed on keyboard
wire [7:0] w_key; 
wire       w_rxDone; 

UARTrx 
    #(.CLKS_PER_BIT(sysF/baudRate))
keyboard
    (   .clk(MainClk),
        .serialData(UARTin),
        .rxDone(w_rxDone),
        .rxByte(w_key)
    );

UARTtx
    #(.CLKS_PER_BIT(sysF/baudRate))
outputToEmulator
    (   .clk(MainClk),
        .i_Tx_DV(w_rxDone),
        .inByte(w_key),
        .txActive(),
        .tx_serialOut(UARTout),
        .txDone()
    );

// Linear-Feedback Shift Register Sizes
wire [1:50] w_lfsr1;
wire [1:20] w_lfsr2;

// Horizontal timing 
localparam hDisp  = 640;
localparam hFp    = 16;
localparam hPulse = 96;
localparam hBp    = 48;

// Vertical timing 
localparam vDisp  = 480;
localparam vFp    = 10;   
localparam vPulse = 2;
localparam vBp    = 29;

// Outputs of IP Clock Generator 
//wire clk_out_wiz;
wire clk_25MHz;
//wire lock;
Clk_Div PixelClock
    ( .clk_in(MainClk),
      .clk_out(clk_25MHz)
    ); 

// Outputs of VGAcore 
wire        w_video; 
wire [10:0] w_hc;
wire [10:0] w_vc;    

VGAcore
    #(  .hDisp(hDisp),
        .hFp(hFp),
        .hPulse(hPulse),
        .hBp(hBp),
        .vDisp(vDisp),
        .vFp(vFp),   
        .vPulse(vPulse),
        .vBp(vBp)
    )
VGADriver
    (   .pixClk(clk_25MHz),
        .rst(rst),
        .horiz_counter(w_hc),
        .vert_counter(w_vc),
        .horiz_sync_pulse(vga_horiz_pulse),
        .vert_sync_pulse(vga_vert_pulse),
        .video(w_video)
   );

// Outputs of PRNG to coordinates of mobs in GameDisplay module
wire [1:10] w_prng_Bill;
wire [1:10] w_prng_Thwomp;
wire [1:10] w_prng_Shell; 
wire [1:10] w_prng_xCoin;
wire [1:10] w_prng_yCoin;
wire [1:10] w_prng_xDragonCoin;
wire [1:10] w_prng_yDragonCoin;

// Output signal from GameDisplay module to PRNG; HIGH when Thwomp reaches FLOOR
wire w_thwompReady; 

PRNG 
    #(  .hDisp(hDisp),
        .vDisp(vDisp),
        .FLOOR(450)
     )
NumberGen
     (  .clk(MainClk),                      // 100 MHz
        .clkFIFOread(clk_25MHz),            // 25 MHz
        .rst(rst),
        .thwompNewLocation(w_thwompReady),  // Read enable of asynchronous FIFO 
        .prng_yBill(w_prng_Bill),
        .prng_xThwomp(w_prng_Thwomp),
        .prng_xShell(w_prng_Shell),
        .prng_xCoin(w_prng_xCoin),
        .prng_yCoin(w_prng_yCoin),
        .prng_xDragonCoin(w_prng_xDragonCoin),
        .prng_yDragonCoin(w_prng_yDragonCoin),
        .FIFOempty_full({FIFOempty, FIFOfull})      
    );

// Output signal from GameDisplay module to PlayerLifeRGB
wire        w_playerIsHit;
// Output signal from GameDisplay module to nDigitSevenSegDriver
wire [19:0] w_playerScore;

// Parameters for GameDisplay
localparam coin = 200; 
localparam dragoncoin = 1000; 
localparam winningScore = 10_000;

GameDisplay 
    #( .hDisp(hDisp),
       .vDisp(vDisp),
       .coinPoints(coin),
       .dragoncoinPoints(dragoncoin),
       .winScore(winningScore)
     )
ShowSprites
    (
        .clk(clk_25MHz),
        .rst(rst),
        .key(w_key),
        .playerspeed(SpeedOfPlayer),
        .thwompspeed(SpeedOfThwomp),
        .billspeed(SpeedOfBill),
        .shellspeed(SpeedOfShell),
        .prngYBill(w_prng_Bill),
        .prngXThwomp(w_prng_Thwomp),
        .prngXShell(w_prng_Shell),
        .prngXCoin(w_prng_xCoin),
        .prngYCoin(w_prng_yCoin),
        .prngXDragonCoin(w_prng_xDragonCoin),
        .prngYDragonCoin(w_prng_yDragonCoin),
        .display(w_video), 
        .hc(w_hc),
        .vc(w_vc),
        .thwompReady(w_thwompReady),
        .playerIsHit(w_playerIsHit),
        .playerScore(w_playerScore), 
        .red(vga_red),
        .green(vga_green),
        .blue(vga_blue) 
    ); 


PlayerLifeRGB Life
    (   .clk(clk_25MHz), 
        .rst(rst),
        .wasHit(w_playerIsHit),
        .greenPWM(gPWM),
        .bluePWM(bPWM),
        .redPWM(rPWM)
    );

// Number of Digits should be enough to hold the winning score value. 
localparam nDigit = 5;

nDigitSevenSegDriver 
    #( .numDigits(nDigit)
     )
SegmentDisplay
     (
        .clk(MainClk),
        .rst(rst),
        .en(1),
        .in(w_playerScore),
        .Cnode(Cnode),
        .dp(dp),
        .AN(AN)
     );
endmodule
