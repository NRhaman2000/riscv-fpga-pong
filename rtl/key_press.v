// key_press.v
// Converts active-low KEY into a 1-cycle press pulse.
// DE10-Lite KEYs are already hardware-debounced on-board.

module key_press (
    input  clk,
    input  reset_n,
    input  key_n,
    output reg press_pulse
);
    wire key_sync;
    sync_2ff u_sync (.clk(clk), .reset_n(reset_n), .d(key_n), .q(key_sync));

    reg prev;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            prev        <= 1'b1;
            press_pulse <= 1'b0;
        end else begin
            press_pulse <= (prev == 1'b1) && (key_sync == 1'b0);
            prev        <= key_sync;
        end
    end
endmodule