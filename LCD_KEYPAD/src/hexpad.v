`timescale 1ns / 1ps

module hex_keypad (
    input  wire        clk,             // 100 kHz clock
    input  wire        rst_n,           // Active-low reset
    output reg  [3:0]  row,             // Row outputs (to keypad)
    input  wire [3:0]  col,             // Column inputs (from keypad)
    output reg  [3:0]  key_value,       // Hex value of pressed key
    output reg         key_valid        // High when a key is pressed
);

parameter DEBOUNCE_TIME = 8;             // 8 cycles at 100 kHz = 80us debounce time
reg clk_out;
    // Counter for clock division
    reg [13:0] counter = 0;     // 14-bit counter for 10,000 cycles

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            clk_out <= 0;
        end else begin
            counter <= counter + 1;

            if (counter >= 500) begin   // Toggle every 5000 cycles
                clk_out <= ~clk_out;
                counter <= 0;
            end
        end
    end



// =============================
// Internal Signals
// =============================
reg [1:0] row_sel;                       // Row selector (2 bits for 4 rows)
reg [7:0] debounce_buffer [3:0];         // Shift registers for debounce (one per column)
reg [3:0] col_stable;                    // Stable column values
reg [3:0] last_key;                      // Stores last key to prevent duplicates
 reg [3:0] prev_col_stable;                    // prev column values
 reg [3:0] curr_col_stable;                    // curr column values
reg [3:0] curr_row;

// Key mapping lookup table
reg [3:0] key_map [51:0];
/*reg key_map_check[51:0];
initial begin
    key_map[ 0] = 4'h1; key_map[ 1] = 4'h2; key_map[ 2] = 4'h3; key_map[ 3] = 4'hA;
    key_map[ 17] = 4'h4; key_map[ 18] = 4'h5; key_map[ 20] = 4'h6; key_map[ 24] = 4'hB;
    key_map[ 32] = 4'h7; key_map[ 33] = 4'h8; key_map[34] = 4'h9; key_map[35] = 4'hC;
    key_map[ 48] = 4'hE; key_map[49] = 4'h0; key_map[50] = 4'hF; key_map[51] = 4'hD;
end*/
reg [3:0] keypad_map [3:0][3:0];

initial begin
    keypad_map[0][0] = 4'h1;   keypad_map[0][1] = 4'h2;  keypad_map[0][2] = 4'h3;  keypad_map[0][3] = 4'hA;
    keypad_map[1][0] = 4'h4;   keypad_map[1][1] = 4'h5;  keypad_map[1][2] = 4'h6;  keypad_map[1][3] = 4'hB;
    keypad_map[2][0] = 4'h7;   keypad_map[2][1] = 4'h8;  keypad_map[2][2] = 4'h9;  keypad_map[2][3] = 4'hC;
    keypad_map[3][0] = 4'hE;   keypad_map[3][1] = 4'h0;  keypad_map[3][2] = 4'hF;  keypad_map[3][3] = 4'hD;
end


// =============================
// Row Scanning Logic
// =============================
always @(posedge clk_out or negedge rst_n) begin
    if (!rst_n) begin
        row_sel <= 0;
        row <= 4'b1110;                 // Start with Row 0 active

    end else begin
        row_sel <= row_sel + 1;         // Rotate row selection
        case (row_sel)
            2'b00: row <= 4'b1110;      // Row 0 active
            2'b01: row <= 4'b1101;      // Row 1 active
            2'b10: row <= 4'b1011;      // Row 2 active
            2'b11: row <= 4'b0111;      // Row 3 active
        endcase
    end
end

// =============================
// Column Debouncing Logic
// =============================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        debounce_buffer[0] <= 8'd0;
        debounce_buffer[1] <= 8'd0;
        debounce_buffer[2] <= 8'd0;
        debounce_buffer[3] <= 8'd0;
        col_stable <= 4'b1111;
    end else begin
        // Shift register debounce for each column
        debounce_buffer[0] <= {debounce_buffer[0][6:0], col[0]};
        debounce_buffer[1] <= {debounce_buffer[1][6:0], col[1]};
        debounce_buffer[2] <= {debounce_buffer[2][6:0], col[2]};
        debounce_buffer[3] <= {debounce_buffer[3][6:0], col[3]};
        
        // If a column has been consistently low, register a stable press
        col_stable[0] <= (debounce_buffer[0] > 8'h0F) ? 1'b0 : 1'b1;
        col_stable[1] <= (debounce_buffer[1] > 8'h0F) ? 1'b0 : 1'b1;
        col_stable[2] <= (debounce_buffer[2] > 8'h0F) ? 1'b0 : 1'b1;
        col_stable[3] <= (debounce_buffer[3] > 8'h0F) ? 1'b0 : 1'b1;
    end
end

// =============================
// Key Detection
// =============================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        key_valid <= 0;
        key_value <= 4'h0;
        last_key <= 4'h0;
        curr_col_stable <= 4'b1111;                   
        prev_col_stable <= 4'b1111;
    end else begin
        curr_col_stable = col_stable;
        if ( curr_col_stable !=  prev_col_stable) begin
            prev_col_stable = curr_col_stable;
            curr_row=~row;
           //key_value <= key_map[{curr_row,~curr_col_stable}];
            key_value <= keypad_map[row_sel][(curr_col_stable == 4'b0001) ? 0 : (curr_col_stable == 4'b0010) ? 1 : (curr_col_stable == 4'b0100) ? 2 : 3];
            key_valid <= 1;
        end else begin
            key_valid <= 0;
        end
    end
end

endmodule
