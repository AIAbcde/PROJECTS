`timescale 1ns / 1ps

module uart_tx #(
    parameter CLK_FREQ  = 5000000,      // Clock frequency in Hz
    parameter BAUD_RATE = 9600           // Baud rate
)(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        tx_start,         // Start TX when data is ready
    input  wire [7:0]  tx_data,          // Data to transmit
    output reg         tx_busy,          // TX busy signal
    output reg         tx_pin            // UART TX pin
);

    localparam CLK_PER_BIT = CLK_FREQ / BAUD_RATE;  // Clock cycles per UART bit

    reg [15:0] clk_count = 0;
    reg [3:0] bit_index = 0;
    reg [9:0] tx_shift = 10'b1111111111;             // Start + 8 data bits + stop
    reg transmitting = 0;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_pin     <= 1;                         // Idle state
            tx_busy    <= 0;
            clk_count  <= 0;
            bit_index  <= 0;
            transmitting <= 0;
        end else begin
            if (tx_start && !transmitting) begin
                // Load data into shift register (start, data, stop)
                tx_shift    <= {1'b1, tx_data, 1'b0}; 
                transmitting <= 1;
                tx_busy     <= 1;
                clk_count   <= 0;
                bit_index   <= 0;
            end

            if (transmitting) begin
                if (clk_count < CLK_PER_BIT - 1) begin
                    clk_count <= clk_count + 1;
                end else begin
                    clk_count <= 0;
                    tx_pin    <= tx_shift[0];
                    tx_shift  <= {1'b1, tx_shift[9:1]};  // Shift right
                    bit_index <= bit_index + 1;

                    if (bit_index == 9) begin
                        transmitting <= 0;              // Transmission complete
                        tx_busy <= 0;
                    end
                end
            end
        end
    end

endmodule
