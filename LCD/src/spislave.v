//###############################
//# Project Name : 
//# File         : spislave.v
//# Author       : 
//# Description  : SPI Slave Module
//# Modification History
//#
//###############################

`timescale 1ns / 1ps

module spislave (
    inout  wire MCLK,                       // Main clock
    input  wire nRST,                       // Reset signal
    input  wire SCK,                        // SPI Clock
    input  wire MOSI,                       // Master Out, Slave In
    output reg  MISO,                       // Master In, Slave Out
    input  wire SS,                         // Slave Select
    output reg [7:0] POUT,                  // Output data
    input  wire [7:0] PIN,                  // Input data
    output reg RDYIN,                       // Ready Input
    output reg RDYOUT                       // Ready Output
);

// State definitions
parameter S_IDLE          = 2'b00;
parameter S_WAIT_CAPTURE  = 2'b01;
parameter S_WAIT_OUTPUT   = 2'b10;
parameter S_END           = 2'b11;

reg [1:0] state;
reg [7:0] sout;
reg [7:0] sin;
reg [2:0] cnt;
reg start;

reg sck_q, ss_q;
reg sck_i, ss_i;
reg mosi_i;

wire sckup    = ~sck_q & sck_i;   // Rising edge
wire sckdown  = sck_q & ~sck_i;   // Falling edge
wire ssdown   = ss_q & ~ss_i;

wire capture_edge = sckup;
wire output_edge  = sckdown;

// Synchronize inputs
always @(posedge MCLK or negedge nRST) begin
    if (!nRST) begin
        ss_i   <= 1'b1;
        sck_i  <= 1'b0;
        mosi_i <= 1'b0;
        sck_q  <= 1'b0;
        ss_q   <= 1'b1;
    end else begin
        ss_i   <= SS;
        sck_i  <= SCK;
        mosi_i <= MOSI;
        sck_q  <= sck_i;
        ss_q   <= ss_i;
    end
end

// Main SPI Logic
always @(posedge MCLK or negedge nRST) begin
    if (!nRST) begin
        MISO     <= 1'b1;
        state    <= S_IDLE;
        POUT     <= 8'b0;
        RDYIN    <= 1'b0;
        RDYOUT   <= 1'b0;
        sout     <= 8'b0;
        sin      <= 8'b0;
        cnt      <= 3'b0;
        start    <= 1'b1;
    end else begin
        case (state)
            S_IDLE: begin
                RDYOUT <= 1'b0;
                if (!ss_i) begin
                    sout <= {PIN[6:0], 1'b1};
                    MISO <= PIN[7];
                    RDYOUT <= 1'b0;
                    RDYIN  <= 1'b0;
                    cnt <= 3'b0;
                    state <= S_WAIT_CAPTURE;
                end else begin
                    start <= 1'b1;
                    state <= S_IDLE;
                end
            end

            S_WAIT_CAPTURE: begin
                RDYIN <= 1'b0;
                if (ss_i) begin
                    start   <= 1'b1;
                    state   <= S_IDLE;
                    RDYOUT  <= 1'b0;
                    cnt     <= 3'b0;
                end else if (capture_edge) begin
                    if (cnt == 3'b000)
                        RDYIN <= 1'b1;

                    sin <= {sin[6:0], mosi_i};
                    state <= S_WAIT_OUTPUT;
                end
            end

            S_WAIT_OUTPUT: begin
                RDYIN <= 1'b0;
                if (output_edge) begin
                    MISO <= sout[7];
                    sout <= {sout[6:0], 1'b0};
                    if (cnt == 3'b111) begin
                        cnt    <= 3'b0;
                        POUT   <= sin;
                        RDYOUT <= 1'b1;
                        state  <= S_END;
                    end else begin
                        cnt <= cnt + 1;
                        state <= S_WAIT_CAPTURE;
                    end
                end
            end

            S_END: begin
                RDYOUT <= 1'b0;
                state  <= S_IDLE;
                start  <= 1'b0;
            end
        endcase
    end
end

endmodule
