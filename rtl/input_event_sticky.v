// input_event_sticky.v
// Creates tick-sampled movement events for CPU.
// One step per sample_tick while held (up_only/down_only).

module input_event_sticky (
    input         clk,
    input         reset_n,
    input         sample_tick,
    input         up_level,
    input         down_level,
    input         rd_pulse,
    output [31:0] data_o
);
    reg [1:0] sticky;
    wire [1:0] new_bits = {down_level, up_level};

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            sticky <= 2'b00;
        end else begin
            if (sample_tick)
                sticky <= sticky | new_bits;

            if (rd_pulse) begin
                if (sample_tick)
                    sticky <= new_bits;
                else
                    sticky <= 2'b00;
            end
        end
    end

    assign data_o = {30'd0, sticky[1], sticky[0]};
endmodule