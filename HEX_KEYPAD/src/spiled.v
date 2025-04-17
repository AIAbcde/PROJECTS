`timescale 1ns / 1ps

module spileds (
    /*inout  wire MCLK,
    input  wire SS,
    input  wire MOSI,
    input  wire SCK,
    output wire MISO,*/
     input  wire nRST,
    output wire TESTCLK,
    input  wire clk,              // 20 MHz input clock
    output wire externalclk,      // Output clock at 25 MHz
    output wire [7:0] LED,
    output wire [7:0] pout_sig,
    input  wire rx_pin,           // UART RX pin
    output wire tx_pin,            // UART TX pin
     output wire [3:0]  row,             // Keypad row outputs
    input  wire [3:0]  col             // Keypad column inputs
);


// =============================
// Internal Signals
// =============================
wire RDYIN, RDYOUT;
wire [7:0] PIN, POUT;
wire pllclk, plllock;         // 100 MHz PLL output
reg  clk_out5 = 0;              // 5 MHz clock output
reg  clk_out100 = 0;
// =============================
// Clock Assignments
// =============================
assign externalclk = clk_out100;    // Use 25 MHz clock as external clock
assign MCLK = pllclk;            // Use PLL 100 MHz clock for SPI and LED
assign TESTCLK = pllclk;         // Test clock (PLL output)
assign pout_sig = POUT;

// =============================
// PLL Instantiation (100 MHz)
// =============================
Gowin_rPLL pllclock (
    .clkout(pllclk),   // PLL output (100 MHz)
    .lock(plllock),     // Lock signal
    .clkin(clk)         // Input clock (20 MHz)
);
/*
// =============================
// SPI Slave Module
// =============================
spislave I_spislave_0 (
    .MCLK(MCLK),         // 100 MHz PLL clock
    .nRST(nRST),
    .SCK(SCK),
    .MOSI(MOSI),
    .MISO(MISO),
    .SS(SS),
    .POUT(POUT),
    .PIN(PIN),
    .RDYIN(RDYIN),
    .RDYOUT(RDYOUT)
);

// =============================
// LED Management Module
// =============================
ledmngt I_ledmngt_0 (
    .MCLK(MCLK),
    .nRST(nRST),
    .LOAD(RDYOUT),
    .NXT(RDYIN),
    .PIN(PIN),
    .POUT(POUT),
    .LED(LED)
);
*/
// =============================
// UART Transmission
// =============================
// RX signals
wire [7:0] rx_data;
wire rx_data_valid;
wire rx_data_ready = 1;   // Always ready to receive

// TX signals
reg [7:0] tx_data;
reg tx_start = 0;
wire tx_busy;

// UART Transmitter Instance (25 MHz clock)
uart_tx #(
    .CLK_FREQ(5000000),         // 25 MHz clock for UART
    .BAUD_RATE(9600)
) uart_tx_inst (
    .clk(clk_out5),                // Use 25 MHz clock
    .rst_n(nRST),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .tx_busy(tx_busy),
    .tx_pin(tx_pin)
);

// UART Receiver Instance (25 MHz clock)
uart_rx #(
    .CLK_FREQ(5000000),
    .BAUD_RATE(9600)
) uart_rx_inst (
    .clk(clk_out5),
    .rst_n(nRST),
    .rx_pin(rx_pin),
    .rx_data(rx_data),
    .rx_data_valid(rx_data_valid),
    .rx_data_ready(rx_data_ready)
);



// =============================
// Keypad Module Instantiation
// =============================
hex_keypad keypad (
    .clk(clk_out100),
    .rst_n(nRST),
    .row(row),
    .col(col),
    .key_value(key_value),
    .key_valid(key_valid)
);

wire [3:0] key_value;                  // Hex value of pressed key
wire key_valid;                        // Key press valid flag


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




// =============================
// UART TX Control Logic
// =============================
always @(posedge clk_out5 or negedge nRST) begin
    if (!nRST) begin
        tx_start <= 0;
        tx_data  <= 8'b0;
    end else begin
        if (key_valid || rx_data_valid  && !tx_busy) begin
            tx_data  <= {4'b0000,key_value};      // Transmit received data
            tx_start <= 1;         // Trigger TX
        end else begin
            tx_start <= 0;
        end
    end
end

endmodule
