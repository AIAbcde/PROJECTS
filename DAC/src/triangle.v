module triangle_wave (
    input wire clk,
    input wire rst,
    output reg [7:0] dac_out
);
    reg direction;
    reg [7:0] counter;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 8'd0;
            direction <= 1'b1;
        end else begin
            if (direction)
                counter <= counter + 1;
            else
                counter <= counter - 1;

            if (counter == 8'd255)
                direction <= 1'b0;
            else if (counter == 8'd0)
                direction <= 1'b1;
        end
    end

    always @(posedge clk) begin
        dac_out <= counter;
    end
endmodule
