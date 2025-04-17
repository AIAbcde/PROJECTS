`timescale 1ns / 1ps

module top_keypad_lcd (
    /*inout  wire MCLK,
    input  wire SS,
    input  wire MOSI,
    input  wire SCK,
    output wire MISO,*/
     input  wire nRST,
    output wire TESTCLK,
    input  wire clk,              // 20 MHz input clock
    output wire externalclk,      // Output clock at 25 MHz
    output reg led,
    output wire [7:0] seg,      // Segment outputs a-g + dp
    output wire [5:0] digit_sel // Active low digit enables
);



always @(posedge clk_out100 or negedge nRST) begin
    if(!nRST) begin
    led <=1;
   end
else begin
led = ~led;
end
end


// =============================
// Internal Signals
// =============================
wire pllclk, plllock;         // 100 MHz PLL output
reg  clk_out5 = 0;              // 5 MHz clock output
reg  clk_out100 = 0;
reg clk_1mhz = 0;
// =============================
// Clock Assignments
// =============================
assign externalclk = clk_1mhz;    // Use 25 MHz clock as external clock
assign MCLK = pllclk;            // Use PLL 100 MHz clock for SPI and LED
assign TESTCLK = clk;         // Test clock (PLL output)


// =============================
// PLL Instantiation (100 MHz)
// =============================
Gowin_rPLL pllclock (
    .clkout(pllclk),   // PLL output (100 MHz)
    .lock(plllock),     // Lock signal
    .clkin(clk)         // Input clock (20 MHz)
);

    // Instantiate the seven_segment_display module
    seven_segment_display u_display (
        .clk(pllclk),
        .reset(nRST),
        .seg(seg),
        .digit_select(digit_sel)
    );

// =============================
// Clock Divider: 100 MHz → 25 MHz
// =============================
reg [9:0] counter5 = 0;  // 2-bit counter for divide-by-4

// Divide 100 MHz to 5 MHz
always @(posedge pllclk or negedge nRST) begin
    if (!nRST) begin
        counter5 <= 0;
        clk_out5 <= 0;
    end else begin
        counter5 <= counter5 + 1;
        if (counter5 == 9) begin
            clk_out5 <= ~clk_out5;
            counter5 <= 0;
        end
    end
end

reg [9:0] counter100 = 0;

// Divide 100 MHz to 100 KHz
always @(posedge pllclk or negedge nRST) begin
    if (!nRST) begin
        counter100 <= 0;
        clk_out100 <= 0;
    end else begin
        counter100 <= counter100 + 1;
        if (counter100 == 500) begin
            clk_out100 <= ~clk_out100;
            counter100 <= 0;
        end
    end
end


 reg [8:0] counter1 = 0; // 7-bit counter (max 127)

always @(posedge pllclk or negedge nRST) begin
        if (!nRST) begin
            counter1 <= 0;
            clk_1mhz <= 0;
        end else begin
            counter1 <= counter1 + 1;
            if (counter1 == 49) begin  // 100MHz / (2 * 50) = 1MHz
                clk_1mhz <= ~clk_1mhz;
                counter1 <= 0;
            end
        end
    end


// State Machine for sending to LCD

endmodule
