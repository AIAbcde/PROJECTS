`timescale 1ns / 1ps

module uart_rx #(
    parameter CLK_FREQ  = 5000000,     // Clock frequency in Hz
    parameter BAUD_RATE = 9600          // Baud rate
)(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        rx_pin,
    output reg [7:0]   rx_data,
    output reg         rx_data_valid,
    input  wire        rx_data_ready
);

    localparam CLK_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam HALF_BIT = CLK_PER_BIT / 2;

    reg [15:0] clk_count = 0;
    reg [3:0] bit_index = 0;
    reg [7:0] rx_shift = 8'b0;
    reg receiving = 0;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_data       <= 8'b0;
            rx_data_valid <= 0;
            clk_count     <= 0;
            bit_index     <= 0;
            receiving     <= 0;
        end else begin
            if (!receiving && !rx_pin) begin
                receiving  <= 1;          // Start bit detected
                clk_count  <= HALF_BIT;   // Align to center of bit
            end

            if (receiving) begin
                if (clk_count < CLK_PER_BIT - 1) begin
                    clk_count <= clk_count + 1;
                end else begin
                    clk_count <= 0;
                    
                    if (bit_index < 8) begin
                        rx_shift[bit_index] <= rx_pin;  // Sample data bits
                        bit_index <= bit_index + 1;
                    end else begin
                        rx_data <= rx_shift;
                        rx_data_valid <= 1;
                        receiving <= 0;
                        bit_index <= 0;
                    end
                end
            end

            if (rx_data_valid && rx_data_ready) begin
                rx_data_valid <= 0;
            end
        end
    end
endmodule