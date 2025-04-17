module square_wave (
    input wire clk,
    input wire rst,
    output reg [7:0] dac_out
);
    reg [15:0] counter;
    reg state;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            state <= 0;
            dac_out <= 0;
        end else begin
            counter <= counter + 1;

            if (counter == 16'd300) begin
                state <= ~state;
                dac_out <= state ? 8'd255 : 8'd0;
                counter <= 0;
            end
        end
    end
endmodule
