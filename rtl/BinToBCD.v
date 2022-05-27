`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer:        Adrian Sacks 
// Create Date:     05/26/2022 12:28:03 AM
// Module Name:     BinToBCD
// Project Name:    CoinCollector
// Description:     Converts a 14 bit binary number 
//                  into 20 bit BCD. 
// Revision 0.01 -  File Created
//////////////////////////////////////////////////////////////////////////////////

module BinToBCD
    (
        input      [13:0] Binary,     
        output reg [19:0] BCD
    );
  
  integer k;
  always @(Binary) 
    begin
        BCD = 0;                        // Set BCD output to 0 first  
        for(k=0;k<14;k=k+1)     
            begin                       // Add 3 if the lower or upper 4 bits is greater than or equal to 5
                if(BCD[3:0]  >= 5) BCD[3:0]   = BCD[3:0]   + 3;      
                if(BCD[7:4]  >= 5) BCD[7:4]   = BCD[7:4]   + 3;
                if(BCD[11:8] >= 5) BCD[11:8]  = BCD[11:8]  + 3;
                if(BCD[15:12]>= 5) BCD[15:12] = BCD[15:12] + 3;
                if(BCD[19:16]>= 5) BCD[19:16] = BCD[19:16] + 3; 
                BCD = {BCD[18:0], Binary[13-k]};    // Shift the input left once into the BCD output 
                                                    // every for loop iteration, starting with MSB
            end
    end
endmodule
