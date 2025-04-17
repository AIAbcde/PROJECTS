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
    output wire [3:0] test_state,
    output reg led,
    input wire [3:0] col,      // Keypad column input
    output wire [3:0] row,     // Keypad row output
    output wire rs,       // LCD Register Select
    output wire en,       // LCD Enable
    output wire [3:0] data // LCD Data Bus (D7-D4)
);

assign test_state = state;

    wire [3:0] key_value;
    wire key_valid;

    // Internal registers
    reg [7:0] ascii_char;
    reg [3:0] state = 0;
    reg [7:0] char_buffer;
    reg trigger_send = 0;
    wire lcd_busy;

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


    // LCD controller wrapper
    lcd_interface lcd_inst (
        .clk(clk_1mhz),
        .rst_n(nRST),           // Active-high reset
        .char_in(char_buffer),
        .send(trigger_send),
        .rs(rs),
        .en(en),
        .data(data)
    );


    // Instantiate the keypad
    hex_keypad keypad_inst (
        .clk(clk_out100),
        .rst_n(nRST),
        .row(row),
        .col(col),
        .key_value(key_value),
        .key_valid(key_valid)
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
reg [3:0] key_latched;
reg [15:0] delay_counter1;

parameter IDLE = 0;
parameter LOAD_CHAR = 1;
parameter SET_CHAR = 2;
parameter SEND_CHAR = 3;
parameter WAIT_DONE = 4;


always @(posedge clk_out100 or negedge nRST) begin
    if (!nRST) begin
        state <= IDLE;
        char_buffer <= 0;
        delay_counter1 <= 0;
        key_latched <= 0;
    end else begin
            case (state)

                IDLE:begin
                    if (key_valid) begin
                        key_latched <= key_value;
                        char_buffer <= 4'h01;
                        state <= LOAD_CHAR;
                    end
                end

                LOAD_CHAR: begin
                        trigger_send <= 1;
                       // delay_counter1 <= delay_counter1 + 1;
                        //if (delay_counter1 == 1000) begin
                            trigger_send <= 0;
                        //end
                        //if (delay_counter1 == 2000) begin
                                if (key_latched < 4'hA) begin  
                                       char_buffer <= (8'h30 + {4'b0000,key_latched});  
                                end
                                else begin     
                                    char_buffer <= (8'h41 + (key_latched - 4'hA)) ;
                                end
                           // char_buffer <= (key_value < 4'hA) ? (8'h30 + {4'b0000,key_value}) : (8'h41 + (key_value - 4'hA));  // A-F;//key_latched;
                            delay_counter1 <= 0;
                            state <= SET_CHAR;
                        //end
                end

                SET_CHAR: begin
                        trigger_send <= 1;
                        delay_counter1 <= delay_counter1 + 1;
                        if (delay_counter1 == 1000) begin
                            trigger_send <= 0;
                            delay_counter1 <= 0;
                            state <= IDLE;
                        end
                end
                default: state <= IDLE;
            endcase
        end
    end

endmodule
