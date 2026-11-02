// instr_rom.v
// Reads inputs at 0x8000_0000 (bit0=up, bit1=down) and writes paddle Y to 0x8000_0004.

module instr_rom (
    input  [31:0] addr_i,
    output reg [31:0] data_o
);
    always @(*) begin
        case (addr_i[31:2])
            30'd0:  data_o = 32'h800000B7; // lui  x1,0x80000
            30'd1:  data_o = 32'h00408113; // addi x2,x1,4
            30'd2:  data_o = 32'h0C800193; // addi x3,x0,200
            30'd3:  data_o = 32'h00312023; // sw   x3,0(x2)

            30'd4:  data_o = 32'h0000A203; // lw   x4,0(x1)
            30'd5:  data_o = 32'h00127293; // andi x5,x4,1   (up)
            30'd6:  data_o = 32'h00028463; // beq  x5,x0,+8
            30'd7:  data_o = 32'hFFC18193; // addi x3,x3,-4

            30'd8:  data_o = 32'h00227293; // andi x5,x4,2   (down)
            30'd9:  data_o = 32'h00028463; // beq  x5,x0,+8
            30'd10: data_o = 32'h00418193; // addi x3,x3,4

            30'd11: data_o = 32'h00312023; // sw   x3,0(x2)
            30'd12: data_o = 32'hFE1FF06F; // jal  x0,-32

            default: data_o = 32'h00000013; // nop
        endcase
    end
endmodule