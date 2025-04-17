`timescale 1ns / 1ps

module lcd_interface (
    input clk,               // 1 MHz clock
    input rst_n,               // active-high reset
    input wire [7:0] char_in, // Character to send
    input wire send,              // Pulse to send character
    output reg rs,           // Register select
    output reg en,           // Enable
    output reg [3:0] data    // LCD data D4–D7
);

    // FSM States
    parameter WAIT             = 4'd0;
    parameter INIT_1           = 4'd1;
    parameter INIT_2           = 4'd2;
    parameter INIT_3           = 4'd3;
    parameter INIT_4           = 4'd4;
    parameter INIT_5           = 4'd5;
    parameter CMD_SET_CURSOR   = 4'd6;
    parameter SEND_CHAR        = 4'd7;
    parameter SEND_HIGH_NIBBLE = 4'd8;
    parameter WAIT_EN_HIGH     = 4'd9;
    parameter SEND_LOW_NIBBLE  = 4'd10;
    parameter WAIT_EN_LOW      = 4'd11;
    parameter WAIT_CHAR_DELAY  = 4'd12;
    parameter DONE             = 4'd13;
    parameter EXTEND           = 4'd14;

    reg [3:0] state = WAIT;
    reg [3:0] next_state = INIT_1;
    reg [15:0] delay_counter = 0;
    reg [3:0] char_index = 0;
    reg [7:0] curr_byte = 8'd0;
    reg send_data = 0;
    reg initialized = 0;
//02,28,0C,01,06,80

    // Message: "UEDB BY SIMS"
    reg [7:0] message [0:1];
    initial begin
        message[0]  = "H"; message[1]  = "I";
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= WAIT;
            next_state <= INIT_1;
            delay_counter <= 0;
            char_index <= 0;
            en <= 0;
            rs <= 0;
            data <= 4'b0000;
            initialized = 0;
        end else begin
            case (state)
                WAIT: begin
                    delay_counter <= delay_counter + 1;
                    if (delay_counter == 50000) begin // ~50ms power-up delay
                        delay_counter <= 0;
                        state <= INIT_1;
                    end
                end

                INIT_1: begin
                    curr_byte <= 8'h02; // 4-bit mode init
                    send_data <= 0;
                    state <= SEND_HIGH_NIBBLE;
                    next_state <= INIT_2;
                end

                INIT_2: begin
                    curr_byte <= 8'h28; // Function set: 2 lines, 5x8 font
                    send_data <= 0;
                    state <= SEND_HIGH_NIBBLE;
                    next_state <= INIT_3;
                end

                INIT_3: begin
                    curr_byte <= 8'h0C; // Display on, cursor off
                    send_data <= 0;
                    state <= SEND_HIGH_NIBBLE;
                    next_state <= INIT_4;
                end

                INIT_4: begin
                    curr_byte <= 8'h01; // Clear display
                    send_data <= 0;
                    state <= SEND_HIGH_NIBBLE;
                    next_state <= INIT_5;
                end

                INIT_5: begin
                    curr_byte <= 8'h06; // Entry mode set
                    send_data <= 0;
                    state <= SEND_HIGH_NIBBLE;
                    next_state <= CMD_SET_CURSOR;
                end

                CMD_SET_CURSOR: begin
                    curr_byte <= 8'h80; // Move cursor to first row, first column
                    send_data <= 0;
                    state <= SEND_HIGH_NIBBLE;
                    next_state <= SEND_CHAR;
                end

                SEND_CHAR: begin
                    curr_byte <= message[char_index];
                    send_data <= 1;
                    state <= SEND_HIGH_NIBBLE;
                    next_state <= WAIT_CHAR_DELAY;
                end

                SEND_HIGH_NIBBLE: begin
                    rs <= send_data;
                    en <= 1;
                    data <= curr_byte[7:4];
                    delay_counter <= 0;
                    state <= WAIT_EN_HIGH;
                end

                WAIT_EN_HIGH: begin
                    delay_counter <= delay_counter + 1;
                    if (delay_counter == 100) begin
                        en <= 0;
                        delay_counter <= 0;
                        state <= SEND_LOW_NIBBLE;
                    end
                end

                SEND_LOW_NIBBLE: begin
                    rs <= send_data;
                    en <= 1;
                    data <= curr_byte[3:0];
                    delay_counter <= 0;
                    state <= WAIT_EN_LOW;
                end

                WAIT_EN_LOW: begin
                    delay_counter <= delay_counter + 1;
                    if (delay_counter == 100) begin
                        en <= 0;
                        delay_counter <= 0;
                        state <= EXTEND;
                    end
                end

                EXTEND: begin
                    delay_counter <= delay_counter + 1;
                    if (delay_counter == 3000) begin
                        delay_counter <= 0;
                        state <= next_state;
                    end
                end

                WAIT_CHAR_DELAY: begin
                    delay_counter <= delay_counter + 1;
                    if (delay_counter == 2000) begin
                        delay_counter <= 0;
                        char_index <= char_index + 1;
                        if (char_index < 1)
                            state <= SEND_CHAR;
                        else begin
                            state <= DONE;
                            initialized <= 1;
                        end
                    end
                end

                DONE: begin
                    if (!initialized) begin
                        state <= WAIT;
                    end else if (send) begin
                                if (curr_byte != char_in) begin
                                            if (char_in == 8'h30) begin
                                                    curr_byte <= 8'h01;
                                                    send_data <= 0; // Data if printable
                                                    state <= SEND_HIGH_NIBBLE;
                                                    next_state <= DONE;
                                            end
                                            else begin
                                                    curr_byte <= char_in;
                                                    send_data <= 1; // Data if printable
                                                    state <= SEND_HIGH_NIBBLE;
                                                    next_state <= DONE;
                                            end
                                end
                    end
                    // Stay in DONE state
                end

                default: state <= WAIT;
            endcase
        end
    end

endmodule
