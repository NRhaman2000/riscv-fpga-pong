// font8x8_min.v
// Minimal 8x8 font for required letters/numbers/space/?.
// bits[7] is leftmost pixel.

module font8x8_min (
    input  [7:0] ch,
    input  [2:0] row,
    output reg [7:0] bits
);
    always @(*) begin
        bits = 8'h00;

        case (ch)
            8'h20: bits = 8'h00; // space

            8'h3F: case (row) // '?'
                3'd0: bits = 8'b00111100;
                3'd1: bits = 8'b01000010;
                3'd2: bits = 8'b00000100;
                3'd3: bits = 8'b00001000;
                3'd4: bits = 8'b00010000;
                3'd5: bits = 8'b00000000;
                3'd6: bits = 8'b00010000;
                3'd7: bits = 8'b00000000;
            endcase

            // digits 0..9
            8'h30: case (row)
                3'd0: bits = 8'b00111100;
                3'd1: bits = 8'b01000010;
                3'd2: bits = 8'b01000110;
                3'd3: bits = 8'b01001010;
                3'd4: bits = 8'b01010010;
                3'd5: bits = 8'b01100010;
                3'd6: bits = 8'b00111100;
                3'd7: bits = 8'b00000000;
            endcase
            8'h31: case (row)
                3'd0: bits = 8'b00011000;
                3'd1: bits = 8'b00111000;
                3'd2: bits = 8'b00011000;
                3'd3: bits = 8'b00011000;
                3'd4: bits = 8'b00011000;
                3'd5: bits = 8'b00011000;
                3'd6: bits = 8'b00111100;
                3'd7: bits = 8'b00000000;
            endcase
            8'h32: case (row)
                3'd0: bits = 8'b00111100;
                3'd1: bits = 8'b01000010;
                3'd2: bits = 8'b00000010;
                3'd3: bits = 8'b00001100;
                3'd4: bits = 8'b00110000;
                3'd5: bits = 8'b01000000;
                3'd6: bits = 8'b01111110;
                3'd7: bits = 8'b00000000;
            endcase
            8'h33: case (row)
                3'd0: bits = 8'b00111100;
                3'd1: bits = 8'b01000010;
                3'd2: bits = 8'b00000010;
                3'd3: bits = 8'b00011100;
                3'd4: bits = 8'b00000010;
                3'd5: bits = 8'b01000010;
                3'd6: bits = 8'b00111100;
                3'd7: bits = 8'b00000000;
            endcase
            8'h34: case (row)
                3'd0: bits = 8'b00000100;
                3'd1: bits = 8'b00001100;
                3'd2: bits = 8'b00010100;
                3'd3: bits = 8'b00100100;
                3'd4: bits = 8'b01000100;
                3'd5: bits = 8'b01111110;
                3'd6: bits = 8'b00000100;
                3'd7: bits = 8'b00000000;
            endcase
            8'h35: case (row)
                3'd0: bits = 8'b01111110;
                3'd1: bits = 8'b01000000;
                3'd2: bits = 8'b01111100;
                3'd3: bits = 8'b00000010;
                3'd4: bits = 8'b00000010;
                3'd5: bits = 8'b01000010;
                3'd6: bits = 8'b00111100;
                3'd7: bits = 8'b00000000;
            endcase
            8'h36: case (row)
                3'd0: bits = 8'b00111100;
                3'd1: bits = 8'b01000000;
                3'd2: bits = 8'b01111100;
                3'd3: bits = 8'b01000010;
                3'd4: bits = 8'b01000010;
                3'd5: bits = 8'b01000010;
                3'd6: bits = 8'b00111100;
                3'd7: bits = 8'b00000000;
            endcase
            8'h37: case (row)
                3'd0: bits = 8'b01111110;
                3'd1: bits = 8'b00000010;
                3'd2: bits = 8'b00000100;
                3'd3: bits = 8'b00001000;
                3'd4: bits = 8'b00010000;
                3'd5: bits = 8'b00010000;
                3'd6: bits = 8'b00010000;
                3'd7: bits = 8'b00000000;
            endcase
            8'h38: case (row)
                3'd0: bits = 8'b00111100;
                3'd1: bits = 8'b01000010;
                3'd2: bits = 8'b01000010;
                3'd3: bits = 8'b00111100;
                3'd4: bits = 8'b01000010;
                3'd5: bits = 8'b01000010;
                3'd6: bits = 8'b00111100;
                3'd7: bits = 8'b00000000;
            endcase
            8'h39: case (row)
                3'd0: bits = 8'b00111100;
                3'd1: bits = 8'b01000010;
                3'd2: bits = 8'b01000010;
                3'd3: bits = 8'b00111110;
                3'd4: bits = 8'b00000010;
                3'd5: bits = 8'b00000100;
                3'd6: bits = 8'b00111000;
                3'd7: bits = 8'b00000000;
            endcase

            // Letters used: A D E G I K L M N O P R S T U V W Y
            8'h41: case (row) // A
                3'd0: bits = 8'b00011000;
                3'd1: bits = 8'b00100100;
                3'd2: bits = 8'b01000010;
                3'd3: bits = 8'b01111110;
                3'd4: bits = 8'b01000010;
                3'd5: bits = 8'b01000010;
                3'd6: bits = 8'b01000010;
                3'd7: bits = 8'b00000000;
            endcase
            8'h44: case (row) // D
                3'd0: bits = 8'b01111100;
                3'd1: bits = 8'b01000010;
                3'd2: bits = 8'b01000010;
                3'd3: bits = 8'b01000010;
                3'd4: bits = 8'b01000010;
                3'd5: bits = 8'b01000010;
                3'd6: bits = 8'b01111100;
                3'd7: bits = 8'b00000000;
            endcase
            8'h45: case (row) // E
                3'd0: bits = 8'b01111110;
                3'd1: bits = 8'b01000000;
                3'd2: bits = 8'b01000000;
                3'd3: bits = 8'b01111100;
                3'd4: bits = 8'b01000000;
                3'd5: bits = 8'b01000000;
                3'd6: bits = 8'b01111110;
                3'd7: bits = 8'b00000000;
            endcase
            8'h47: case (row) // G
                3'd0: bits = 8'b00111100;
                3'd1: bits = 8'b01000010;
                3'd2: bits = 8'b01000000;
                3'd3: bits = 8'b01001110;
                3'd4: bits = 8'b01000010;
                3'd5: bits = 8'b01000010;
                3'd6: bits = 8'b00111100;
                3'd7: bits = 8'b00000000;
            endcase
            8'h49: case (row) // I
                3'd0: bits = 8'b00111100;
                3'd1: bits = 8'b00011000;
                3'd2: bits = 8'b00011000;
                3'd3: bits = 8'b00011000;
                3'd4: bits = 8'b00011000;
                3'd5: bits = 8'b00011000;
                3'd6: bits = 8'b00111100;
                3'd7: bits = 8'b00000000;
            endcase
            8'h4B: case (row) // K
                3'd0: bits = 8'b01000010;
                3'd1: bits = 8'b01000100;
                3'd2: bits = 8'b01001000;
                3'd3: bits = 8'b01110000;
                3'd4: bits = 8'b01001000;
                3'd5: bits = 8'b01000100;
                3'd6: bits = 8'b01000010;
                3'd7: bits = 8'b00000000;
            endcase
            8'h4C: case (row) // L
                3'd0: bits = 8'b01000000;
                3'd1: bits = 8'b01000000;
                3'd2: bits = 8'b01000000;
                3'd3: bits = 8'b01000000;
                3'd4: bits = 8'b01000000;
                3'd5: bits = 8'b01000000;
                3'd6: bits = 8'b01111110;
                3'd7: bits = 8'b00000000;
            endcase
            8'h4D: case (row) // M
                3'd0: bits = 8'b01000010;
                3'd1: bits = 8'b01100110;
                3'd2: bits = 8'b01011010;
                3'd3: bits = 8'b01000010;
                3'd4: bits = 8'b01000010;
                3'd5: bits = 8'b01000010;
                3'd6: bits = 8'b01000010;
                3'd7: bits = 8'b00000000;
            endcase
            8'h4E: case (row) // N
                3'd0: bits = 8'b01000010;
                3'd1: bits = 8'b01100010;
                3'd2: bits = 8'b01010010;
                3'd3: bits = 8'b01001010;
                3'd4: bits = 8'b01000110;
                3'd5: bits = 8'b01000010;
                3'd6: bits = 8'b01000010;
                3'd7: bits = 8'b00000000;
            endcase
            8'h4F: case (row) // O
                3'd0: bits = 8'b00111100;
                3'd1: bits = 8'b01000010;
                3'd2: bits = 8'b01000010;
                3'd3: bits = 8'b01000010;
                3'd4: bits = 8'b01000010;
                3'd5: bits = 8'b01000010;
                3'd6: bits = 8'b00111100;
                3'd7: bits = 8'b00000000;
            endcase
            8'h50: case (row) // P
                3'd0: bits = 8'b01111100;
                3'd1: bits = 8'b01000010;
                3'd2: bits = 8'b01000010;
                3'd3: bits = 8'b01111100;
                3'd4: bits = 8'b01000000;
                3'd5: bits = 8'b01000000;
                3'd6: bits = 8'b01000000;
                3'd7: bits = 8'b00000000;
            endcase
            8'h52: case (row) // R
                3'd0: bits = 8'b01111100;
                3'd1: bits = 8'b01000010;
                3'd2: bits = 8'b01000010;
                3'd3: bits = 8'b01111100;
                3'd4: bits = 8'b01001000;
                3'd5: bits = 8'b01000100;
                3'd6: bits = 8'b01000010;
                3'd7: bits = 8'b00000000;
            endcase
            8'h53: case (row) // S
                3'd0: bits = 8'b00111110;
                3'd1: bits = 8'b01000000;
                3'd2: bits = 8'b01000000;
                3'd3: bits = 8'b00111100;
                3'd4: bits = 8'b00000010;
                3'd5: bits = 8'b00000010;
                3'd6: bits = 8'b01111100;
                3'd7: bits = 8'b00000000;
            endcase
            8'h54: case (row) // T
                3'd0: bits = 8'b01111110;
                3'd1: bits = 8'b00011000;
                3'd2: bits = 8'b00011000;
                3'd3: bits = 8'b00011000;
                3'd4: bits = 8'b00011000;
                3'd5: bits = 8'b00011000;
                3'd6: bits = 8'b00011000;
                3'd7: bits = 8'b00000000;
            endcase
            8'h55: case (row) // U
                3'd0: bits = 8'b01000010;
                3'd1: bits = 8'b01000010;
                3'd2: bits = 8'b01000010;
                3'd3: bits = 8'b01000010;
                3'd4: bits = 8'b01000010;
                3'd5: bits = 8'b01000010;
                3'd6: bits = 8'b00111100;
                3'd7: bits = 8'b00000000;
            endcase
            8'h56: case (row) // V
                3'd0: bits = 8'b01000010;
                3'd1: bits = 8'b01000010;
                3'd2: bits = 8'b01000010;
                3'd3: bits = 8'b01000010;
                3'd4: bits = 8'b00100100;
                3'd5: bits = 8'b00100100;
                3'd6: bits = 8'b00011000;
                3'd7: bits = 8'b00000000;
            endcase
            8'h57: case (row) // W
                3'd0: bits = 8'b01000010;
                3'd1: bits = 8'b01000010;
                3'd2: bits = 8'b01000010;
                3'd3: bits = 8'b01011010;
                3'd4: bits = 8'b01011010;
                3'd5: bits = 8'b01100110;
                3'd6: bits = 8'b01000010;
                3'd7: bits = 8'b00000000;
            endcase
            8'h59: case (row) // Y
                3'd0: bits = 8'b01000010;
                3'd1: bits = 8'b00100100;
                3'd2: bits = 8'b00011000;
                3'd3: bits = 8'b00011000;
                3'd4: bits = 8'b00011000;
                3'd5: bits = 8'b00011000;
                3'd6: bits = 8'b00011000;
                3'd7: bits = 8'b00000000;
            endcase

            default: bits = 8'h00;
        endcase
    end
endmodule