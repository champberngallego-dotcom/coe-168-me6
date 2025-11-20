`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2025 11:10:16 AM
// Design Name: 
// Module Name: ssd_driver
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module ssd_driver (
    input clk,
    input nrst,
    input [8:0] data_in,
    output segA,
    output segB,
    output segC,
    output segD,
    output segE,
    output segF,
    output segG,
    output reg sel
);

    // Registers
    reg [15:0] divider;         // digit multiplexer divider
    reg [6:0] segments;         // segment register
    reg [3:0] cur_digit;        // current digit to display
    reg mode;                   // mode bit (data_in[8])
    reg [7:0] data;             // lower 8 bits
    
    assign {segA, segB, segC, segD, segE, segF, segG} = segments;

    always @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            divider   <= 0;
            sel       <= 0;
            cur_digit <= 0;
            segments  <= 7'b0000000;
            mode      <= 0;
            data      <= 8'h00;
        end else begin
            // Latch input data
            mode <= data_in[8];
            data <= data_in[7:0];
            
            // Digit multiplexing
            divider <= divider + 1;
            sel <= divider[15]; // toggle between displays
            
            // Select which digit to display
            if (mode == 0) begin
                // Mode 0: Display hexadecimal (00-FF)
                if (sel)
                    cur_digit <= data[7:4]; // high nibble
                else
                    cur_digit <= data[3:0]; // low nibble
            end else begin
                // Mode 1: Custom character display
                if (sel) begin
                    // High digit - display based on value range
                    if (data >= 8'hF0)        // 0xF0-0xFF: display 'C'
                        cur_digit <= 4'hD;    // Use 'D' code for 'C'
                    else if (data >= 8'hE0)   // 0xE0-0xEF: display 'G'
                        cur_digit <= 4'hA;    // Use 'A' code for 'G'
                    else                      // 0x00-0xDF: display '-'
                        cur_digit <= 4'hC;    // Use 'C' code for '-'
                end else begin
                    // Low digit - display based on value range
                    if (data >= 8'hF0)        // 0xF0-0xFF: display 'B'
                        cur_digit <= 4'hB;    // Use 'B' code for 'B'
                    else if (data >= 8'hE0)   // 0xE0-0xEF: display 'G'
                        cur_digit <= 4'hA;    // Use 'A' code for 'G'
                    else                      // 0x00-0xDF: display hex digit
                        cur_digit <= data[3:0]; // low nibble for negative hex
                end
            end

            // SSD Decoder
            case (cur_digit)
                // Standard hexadecimal digits
                4'h0: segments <= 7'b1111110;
                4'h1: segments <= 7'b0110000;
                4'h2: segments <= 7'b1101101;
                4'h3: segments <= 7'b1111001;
                4'h4: segments <= 7'b0110011;
                4'h5: segments <= 7'b1011011;
                4'h6: segments <= 7'b1011111;
                4'h7: segments <= 7'b1110000;
                4'h8: segments <= 7'b1111111; // '8'
                4'h9: segments <= 7'b1111011;
                // Custom characters (mode 1)
                4'hA: segments <= 7'b1011110;  // 'G' (custom)
                4'hB: segments <= 7'b1111111;  // 'B' (custom, looks like '8')
                4'hC: segments <= 7'b0000001;  // '-' (minus sign)
                4'hD: segments <= 7'b1001110;  // 'C'
                4'hE: segments <= 7'b1110111;  // 'A'
                4'hF: segments <= 7'b1000111;  // 'F'
                default: segments <= 7'b0000000;
            endcase
        end
    end

endmodule
