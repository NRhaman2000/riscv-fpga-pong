// rv32i_min.v
// Minimal RV32I subset: LUI, ADDI, ANDI, LW, SW, BEQ, JAL

module rv32i_min (
    input         clk,
    input         reset_n,

    input  [31:0] instr_i,
    output reg [31:0] pc_o,

    output reg [31:0] data_addr_o,
    output reg [31:0] data_wdata_o,
    output reg        data_we_o,
    output reg        data_re_o,
    input  [31:0] data_rdata_i
);
    reg [31:0] regs[0:31];
    integer i;

    wire [31:0] instr  = instr_i;
    wire [6:0]  opcode = instr[6:0];
    wire [2:0]  funct3 = instr[14:12];
    wire [4:0]  rd     = instr[11:7];
    wire [4:0]  rs1    = instr[19:15];
    wire [4:0]  rs2    = instr[24:20];

    wire [31:0] rs1_val = (rs1 == 0) ? 32'd0 : regs[rs1];
    wire [31:0] rs2_val = (rs2 == 0) ? 32'd0 : regs[rs2];

    wire [31:0] imm_i = {{20{instr[31]}}, instr[31:20]};
    wire [31:0] imm_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};
    wire [31:0] imm_b = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
    wire [31:0] imm_u = {instr[31:12], 12'b0};
    wire [31:0] imm_j = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};

    wire is_lui   = (opcode == 7'b0110111);
    wire is_opimm = (opcode == 7'b0010011);
    wire is_lw    = (opcode == 7'b0000011) && (funct3 == 3'b010);
    wire is_sw    = (opcode == 7'b0100011) && (funct3 == 3'b010);
    wire is_beq   = (opcode == 7'b1100011) && (funct3 == 3'b000);
    wire is_jal   = (opcode == 7'b1101111);

    wire is_addi  = is_opimm && (funct3 == 3'b000);
    wire is_andi  = is_opimm && (funct3 == 3'b111);

    always @(*) begin
        data_addr_o  = 32'd0;
        data_wdata_o = rs2_val;
        data_we_o    = 1'b0;
        data_re_o    = 1'b0;

        if (is_lw) begin
            data_addr_o = rs1_val + imm_i;
            data_re_o   = 1'b1;
        end else if (is_sw) begin
            data_addr_o = rs1_val + imm_s;
            data_we_o   = 1'b1;
        end
    end

    reg rf_we;
    reg [31:0] rf_wdata;

    always @(*) begin
        rf_we    = 1'b0;
        rf_wdata = 32'd0;

        if (is_lui) begin
            rf_we    = 1'b1;
            rf_wdata = imm_u;
        end else if (is_addi) begin
            rf_we    = 1'b1;
            rf_wdata = rs1_val + imm_i;
        end else if (is_andi) begin
            rf_we    = 1'b1;
            rf_wdata = rs1_val & imm_i;
        end else if (is_lw) begin
            rf_we    = 1'b1;
            rf_wdata = data_rdata_i;
        end else if (is_jal) begin
            rf_we    = 1'b1;
            rf_wdata = pc_o + 32'd4;
        end
    end

    reg [31:0] next_pc;

    always @(*) begin
        next_pc = pc_o + 32'd4;

        if (is_beq && (rs1_val == rs2_val))
            next_pc = pc_o + imm_b;

        if (is_jal)
            next_pc = pc_o + imm_j;
    end

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            pc_o <= 32'd0;
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'd0;
        end else begin
            pc_o <= next_pc;

            if (rf_we && (rd != 0))
                regs[rd] <= rf_wdata;

            regs[0] <= 32'd0;
        end
    end
endmodule