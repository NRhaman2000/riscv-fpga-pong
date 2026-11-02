// vga_sync_640x480.v
// Standard 640x480@60Hz timing.
// frame_tick pulses for 1 clock at the start of each frame.

module vga_sync_640x480 (
    input        clk,
    input        reset_n,
    output reg [9:0] x,
    output reg [9:0] y,
    output       hsync,
    output       vsync,
    output       video_on,
    output       frame_tick
);
    localparam integer H_VISIBLE = 640;
    localparam integer H_FRONT   = 16;
    localparam integer H_SYNC    = 96;
    localparam integer H_BACK    = 48;
    localparam integer H_TOTAL   = 800;

    localparam integer V_VISIBLE = 480;
    localparam integer V_FRONT   = 10;
    localparam integer V_SYNC    = 2;
    localparam integer V_BACK    = 33;
    localparam integer V_TOTAL   = 525;

    reg [9:0] h_count;
    reg [9:0] v_count;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            h_count <= 10'd0;
            v_count <= 10'd0;
        end else begin
            if (h_count == H_TOTAL - 1) begin
                h_count <= 10'd0;
                if (v_count == V_TOTAL - 1)
                    v_count <= 10'd0;
                else
                    v_count <= v_count + 10'd1;
            end else begin
                h_count <= h_count + 10'd1;
            end
        end
    end

    always @(*) begin
        x = h_count;
        y = v_count;
    end

    assign video_on = (h_count < H_VISIBLE) && (v_count < V_VISIBLE);

    // Active-low sync pulses
    assign hsync = ~((h_count >= (H_VISIBLE + H_FRONT)) &&
                     (h_count <  (H_VISIBLE + H_FRONT + H_SYNC)));

    assign vsync = ~((v_count >= (V_VISIBLE + V_FRONT)) &&
                     (v_count <  (V_VISIBLE + V_FRONT + V_SYNC)));

    // 1-cycle pulse at start of frame
    assign frame_tick = (h_count == 10'd0) && (v_count == 10'd0);

endmodule