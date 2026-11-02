// sync_2ff.v
// 2-flop synchronizer.
// Reset to '1' so active-low inputs (KEY/buttons) don't create false presses after reset.

module sync_2ff (
    input  clk,
    input  reset_n,
    input  d,
    output reg q
);
    reg q1;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            q1 <= 1'b1;
            q  <= 1'b1;
        end else begin
            q1 <= d;
            q  <= q1;
        end
    end
endmodule