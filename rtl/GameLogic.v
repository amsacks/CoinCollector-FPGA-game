`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/25/2022 08:50:38 PM
// Design Name: 
// Module Name: GameLogic
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

// ASCII of keys pressed
`define UP     8'h77       // Up (w)
`define DOWN   8'h73       // Down (s)
`define LEFT   8'h61       // Left (a)
`define RIGHT  8'h64       // Right (d)

module GameLogic
    #( parameter hDisp = 640,
       parameter vDisp = 480
     ) 
      (
        input              clk,
        input        [1:0] PlayerSpeed,
        input        [1:0] 
        output             gameOver,     // Could be win or lose when HIGH
        output             win,          // Active HIGH win
        output      [10:0] xPos,
        output      [10:0] yPos,
        output      [10:0] xThwomp1,
        output      [10:0] yThwomp1,
        output      [10:0] xThwomp2,
        output      [10:0] yThwomp2,
        output      [10:0] xBill,
        output      [10:0] yBill, 
        output             billSpawn,    // Active HIGH show bill
        output      [10:0] xShell,
        output      [10:0] yShell,
        output             shellSpawn,   // Active HIGH show shell
        output      [10:0] xCoin,
        output      [10:0] yCoin,
        output      [10:0] xDragonCoin,
        output      [10:0] yDragonCoin,
        output             dragoncoinSpawn, // Active HIGH show dragon coin
        output      [10:0] hc,
        output      [10:0] vc
      );
/** ----------------------------------------------------------------------------------------- **/
    // Create Player Movements by changing x-coordinate and y-coordinate 
    // of player in accordance to the input key.
    reg [21:0] counter; 
    wire FrogFrame = counter[19-FrogSpeed];
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
                case(data)
                    `UP:     begin Direction <= 0; end 
                    `DOWN:   begin Direction <= 1; end
                    `LEFT:   begin Direction <= 2; end
                    `RIGHT:  begin Direction <= 3; end
                    default: begin Direction <= 4; end
                endcase
        end
    end

    always @(posedge FrogFrame)
        begin
            if(rst)
                begin
                    xPos <= 300;
                    yPos <= 200;       
                end
            else
                if(!GameOver)
                case(Direction)
                    3'b000: begin   // UP
                                if(yPos < 1) yPos <= yPos;         // Cannot go UP anymore 
                                else yPos <= yPos - 1; 
                            end
                    3'b001: begin  // DOWN
                                if(yPos < (vEND - BlockHEIGHT-FrogHEIGHT)) yPos <= yPos + 1;
                                else if((yPos >= (vEND - BlockHEIGHT - FrogHEIGHT/2)) // Frog/block collision  
                                        && (yPos <= vEND - BlockHEIGHT - FrogHEIGHT)) yPos <= yPos;
                            end 
                    3'b010: begin  // LEFT
                                if(xPos < 1) xPos <= hEND;
                                else xPos <= xPos - 1; 
                            end
                    3'b011: begin // RIGHT
                                if(xPos < hEND + FrogWIDTH) xPos <= xPos + 1; 
                                else xPos <= 0;
                            end
                    3'b100: begin // IDLE
                                xPos <= xPos; yPos <= yPos; 
                            end      
                    default: begin xPos <= 0; yPos <= 0; end
                    endcase
        end 
  /** ----------------------------------------------------------------------------------------- **/   
  
endmodule
