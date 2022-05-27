`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer:        Adrian Sacks
// Create Date:     03/09/2022 08:57:24 PM
// Module Name:     nDigitSevenSegDriver
// Project Name:    CoinCollector
// Description:     The nDigitSevenSegDriver module is parametrized
//                  using the parameter 'numDigits'. It takes an 
//                  input of size 4*numDigits and displays it to numDigits
//                  seven segment displays. 
//                  NOTE: 
//                  Unused seven segment displays are kept completely off.                
// Revision 0.01 -  File Created
//////////////////////////////////////////////////////////////////////////////////

module nDigitSevenSegDriver
    #(parameter numDigits = 2)
    (   
        input  clk, rst, en,
        input  [numDigits*4-1: 0] in, 
        output reg [6:0] Cnode,
        output dp,
        output reg [7:0] AN
     );
      assign dp = 1'b1;  // Keep DP off
     /*--------------------------------------------------
        $clog2(val) is a verilog function that takes the ceiling 
        of 'val' in log base-2. 
        ex: if val = 5. $clog2(val) -> ceil(log2(5)) = ceil(2.3) = 3. 
        
        $clog2() is used to find the number of bits that will be used as
        the select (called 's') for time muxing the ANs and Cnodes.
        This creates a potential problem for cases when numDigits is not 
        a power of 2 - there are unused bits, which the refresh counter 
        will have to count up extra in order to reset. 
        ex) If numDigits = 6, we want 6 digits up. 
            The number of MSB select bits from refresh counter is 3 from $clog2().
            But we cannot wait until 's' will become 111 or roll over to 000 when the
            counter resets at value 20'b1_1111_1111_1111_1111_1111, or else 
            the 7th or 8th digit will be on. 
            To fix this: a conditional statement is used to reset the counter
            if(s == numDigits)  
                tmp <= 0;

     ----------------------------------------------------*/
     localparam bits_need = $clog2(numDigits);
     wire [bits_need-1:0] s;                    // Assign number of select bits  
     reg  [19:0] tmp;
     assign s = tmp[15:16-bits_need];           // based on number of digits used 
     always @(posedge clk or posedge rst)
        begin
            if(rst)
                tmp <= 20'd0;
            else
                if(en)
                    begin
                        if(s == numDigits) tmp <= 0;
                        else tmp <= tmp + 1'd1; 
                    end
                else tmp <= tmp;          
        end
        
        always@(*)
            begin
                AN = 8'b1111_1111;
                AN[s] = 1'b0;
            end
            
        wire [3:0] digit [numDigits-1:0];         
        genvar k;
        generate
            for(k = 0; k < numDigits; k = k + 1)
                begin
                    assign digit[k] = in[4*k+3:4*k];
                end
        endgenerate

        always@ (*)
        begin
                case(digit[s])                      // Seven Segment Display Outputs
                    4'd0:    Cnode = 7'b0000001;   // Output 0
                    4'd1:    Cnode = 7'b1001111;   // Output 1
                    4'd2:    Cnode = 7'b0010010;   // Output 2
                    4'd3:    Cnode = 7'b0000110;   // Output 3
                    4'd4:    Cnode = 7'b1001100;   // Output 4
                    4'd5:    Cnode = 7'b0100100;   // Output 5
                    4'd6:    Cnode = 7'b0100000;   // Output 6
                    4'd7:    Cnode = 7'b0001111;   // Output 7
                    4'd8:    Cnode = 7'b0000000;   // Output 8
                    4'd9:    Cnode = 7'b0000100;   // Output 9
                    4'd10:   Cnode = 7'b0001000;   // Output A
                    4'd11:   Cnode = 7'b1100000;   // Output B
                    4'd12:   Cnode = 7'b0110001;   // Output C
                    4'd13:   Cnode = 7'b1000010;   // Output D
                    4'd14:   Cnode = 7'b0110000;   // Output E
                    4'd15:   Cnode = 7'b0111000;   // Output F
                    default: Cnode = 7'bZZZ_ZZZZ; // High Impedance - Disconnect
                 endcase    
        end         
endmodule