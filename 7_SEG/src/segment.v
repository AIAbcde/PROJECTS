/*module seven_segment_display (
    input wire clk,               // System clock
    input wire reset,             // Active high reset
    output reg [7:0] seg,         // Segments a-g + dp
    output reg [5:0] digit_select // Active low digit enable
);

    // Segment codes (0-9)
    reg [7:0] segment_codes [0:9];
    initial begin
        segment_codes[ 0] = 8'b00111111; // 0
        segment_codes[ 1] = 8'b00000110; // 1
        segment_codes[ 2] = 8'b01011011; // 2
        segment_codes[ 3] = 8'b01001111; // 3
        segment_codes[ 4] = 8'b01100110; // 4
        segment_codes[ 5] = 8'b01101101; // 5
        segment_codes[ 6] = 8'b01111101; // 6
        segment_codes[ 7] = 8'b00000111; // 7
        segment_codes[ 8] = 8'b01111111; // 8
        segment_codes[ 9] = 8'b01101111; // 9
    end

    // Calendar counters: DD MM YY
    reg [5:0] day   = 6'd1;   // 1–30
    reg [4:0] month = 5'd1;   // 1–12
    reg [6:0] year  = 7'd0;   // 0–99

    // Clock divider for ~1Hz tick
    reg [25:0] second_divider = 0; // Adjust for your system clock
    wire one_sec_tick = (second_divider == 0);

    always @(posedge clk or negedge reset) begin
        if (!reset)
            second_divider <= 0;
        else
            second_divider <= second_divider + 1;
    end

    // Calendar update
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            day <= 1;
            month <= 1;
            year <= 0;
        end else if (one_sec_tick) begin
            if (day == 30) begin
                day <= 1;
                if (month == 12) begin
                    month <= 1;
                    if (year == 99)
                        year <= 0;
                    else
                        year <= year + 1;
                end else begin
                    month <= month + 1;
                end
            end else begin
                day <= day + 1;
            end
        end
    end

    // Break DD MM YY into 6 BCD digits
    reg [3:0] digits[0:5];
    always @(*) begin
        digits[5] = year / 10;    // Y1
        digits[4] = year % 10;    // Y0
        digits[3] = month / 10;   // M1
        digits[2] = month % 10;   // M0
        digits[1] = day / 10;     // D1
        digits[0] = day % 10;     // D0
    end

    // Multiplexing logic
    reg [2:0] current_digit = 0;
    reg [15:0] refresh_counter = 0;
    wire refresh_tick = (refresh_counter == 0);

    always @(posedge clk or negedge reset) begin
        if (!reset)
            refresh_counter <= 0;
        else
            refresh_counter <= refresh_counter + 1;
    end

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            current_digit <= 0;
            digit_select <= 6'b111111;
            seg <= 8'b00000000;
        end else if (refresh_tick) begin
            current_digit <= (current_digit == 5) ? 0 : current_digit + 1;
            seg <= segment_codes[digits[current_digit]];
            digit_select <= ~(6'b000001 << current_digit); // Active low
        end
    end

endmodule */

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
module seven_segment_display (
    input wire clk,                // 50MHz or 100MHz system clock
    input wire reset,              // Active high reset
    output reg [7:0] seg,          // Segments a-g + dp
    output reg [5:0] digit_select  // Active low digit enable
);

    // Segment patterns for 0-F (common cathode)
    reg [7:0] segment_codes [0:15];
    initial begin
        segment_codes[ 0] = 8'b00111111; // 0
        segment_codes[ 1] = 8'b00000110; // 1
        segment_codes[ 2] = 8'b01011011; // 2
        segment_codes[ 3] = 8'b01001111; // 3
        segment_codes[ 4] = 8'b01100110; // 4
        segment_codes[ 5] = 8'b01101101; // 5
        segment_codes[ 6] = 8'b01111101; // 6
        segment_codes[ 7] = 8'b00000111; // 7
        segment_codes[ 8] = 8'b01111111; // 8
        segment_codes[ 9] = 8'b01101111; // 9
    end

    // 6-digit decimal counter (max 999999)
    reg [19:0] counter = 0;  // Enough to count up to 999999

    // Clock divider for ~100ms count increment
    reg [23:0] count_divider = 0;
    wire count_tick = (count_divider == 0);

    always @(posedge clk or negedge reset) begin
        if (!reset)
            count_divider <= 0;
        else
            count_divider <= count_divider + 1;
    end

    // Increment the counter
    always @(posedge clk or negedge reset) begin
        if (!reset)
            counter <= 0;
        else if (count_tick)
            counter <= (counter == 999999) ? 0 : counter + 1;
    end

    // Split counter into 6 BCD digits
    reg [3:0] digits[0:5];
    integer temp;
    always @(*) begin
        temp = counter;
        digits[5] = temp / 100000; temp = temp % 100000;
        digits[4] = temp / 10000;  temp = temp % 10000;
        digits[3] = temp / 1000;   temp = temp % 1000;
        digits[2] = temp / 100;    temp = temp % 100;
        digits[1] = temp / 10;     temp = temp % 10;
        digits[0] = temp;
    end

    // Digit multiplexing state
    reg [2:0] current_digit = 0;

    // Clock divider for ~1ms refresh rate
    reg [15:0] refresh_counter = 0;
    wire refresh_tick = (refresh_counter == 0);

    always @(posedge clk or negedge reset) begin
        if (!reset)
            refresh_counter <= 0;
        else
            refresh_counter <= refresh_counter + 1;
    end

    // Multiplexing logic
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            current_digit <= 0;
            digit_select <= 6'b111111;
            seg <= 8'b00000000;
        end else if (refresh_tick) begin
            current_digit <= (current_digit == 5) ? 0 : current_digit + 1;
            seg <= segment_codes[digits[current_digit]];
            digit_select <= ~(6'b000001 << current_digit); // active-low
        end
    end

endmodule 
/////////////////////////////////////////////////////////////////////////////////////////////////
/*module seven_segment_display (
    input wire clk,                // 50MHz or 100MHz system clock
    input wire reset,              // Active high reset
    output reg [7:0] seg,          // Segments a-g + dp
    output reg [5:0] digit_select  // Active low digit enable
);

    // Segment patterns for 0-F (common cathode)
    reg [7:0] segment_codes [0:15];
    initial begin
        segment_codes[ 0] = 8'b00111111; // 0
        segment_codes[ 1] = 8'b00000110; // 1
        segment_codes[ 2] = 8'b01011011; // 2
        segment_codes[ 3] = 8'b01001111; // 3
        segment_codes[ 4] = 8'b01100110; // 4
        segment_codes[ 5] = 8'b01101101; // 5
        segment_codes[ 6] = 8'b01111101; // 6
        segment_codes[ 7] = 8'b00000111; // 7
        segment_codes[ 8] = 8'b01111111; // 8
        segment_codes[ 9] = 8'b01101111; // 9
        segment_codes[10] = 8'b01110111; // A
        segment_codes[11] = 8'b01111100; // b
        segment_codes[12] = 8'b00111001; // C
        segment_codes[13] = 8'b01011110; // d
        segment_codes[14] = 8'b01111001; // E
        segment_codes[15] = 8'b01110001; // F
    end

    // Example digits to display: 0–5
    reg [3:0] digits[0:5];
    initial begin
        digits[0] = 4'd0;
        digits[1] = 4'd1;
        digits[2] = 4'd2;
        digits[3] = 4'd3;
        digits[4] = 4'd4;
        digits[5] = 4'd5;
    end

    // Digit multiplexing state
    reg [2:0] current_digit = 0;

    // Clock divider for ~1ms digit refresh rate
    reg [15:0] refresh_counter = 0;
    wire refresh_tick = (refresh_counter == 0);

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            refresh_counter <= 0;
        end else begin
            refresh_counter <= refresh_counter + 1;
        end
    end

    // Multiplexing logic
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            current_digit <= 0;
            digit_select <= 6'b111111;
            seg <= 8'b00000000;
        end else if (refresh_tick) begin
            current_digit <= current_digit + 1;
            if (current_digit == 5) current_digit <= 0;

            // Set segments based on current digit's value
            seg <= segment_codes[digits[current_digit]];

            // Set digit select (active low)
            digit_select <= ~(6'b000001 << current_digit);
        end
    end

endmodule*/