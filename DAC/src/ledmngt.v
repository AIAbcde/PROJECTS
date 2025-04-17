//###############################
//# Project Name : 
//# File         : ledmngt.v
//# Author       : 
//# Description  : LED Management Module
//# Modification History
//#
//###############################

`timescale 1ns / 1ps

module ledmngt (
    inout  wire MCLK,                       // Main clock
    input  wire nRST,                       // Reset signal
 //   input  wire ID,                         // ID signal
    input  wire LOAD,                       // Load signal
    input  wire NXT,                        // Next signal
    output reg  [7:0] PIN,                  // Output data
    input  wire [7:0] POUT,                 // Input data
    output wire  [7:0] LED                   // LED output
);

reg [7:0] ledi;
reg [7:0] idreg;
reg [7:0] temp;
reg [7:0] counter=0;



always @(posedge MCLK or negedge nRST) begin
    if (!nRST) begin
        idreg <= 8'h00;                     // Reset idreg to all ones
        ledi  <= 8'h00;                     // Reset LED output to 0
        temp  <= 8'h00;                     // Reset temporary variable
        PIN   <= 8'h00;                     // Clear PIN on reset
    end 
    else if (LOAD) begin
            idreg <= POUT;                  // Store POUT data in idreg
            case (idreg)
                8'h00: temp <= 8'h00;                   // Clear all
                8'h01: temp <= ledi | POUT;             // Set
                8'h02: temp <= ledi & ~POUT;            // Reset
                8'h03: temp <= ledi ^ POUT;             // Toggle
                8'h04: temp <= ledi ~^ POUT;            // XNOR (Toggle)
                8'h05: temp <= ~ledi;                   // NOT (Invert)
                8'h10: temp <= POUT;                    // Force POUT to LED
                8'h20: PIN  <= ledi;                    // Copy LED state to PIN
                default: temp <= ledi;                   // Do nothing
            endcase
            ledi <= temp;                   // Update LED state
        end
    end
assign  LED = temp; 

     //Update LED inside the always block (no assign statement needed)
//    always @(posedge MCLK or negedge nRST) begin
//        if (!nRST)
//            LED <= 8'h00;
//        else
//            LED <= ledi;
//    end

endmodule
