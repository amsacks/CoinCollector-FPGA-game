`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2022 01:05:59 AM
// Design Name: 
// Module Name: FIFOv2
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


module FIFOv2#( parameter WIDTH = 8,      // Data width
                parameter DEPTH = 16)     // Depth of FIFO                    
                (
                   input  clk1,                     // Write Clock
                   input  clk2,                     // Read Clock            
                   input  rst,                      // Active-high Asynchronous Reset
                   input  i_wren,                   // Write Enable
                   input [WIDTH-1:0] i_wrdata,      // Write-data
                   output o_full,                   // Full signal
                   input  i_rden,                   // Read Enable
                   output reg [WIDTH-1:0] o_rddata, // Read-data
                   output o_empty                   // Empty signal
                );

reg [WIDTH - 1         : 0] data_rg [DEPTH:0];  // Data array
reg [$clog2(DEPTH) : 0] wrptr_rg;               // Write pointer
reg [$clog2(DEPTH) : 0] rdptr_rg;               // Read pointer
reg [$clog2(DEPTH)-1:0] wrptr_addr;
reg [$clog2(DEPTH)-1:0] rdptr_addr;

wire wren_s;        // Write Enable signal generated iff FIFO is not full
wire rden_s;        // Read Enable signal generated iff FIFO is not empty
wire full_s;        // Full signal
wire empty_s;       // Empty signal

always @ (posedge clk1 or posedge rst) begin
   if (rst) begin             
      wrptr_rg   <= 0;   
      wrptr_addr <= 0;  
   end
   else 
        begin 
      /* FIFO write logic */            
      if (wren_s) begin                            
         data_rg [wrptr_addr] <= i_wrdata;        // Data written to FIFO
        // else 
            wrptr_addr <= wrptr_addr + 1; 
            wrptr_rg <= wrptr_rg + 1;           // Increment write pointer            
      end 
    end
end
 
always @(posedge clk2 or posedge rst) begin
      if (rst) begin             
          rdptr_rg  <= 0; 
          rdptr_addr <= 0;     
        end
   else begin
      /* FIFO read logic */
      if (rden_s) begin 
            // Read-data to output
            o_rddata  <= data_rg [rdptr_addr];    
            rdptr_addr <= rdptr_addr +1;
            rdptr_rg <= rdptr_rg + 1;           // Increment read pointer            
      end              
     end
end

    localparam MSB = $clog2(DEPTH);
    // Full and Empty internal
     assign full_s  =  ({~wrptr_rg[MSB], wrptr_rg[MSB-1:0]} == rdptr_rg) ? 1 : 0;
     assign empty_s =  (wrptr_rg == rdptr_rg) ? 1 : 0;
     
    // Write and Read Enables internal
    assign wren_s  = i_wren & !full_s;  
    assign rden_s  = i_rden & !empty_s;
         
    // Full and Empty to output
    assign o_full  = full_s;
    assign o_empty = empty_s;

endmodule