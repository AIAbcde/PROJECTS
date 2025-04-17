module parallel_dac (
    input wire clk,
    input wire rst,
    output reg [7:0] dac_out  // Connect these pins to your DAC or R-2R ladder
);

    reg [7:0] value;

    always @(posedge clk or posedge rst) begin
        if (rst)
            value <= 8'd0;
        else
            value <= value + 1;  // Sawtooth waveform (0 to 255)
    end

    always @(posedge clk) begin
        dac_out <= value;
    end

endmodule
