`timescale 1ns / 1ps

// Description:     Displays all sprites in the CoinCollector game and does game logic.

// ASCII value of the 'w', 's', 'a', 'd' keys. 
// NOTE: They must be lowercase. 
`define UP     8'h77       // Up    (w)
`define DOWN   8'h73       // Down  (s)
`define LEFT   8'h61       // Left  (a)
`define RIGHT  8'h64       // Right (d)

module GameDisplay
    #( parameter hDisp = 640,
       parameter vDisp = 480,
       parameter coinPoints = 200,
       parameter dragoncoinPoints = 1000,
       parameter winScore = 10000
     ) 
     ( input             clk,           // 25 MHz
       input             rst, 
       input      [7:0]  key, 
       input      [1:0]  playerspeed,
       input      [1:0]  thwompspeed, 
       input             billspeed,
       input             shellspeed, 
       input      [1:10] prngYBill,
       input      [1:10] prngXThwomp,
       input      [1:10] prngXShell,
       input      [1:10] prngXCoin,
       input      [1:10] prngYCoin,
       input      [1:10] prngXDragonCoin,
       input      [1:10] prngYDragonCoin,
       input             display, 
       input      [10:0] hc,
       input      [10:0] vc,
       output            thwompReady, 
       output reg        playerIsHit,
       output     [19:0] playerScore, 
       output reg [3:0]  red,
       output reg [3:0]  green,
       output reg [3:0]  blue
      );
      
// Width of horizontal column
localparam hCol = hDisp/8;
// Width of vertical row
localparam vRow = vDisp/8;


// Dimensions of sprites
localparam PlayerWIDTH  = 42;
localparam PlayerHEIGHT = 32;

localparam BlockWIDTH  = 31;
localparam BlockHEIGHT = 30; 

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

// Location of bottom platform
localparam FLOOR = vDisp - BlockHEIGHT;

//  Game State
reg        gameOver = 1'b0;   // Could be win or lose when HIGH 
reg [13:0] playerScore_tmp;

// x,y position of sprites
reg      [10:0] xPos;
reg      [10:0] yPos;
reg      [10:0] xThwomp1;
reg      [10:0] yThwomp1;
reg      [10:0] xThwomp2;
reg      [10:0] yThwomp2;
reg      [10:0] xBill;
reg      [10:0] yBill; 
reg      [10:0] xShell;
reg      [10:0] yShell;
reg      [10:0] xCoin;
reg      [10:0] yCoin;
reg      [10:0] xDragonCoin;
reg      [10:0] yDragonCoin;

// Active HIGH spawn mob
reg             billSpawn;      
reg             shellSpawn;     
reg             dragoncoinSpawn; 

// Pixel addresses of sprites
wire [10:0] PlayerAddress; 
wire [9:0]  Thwomp1Address;
wire [9:0]  Thwomp2Address;
wire [11:0] BillAddress;
wire [7:0]  ShellAddress;
wire [7:0]  CoinAddress;
wire [8:0]  DragonCoinAddress;
wire [9:0]  BlockAddress;

// 12-bit pixel data of sprites
wire [11:0] PlayerPixel;
wire [11:0] Thwomp1Pixel;
wire [11:0] Thwomp2Pixel;
wire [11:0] BillPixel;
wire [11:0] ShellPixel;
wire [11:0] CoinPixel;
wire [11:0] DragonCoinPixel;
wire [11:0] BlockPixel; 

// Generation of Sprites using IP ROM Blocks
blk_mem_gen_0 Player
    (
        .addra(PlayerAddress),
        .clka(clk),
        .douta(PlayerPixel)
    );

blk_mem_gen_1 Thwomp1
    (
        .addra(Thwomp1Address),
        .clka(clk),
        .douta(Thwomp1Pixel)
    );

blk_mem_gen_8 Thwomp2
    (
        .addra(Thwomp2Address),
        .clka(clk),
        .douta(Thwomp2Pixel)
    );


blk_mem_gen_3 Bill
    (
        .addra(BillAddress),
        .clka(clk),
        .douta(BillPixel)
    );

blk_mem_gen_4 Shell
    (
        .addra(ShellAddress),
        .clka(clk),
        .douta(ShellPixel)
    );

blk_mem_gen_5 Coin
    (
        .addra(CoinAddress),
        .clka(clk),
        .douta(CoinPixel)
    );

blk_mem_gen_6 DragonCoin
    (
        .addra(DragonCoinAddress),
        .clka(clk),
        .douta(DragonCoinPixel)
    );

blk_mem_gen_7 BottomBlock
    (
        .addra(BlockAddress),
        .clka(clk),
        .douta(BlockPixel)
    );

// Address the ROM blocks according to sprite's position on the screen
assign PlayerAddress     = (hc - xPos)     + (vc - yPos)*PlayerWIDTH;
assign Thwomp1Address    = (hc - xThwomp1) + (vc - yThwomp1)*ThwompWIDTH;
assign Thwomp2Address    = (hc - xThwomp2) + (vc - yThwomp2)*ThwompWIDTH;
assign BillAddress       = (hc - xBill)    + (vc - yBill)*BillWIDTH;
assign ShellAddress      = (hc - xShell)   + (vc - yShell)*ShellWIDTH;
assign CoinAddress       = (hc - xCoin)    + (vc - yCoin)*CoinWIDTH;
assign DragonCoinAddress = (hc - xDragonCoin) + (vc - yDragonCoin)*DragonCoinWIDTH;
assign BlockAddress      =  hc             + (vc - (vDisp - BlockHEIGHT))*BlockWIDTH;

    always @(posedge clk)
        begin
            if(playerScore_tmp >= winScore)     // Win the game
                begin
                    if((vc <= vRow - 1)) 
                        begin
                            red   <= 4'h0;
                            green <= 4'h0;
                            blue  <= 4'h0;
                        end 
                    else if(vc <= (2*vRow - 1)) 
                        begin
                            red   <= 4'h0;
                            green <= 4'h0;
                            blue  <= 4'hF;
                        end
                    else if(vc <= (3*vRow - 1)) 
                        begin
                            red   <= 4'h0;
                            green <= 4'hF;
                            blue  <= 4'h0;
                        end 
                    else if(vc <= (4*vRow - 1)) 
                        begin
                            red   <= 4'h0;
                            green <= 4'hF;
                            blue  <= 4'hF;
                        end 
                    else if(vc <= (5*vRow - 1)) 
                        begin
                            red   <= 4'hF;
                            green <= 4'h0;
                            blue  <= 4'h0;
                        end 
                    else if(vc <= (6*vRow - 1)) 
                        begin
                            red   <= 4'hF;
                            green <= 4'h0;
                            blue  <= 4'hF;
                        end 
                    else if(vc <= (7*vRow - 1)) 
                        begin
                            red   <= 4'hF;
                            green <= 4'hF;
                            blue  <= 4'h0;
                        end
                    else if(vc <= (8*vRow - 1)) 
                        begin
                            red   <= 4'hF;
                            green <= 4'hF;
                            blue  <= 4'hF;
                        end
                end
            else 
                begin
                    if(display && (gameOver == 0)) 
                        begin
                            // Display Player
                            if((hc >= xPos && hc <= PlayerWIDTH + xPos) && 
                                (vc >= yPos && vc <= PlayerHEIGHT + yPos))
                                begin
                                    red   <= PlayerPixel[11:8];
                                    green <= PlayerPixel[7:4]; 
                                    blue  <= PlayerPixel[3:0];
                                end
                            // Display Thwomp1
                            else if((hc >= xThwomp1 && hc <= xThwomp1 + ThwompWIDTH) && 
                                     (vc >= yThwomp1 && vc <= ThwompHEIGHT + yThwomp1))
                                begin
                                    red   <= Thwomp1Pixel[11:8];
                                    green <= Thwomp1Pixel[7:4]; 
                                    blue  <= Thwomp1Pixel[3:0];
                                end
                            // Display Thwomp2
                            else if((hc >= xThwomp2 && hc <= xThwomp2 + ThwompWIDTH) && 
                                     (vc >= yThwomp2 && vc <= ThwompHEIGHT + yThwomp2))
                                begin
                                    red   <= Thwomp2Pixel[11:8];
                                    green <= Thwomp2Pixel[7:4]; 
                                    blue  <= Thwomp2Pixel[3:0];
                                end
                            // Display Banzai Bill
                            else if (billSpawn && ((hc >= xBill && hc <= xBill + BillWIDTH) && 
                                     (vc >= yBill && vc <= BillHEIGHT + yBill)))
                                begin
                                    red   <= BillPixel[11:8];
                                    green <= BillPixel[7:4];
                                    blue  <= BillPixel[3:0]; 
                                end
                            // Display Blue Shell
                            else if (shellSpawn && ((hc >= xShell && hc <= xShell + ShellWIDTH) && 
                                     (vc >= yShell && vc <= yShell + ShellHEIGHT)))
                                begin
                                    red   <= ShellPixel[11:8];
                                    green <= ShellPixel[7:4];
                                    blue  <= ShellPixel[3:0]; 
                                end
                            // Display Coin
                            else if ((hc >= xCoin && hc <= xCoin + CoinWIDTH) && 
                                     (vc >= yCoin && vc <= yCoin + CoinHEIGHT))
                                begin
                                    red   <= CoinPixel[11:8];
                                    green <= CoinPixel[7:4];
                                    blue  <= CoinPixel[3:0]; 
                                end
                            // Display Dragon Coin
                            else if (dragoncoinSpawn && ((hc >= xDragonCoin && hc <= xDragonCoin + DragonCoinWIDTH) && 
                                     (vc >= yDragonCoin && vc <= yDragonCoin + DragonCoinHEIGHT)))
                                begin
                                        red   <= DragonCoinPixel[11:8];
                                        green <= DragonCoinPixel[7:4];
                                        blue  <= DragonCoinPixel[3:0]; 
                                end 
                            // Display Bottom Platform 
                            else if((vc >= vDisp - BlockHEIGHT && vc <= vDisp))
                                begin
                                    red   <= BlockPixel[11:8];
                                    green <= BlockPixel[7:4]; 
                                    blue  <= BlockPixel[3:0];
                                end
                            // Display black background
                            else 
                                begin
                                    red   <= 0;
                                    green <= 0;
                                    blue  <= 0;
                                end
                        end 
                    else 
                        begin
                            if(hc <= (hCol - 1)) 
                                begin
                                    red   <= 4'h0;
                                    green <= 4'h0;
                                    blue  <= 4'h0;
                                end 
                            else if(hc <= (2*hCol - 1)) 
                                begin
                                    red   <= 4'h0;
                                    green <= 4'h0;
                                    blue  <= 4'hF;
                                end
                            else if(hc <= (3*hCol - 1)) 
                                begin
                                    red   <= 4'h0;
                                    green <= 4'hF;
                                    blue  <= 4'h0;
                                end
                            else if(hc <= (4*hCol - 1)) 
                                begin
                                    red   <= 4'h0;
                                    green <= 4'hF;
                                    blue  <= 4'hF;
                                end 
                            else if(hc <= (5*hCol - 1)) 
                                begin
                                    red   <= 4'hF;
                                    green <= 4'h0;
                                    blue  <= 4'h0;
                                end
                            else if(hc <= (6*hCol - 1)) 
                                begin
                                    red   <= 4'hF;
                                    green <= 4'h0;
                                    blue  <= 4'hF;
                                end 
                            else if(hc <= (7*hCol - 1)) 
                                begin
                                    red   <= 4'hF;
                                    green <= 4'hF;
                                    blue  <= 4'h0;
                                end
                            else if(hc <= (8*hCol - 1)) 
                                begin
                                    red   <= 4'hF;
                                    green <= 4'hF;
                                    blue  <= 4'hF;
                                end
                       end                        
              end   // else (playerScore <=   winScore)  
        end // End of always block

/** ----------------------------------------------------------         
        PLAYER:
        
        1st: -Based off keyboard inputs, change the position of the
             player accordingly. 
        
        2nd: Check whether the player collides with a coin.
             -Increment points depending on the coin.
             -If score > winning score, win = 1. else win = 0
             -Convert score from binary to BCD
        
        3rd: -Check whether the player collides with a mob.
             Lose a life if TRUE. If lives = 0, game over. 
    ---------------------------------------------------------- **/

/** 1st **/ 
reg [21:0]         counter; 
wire PlayerFrame = counter[19-playerspeed];
    always @(posedge clk)   
        begin
            if(rst) counter <= 0;
            counter <= counter+1;
        end
        
    // Player Direction Control 
    reg [2:0] Direction; 
    always @(posedge clk)                             
    begin
        if(rst) begin Direction <= 4; end
        else begin
              if(display)
                case(key)
                    `UP:     begin Direction <= 0; end 
                    `DOWN:   begin Direction <= 1; end
                    `LEFT:   begin Direction <= 2; end
                    `RIGHT:  begin Direction <= 3; end
                    default: begin Direction <= 4; end
                endcase
        end
    end

    always @(posedge PlayerFrame)
        begin
            if(rst)
                begin
                    xPos <= 300;
                    yPos <= 200;       
                end
            else
                if(!gameOver)
                case(Direction)
                    3'b000: begin   // UP
                                if(yPos < 1) yPos <= yPos;         // Cannot go UP anymore 
                                else yPos <= yPos - 1; 
                            end
                    3'b001: begin  // DOWN
                                if(yPos < (vDisp - BlockHEIGHT - PlayerHEIGHT)) yPos <= yPos + 1;
                                else if((yPos >= (vDisp - BlockHEIGHT - PlayerHEIGHT/2)) // Frog/block collision  
                                        && (yPos <= vDisp - BlockHEIGHT - PlayerHEIGHT)) yPos <= yPos;
                            end 
                    3'b010: begin  // LEFT
                                if(xPos < 1) xPos <= hDisp;
                                else xPos <= xPos - 1; 
                            end
                    3'b011: begin // RIGHT
                                if(xPos < hDisp + PlayerWIDTH) xPos <= xPos + 1; 
                                else xPos <= 0;
                            end
                    3'b100: begin // IDLE
                                xPos <= xPos; yPos <= yPos; 
                            end      
                    default: begin xPos <= 0; yPos <= 0; end
                    endcase
        end
        
/** 2nd **/
// Interaction between Coin and Player 
// State 0: Coin spawns in NEW location; player can gain points; starting state upon reset.
// State 1: Coin is collected by player; player cannot gain anymore points.
localparam FIVE_SECOND_DELAY = 125_000_000; 
reg [30:0] dragoncoinCount;  
reg        SM_Coin; 
// local registers for the always block and module
reg        dragoncoinCollected;
reg        dragoncoinNewLocation;
reg        coinCollected;
wire[13:0] Score;
        
// Output signal from BinToBCD 
wire [19:0] w_BCD;

BinToBCD CodeConverter
    ( .Binary(Score),
      .BCD(w_BCD)
    ); 

// Assign playerScore output.
assign playerScore =  w_BCD;
assign Score       =  playerScore_tmp;
    
     always@(posedge clk)
        begin
            if(rst) 
                begin
                    SM_Coin               <= 0;            
                    playerScore_tmp       <= 0;
                    xCoin                 <= 5*CoinWIDTH;
                    yCoin                 <= 5*CoinHEIGHT;
                    xDragonCoin           <= 5*DragonCoinWIDTH;
                    yDragonCoin           <= 5*DragonCoinHEIGHT;
                    dragoncoinSpawn       <= 1;                 // Show Display Dragon Coin at start of game 
                    dragoncoinCount       <= 0;
                    dragoncoinCollected   <= 0;
                    dragoncoinNewLocation <= 0; 
                    coinCollected         <= 0;
                end
            else begin
            if(dragoncoinNewLocation) begin
                 if(dragoncoinCount == FIVE_SECOND_DELAY - 1) begin
                        dragoncoinCount       <= 0;
                        dragoncoinNewLocation <= 0;
                        dragoncoinSpawn       <= 1;
                    end
                  else dragoncoinCount <= dragoncoinCount + 1'd1;        
            end
                case(SM_Coin)
                1'b0: begin: Display_Coin   
                    if((!coinCollected) && (!dragoncoinCollected)) SM_Coin <= 1;
                    if(dragoncoinCollected) begin
                            SM_Coin             <= 1;          // Move to State 1
                            dragoncoinSpawn     <= 0;          // Do not show Dragon coin immediately; wait for 5 second timer.
                            dragoncoinCollected <= 0; 
                            xDragonCoin         <= prngXDragonCoin;
                            yDragonCoin         <= prngYDragonCoin;
                        end   
                    if(coinCollected)      
                        begin
                            SM_Coin       <= 1;
                            coinCollected <= 0; 
                            xCoin         <= prngXCoin;
                            yCoin         <= prngYCoin;
                        end  
               end  // End State 0
               1'b1: begin: Collect_Coin
                // Coin order: Coin, Dragon Coin. 
                // Collision order: upper left, upper right, lower left, lower right.
                if(!gameOver) begin
                    if(((xPos <= xCoin + CoinWIDTH) && (xPos >= xCoin)) && 
                            ((yPos <= yCoin + CoinHEIGHT) && (yPos >= yCoin)))
                        begin
                            SM_Coin         <= 0;
                            playerScore_tmp <= playerScore_tmp + coinPoints;
                            coinCollected   <= 1;
                        end
                    else if(((xPos <= xCoin + CoinWIDTH - PlayerWIDTH) && (xPos >= xCoin - PlayerWIDTH)) && 
                            ((yPos <= yCoin + CoinHEIGHT) && (yPos >= yCoin)))
                        begin
                            SM_Coin         <= 0;
                            playerScore_tmp <= playerScore_tmp + coinPoints;
                            coinCollected   <= 1;
                        end
                    else if(((xPos <= xCoin + CoinWIDTH) && (xPos >= xCoin)) && 
                            ((yPos <= yCoin + CoinHEIGHT - PlayerHEIGHT) && (yPos >= yCoin - PlayerHEIGHT)))
                        begin
                            SM_Coin         <= 0;
                            playerScore_tmp <= playerScore_tmp + coinPoints;
                            coinCollected   <= 1;
                        end
                    else if(((xPos <= xCoin + CoinWIDTH - PlayerWIDTH) && (xPos >= xCoin - PlayerWIDTH)) && 
                            ((yPos <= yCoin + CoinHEIGHT - PlayerHEIGHT) && (yPos >= yCoin - PlayerHEIGHT)))
                        begin
                            SM_Coin            <= 0;
                            playerScore_tmp    <= playerScore_tmp + coinPoints;
                            coinCollected      <= 1;
                        end
       
                    if(((xPos <= xDragonCoin + DragonCoinWIDTH) && (xPos >= xDragonCoin)) && 
                            ((yPos <= yDragonCoin + DragonCoinHEIGHT) && (yPos >= yDragonCoin)))
                        begin
                            SM_Coin               <= 0;
                            playerScore_tmp       <= playerScore_tmp + dragoncoinPoints;
                            dragoncoinCollected   <= 1;
                            dragoncoinNewLocation <= 1; 
                        end
                    else if(((xPos <= xDragonCoin + DragonCoinWIDTH - PlayerWIDTH) && (xPos >= xDragonCoin - PlayerWIDTH)) && 
                            ((yPos <= yDragonCoin + DragonCoinHEIGHT) && (yPos >= yDragonCoin)))
                        begin
                            SM_Coin               <= 0;
                            playerScore_tmp       <= playerScore_tmp + dragoncoinPoints;
                            dragoncoinCollected   <= 1;
                            dragoncoinNewLocation <= 1; 
                        end
                    else if(((xPos <= xDragonCoin + DragonCoinWIDTH) && (xPos >= xDragonCoin)) && 
                            ((yPos <= yDragonCoin + DragonCoinHEIGHT - PlayerHEIGHT) && (yPos >= yDragonCoin - PlayerHEIGHT)))
                        begin
                            SM_Coin               <= 0;
                            playerScore_tmp       <= playerScore_tmp + dragoncoinPoints;
                            dragoncoinCollected   <= 1;
                            dragoncoinNewLocation <= 1;
                        end  
                    else if(((xPos <= xDragonCoin + DragonCoinWIDTH - PlayerWIDTH) && (xPos >= xDragonCoin - PlayerWIDTH)) && 
                            ((yPos <= yDragonCoin + DragonCoinHEIGHT - PlayerHEIGHT) && (yPos >= yDragonCoin - PlayerHEIGHT)))
                        begin
                            SM_Coin               <= 0;
                            playerScore_tmp       <= playerScore_tmp + dragoncoinPoints;
                            dragoncoinCollected   <= 1;
                            dragoncoinNewLocation <= 1;
                        end
                   end      // Not GameOver Yet
               end          // End State 1
               endcase 
            end
        end                 // End always block
  
/** 3rd **/  
// Interaction between Mobs and Player
// State 0: Allow for Player to be Invincible for 3 Seconds; starting state upon reset.
//          Check whether there is a game over.
//          game over is TRUE if : get hit 3 times or get a winning score 
//
// State 1: Not Invincible; can lose the game or just lose a life.
// State 2: Game is over. 

localparam CLKS_PER_THREE_SECONDS = 75_000_000;
reg [1:0]  SM_Invincible;
reg [26:0] Invincible_Clock_Count;
// local register for always block
reg [1:0]  timesBeenHit = 2'b0;
   always@(posedge clk)
    begin
         if(rst) 
            begin
                timesBeenHit           <= 0;
                playerIsHit            <= 0;
                SM_Invincible          <= 0;
                Invincible_Clock_Count <= 0;
                gameOver               <= 0;
            end
         else begin
                case(SM_Invincible)
                2'b00:
                    begin
                        if(playerIsHit) 
                            begin
                                playerIsHit  <= 0; 
                                timesBeenHit <= timesBeenHit + 1'd1;
                            end
                        if(timesBeenHit == 2'd3 || playerScore_tmp >= winScore)
                            begin                       // Move to state 2: game is over. 
                                gameOver      <= 1;
                                SM_Invincible <= 2'b10;
                            end 
                        // Player is allowed a 3 second grace period.    
                        if(Invincible_Clock_Count == CLKS_PER_THREE_SECONDS - 1)
                            begin
                                SM_Invincible <= 2'b01;
                                Invincible_Clock_Count <= 0;
                            end
                        else 
                            begin
                                Invincible_Clock_Count <= Invincible_Clock_Count + 1'd1;
                                SM_Invincible          <= 2'b00;
                            end                                       
                    end // End State 0: Invincible 
                2'b01: 
                    begin 
                        // Collision of Upper left of Frog and Thwomps/Banzai Bill/Blue Shell
                        if( (((xPos <= xThwomp1 + ThwompWIDTH) && (xPos >= xThwomp1)) && 
                                ((yPos <= yThwomp1 + ThwompHEIGHT) && (yPos >= yThwomp1)))  || 
                            (((xPos <= xThwomp2 + ThwompWIDTH) && (xPos >= xThwomp2)) && 
                                ((yPos <= yThwomp2 + ThwompHEIGHT) && (yPos >= yThwomp2)))  ||
                             ((xPos <= xBill + BillWIDTH) && (xPos >= xBill) &&
                                (yPos <= yBill + BillHEIGHT) && (yPos >= yBill))  ||
                             ((xPos <= xShell + ShellWIDTH) && (xPos >= xShell)  &&
                                (yPos <= yShell + ShellHEIGHT) && (yPos >= yShell)))
                            begin
                                if(!gameOver) 
                                    begin
                                        SM_Invincible <= 2'b00;
                                        playerIsHit   <= 1;
                                    end
                            end
                        // Collision of Upper right of Frog and Thwomps/Banzai Bill/Blue Shell
                        else if( (((xPos <= xThwomp1 + ThwompWIDTH - PlayerWIDTH) && (xPos >= xThwomp1 - PlayerWIDTH)) && 
                                    ((yPos <= yThwomp1 + ThwompHEIGHT) && (yPos >= yThwomp1)))  ||
                                 (((xPos <= xThwomp2 + ThwompWIDTH - PlayerWIDTH) && (xPos >= xThwomp2 - PlayerWIDTH)) && 
                                    ((yPos <= yThwomp2 + ThwompHEIGHT) && (yPos >= yThwomp2)))  || 
                                  ((xPos <= xBill + BillWIDTH - PlayerWIDTH) && (xPos >= xBill - PlayerWIDTH) &&
                                    (yPos <= yBill + BillHEIGHT) && (yPos >= yBill))  ||
                                  ((xPos <= xShell + ShellWIDTH - PlayerWIDTH) && (xPos >= xShell - PlayerWIDTH)  &&
                                    (yPos <= yShell + ShellHEIGHT) && (yPos >= yShell)))
                            begin
                                if(!gameOver) 
                                    begin
                                        SM_Invincible <= 2'b00;
                                        playerIsHit   <= 1;
                                    end
                            end
                        // Collision of Lower left of Frog and Thwomps/Banzai Bill/Blue Shell
                        else if( (((xPos <= xThwomp1 + ThwompWIDTH) && (xPos >= xThwomp1)) && 
                                     ((yPos <= yThwomp1 + ThwompHEIGHT - PlayerHEIGHT) && (yPos >= yThwomp1 - PlayerHEIGHT))) ||
                                  (((xPos <= xThwomp2 + ThwompWIDTH) && (xPos >= xThwomp2)) && 
                                    ((yPos <= yThwomp2 + ThwompHEIGHT - PlayerHEIGHT) && (yPos >= yThwomp2 - PlayerHEIGHT)))  || 
                                  ((xPos <= xBill + BillWIDTH) && (xPos >= xBill) &&
                                     (yPos <= yBill + BillHEIGHT - PlayerHEIGHT) && (yPos >= yBill - PlayerHEIGHT))   ||
                                  ((xPos <= xShell + ShellWIDTH) && (xPos >= xShell)  &&
                                     (yPos <= yShell + ShellHEIGHT - PlayerHEIGHT) && (yPos >= yShell - PlayerHEIGHT))) 
                            begin
                                if(!gameOver) 
                                    begin
                                        SM_Invincible <= 2'b00;
                                        playerIsHit   <= 1;
                                    end
                            end
                       // Collision of Lower right of Frog and Thwomps/Banzai Bill/Blue Shell
                       else if( (((xPos <= xThwomp1 + ThwompWIDTH - PlayerWIDTH) && (xPos >= xThwomp1 - PlayerWIDTH)) && 
                                     ((yPos <= yThwomp1 + ThwompHEIGHT - PlayerHEIGHT) && (yPos >= yThwomp1 - PlayerHEIGHT))) ||
                                (((xPos <= xThwomp2 + ThwompWIDTH - PlayerWIDTH) && (xPos >= xThwomp2 - PlayerWIDTH)) && 
                                    ((yPos <= yThwomp2 + ThwompHEIGHT - PlayerHEIGHT) && (yPos >= yThwomp2 - PlayerHEIGHT)))  ||
                                 ((xPos <= xBill + BillWIDTH - PlayerWIDTH) && (xPos >= xBill - PlayerWIDTH) &&
                                     (yPos <= yBill + BillHEIGHT - PlayerHEIGHT) && (yPos >= yBill - PlayerHEIGHT))   ||
                                 ((xPos <= xShell + ShellWIDTH - PlayerWIDTH) && (xPos >= xShell - PlayerWIDTH)  &&
                                     (yPos <= yShell + ShellHEIGHT - PlayerHEIGHT) && (yPos >= yShell - PlayerHEIGHT)))
                            begin
                                if(!gameOver) 
                                    begin
                                        SM_Invincible <= 2'b00;
                                        playerIsHit   <= 1;
                                    end
                            end    
                      else   // No Collision. Stay in state until there is collision. 
                        begin 
                            SM_Invincible <= 2'b01; 
                            playerIsHit   <= 0; 
                        end
                      end   // End State 1: Not Invincible 
                2'b10: 
                    begin
                        SM_Invincible <= 2'b10; // Stay in state
                        timesBeenHit  <= timesBeenHit; 
                        playerIsHit   <= 0; 
                    end 
                endcase
         end
    end  

/** ----------------------------------------------------------         
     Thwomp1, Thwomp2:
        
        1st: Create location of Thwomp1 and Thwomp2   
             Thwomp1 will get its pseudo random coordinates
             from the FIFO. 
             Thwomp2 will get its pseudo random coordinates 
             from the LFSR.
    ---------------------------------------------------------- **/
/** 1st **/ 
wire   ThwompFallSpeed = counter[17-thwompspeed];    
reg    thwompReady_tmp;
assign thwompReady = thwompReady_tmp; 

   always @(posedge ThwompFallSpeed)           
    begin
        if(rst) begin
                yThwomp1           <= 0;
                xThwomp1           <= 100; 
                yThwomp2           <= 0;
                xThwomp2           <= 400;
                thwompReady_tmp    <= 0; 
            end
         else begin
            if(yThwomp1 < FLOOR - ThwompHEIGHT) 
                yThwomp1 <= yThwomp1 + 1;
            else    // Reset Thwomp1 in New Location. Location of Thwomp1 will lag by 1 clock cycle.
                begin
                       if(thwompReady_tmp)
                        begin
                            thwompReady_tmp  <= 0;
                            yThwomp1         <= 0;
                            xThwomp1         <= prngXThwomp;
                        end
                        else    thwompReady_tmp  <= 1;
                end
            if(yThwomp2 < FLOOR - ThwompHEIGHT) 
                yThwomp2 <= yThwomp2 + 1;
            else   // Reset Thwomp2 in New Location
                begin
                    yThwomp2 <= 0;
                    xThwomp2 <= (prngXThwomp + vDisp/2)%(vDisp);
                end  
         end             
    end       

/** ----------------------------------------------------------         
      Bill:
        
        1st: Create location of Bill   
             
    ---------------------------------------------------------- **/

/** 1st **/
// Create speed and location of Banzai Bill
wire       BillSpeed = counter[18-billspeed];
localparam CLKS_PER_ONE_SEC = 25_000_000/(2**(18+1));

// local registers for always block
reg [7:0]  billCount;

    always @(posedge BillSpeed)
        begin
            if(rst) begin
                billSpawn <= 0; 
                billCount <= 0; 
                xBill     <= 0; 
                yBill     <= BillHEIGHT;   
            end
                else begin
                    if(billSpawn && (xBill < hDisp - BillWIDTH))  // Bill still on screen
                        xBill <= xBill + 3; 
                    else     // Bill left screen. Wait for it to respawn again
                        begin 
                            billSpawn <= 0;
                            if(billCount >= CLKS_PER_ONE_SEC - 1) 
                                begin 
                                    billSpawn <= 1; 
                                    billCount <= 0; 
                                    xBill     <= 0; 
                                    yBill     <= prngYBill;
                                end
                            else    billCount <= billCount + 1'd1; 
                        end 
                end
               
        end
        
/** ----------------------------------------------------------         
      Shell:
        
        1st: Create location of Shell   
             
    ---------------------------------------------------------- **/  
    
/**1st**/
// Create speed and location of Blue Shell
wire       ShellSpeed = counter [17+shellspeed];

// local registers for always block
reg [5:0]  shellCount;
reg        rightOrLeft; 
localparam CLKS_PER_HALF_SEC = ((25000000)/(2**(17+2)));
    always @(posedge ShellSpeed)
        begin
            if(rst) begin
                rightOrLeft  <= 0;
                shellSpawn   <= 0;
                shellCount   <= 0;
                xShell       <= 0;
                yShell       <= FLOOR-ShellHEIGHT;
            end
            else begin
                if(shellSpawn && (xShell >= 0 && xShell <= hDisp - ShellWIDTH))
                    begin
                        if(rightOrLeft) xShell <= xShell + 4; // Blue Shell Moves Right
                        else            xShell <= xShell - 4; // Blue Shell Moves Left
                    end
                else   // Blue Shell not on Screen
                    begin
                         shellSpawn <= 0;
                         if(shellCount >= CLKS_PER_HALF_SEC - 1)
                            begin
                                rightOrLeft    <= (prngXShell[1] ^ prngXShell[10]) ^ prngXShell[5];  // Random
                                shellSpawn     <= 1;
                                shellCount     <= 0; 
                                xShell         <= prngXShell;
                                yShell         <= FLOOR-ShellHEIGHT;    // Shell stays on bottom blocks
                            end
                         else shellCount <= shellCount + 1'd1;
                    end
            end
        end    
                 
endmodule
