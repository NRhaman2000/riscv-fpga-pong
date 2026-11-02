// pong_engine_lives_score.v
// SINGLE PLAYER + RIGHT WALL
// - Left paddle controlled by CPU (MMIO), applied only on game_tick for perfect frames
// - Right side is a wall (always bounces)
// - Lives: 3 misses at left => GAME OVER
// - Score: +1 per player hit => WIN at 99999

module pong_engine_lives_score (
    input        clk,
    input        reset_n,
    input        start_pulse,
    input        enable,
    input        game_tick,

    input        cpu_paddle_we,
    input  [9:0] cpu_paddle_y,

    output reg [9:0] left_paddle_y,
    output reg [9:0] right_paddle_y,   // unused (kept)
    output reg [9:0] ball_x,
    output reg [9:0] ball_y,

    output reg [1:0]  lives,
    output reg [19:0] score_bcd,

    output reg game_over,
    output reg win,

    output reg hit_pulse,
    output reg miss_pulse,
    output reg gameover_pulse,
    output reg win_pulse
);

    localparam [9:0] BORDER10       = 10'd4;

    localparam [9:0] LEFT_X10       = 10'd20;
    localparam [9:0] PADDLE_W10     = 10'd8;
    localparam [9:0] PADDLE_H10     = 10'd80;
    localparam [9:0] PADDLE_MAX_Y10 = 10'd396;

    localparam [9:0] BALL_S10       = 10'd8;
    localparam [9:0] BALL_X0_10     = 10'd316;
    localparam [9:0] BALL_Y0_10     = 10'd236;
    localparam [9:0] BALL_MAX_Y10   = 10'd468;

    localparam [9:0] STEP_X10       = 10'd4;
    localparam [9:0] STEP_Y10       = 10'd3;

    localparam [9:0] RIGHT_BOUNCE_X10 = 10'd632; // 640-8
    localparam [9:0] LEFT_FACE_X10    = 10'd28;  // 20+8
    localparam [9:0] LEFT_CHECK_X10   = 10'd32;  // 28+4
    localparam [9:0] LEFT_MISS_X10    = 10'd8;   // 4+4

    reg dx_right;
    reg dy_down;

    reg [9:0] cpu_paddle_y_buf;

    function [9:0] clamp_paddle;
        input [9:0] y_in;
        begin
            if (y_in < BORDER10) clamp_paddle = BORDER10;
            else if (y_in > PADDLE_MAX_Y10) clamp_paddle = PADDLE_MAX_Y10;
            else clamp_paddle = y_in;
        end
    endfunction

    function overlap_y;
        input [9:0] obj_y;
        input [9:0] obj_h;
        input [9:0] pad_y;
        reg   [10:0] obj_end;
        reg   [10:0] pad_end;
        begin
            obj_end = obj_y + obj_h;
            pad_end = pad_y + PADDLE_H10;
            overlap_y = (obj_end >= pad_y) && (obj_y <= pad_end);
        end
    endfunction

    // BCD increment score 00000..99999
    reg [3:0] t0, t1, t2, t3, t4;
    reg carry;

    task do_score_inc;
        begin
            t0 = score_bcd[3:0];
            t1 = score_bcd[7:4];
            t2 = score_bcd[11:8];
            t3 = score_bcd[15:12];
            t4 = score_bcd[19:16];

            carry = 1'b1;

            if (carry) begin
                if (t0 == 4'd9) begin t0 = 4'd0; carry = 1'b1; end
                else begin t0 = t0 + 4'd1; carry = 1'b0; end
            end
            if (carry) begin
                if (t1 == 4'd9) begin t1 = 4'd0; carry = 1'b1; end
                else begin t1 = t1 + 4'd1; carry = 1'b0; end
            end
            if (carry) begin
                if (t2 == 4'd9) begin t2 = 4'd0; carry = 1'b1; end
                else begin t2 = t2 + 4'd1; carry = 1'b0; end
            end
            if (carry) begin
                if (t3 == 4'd9) begin t3 = 4'd0; carry = 1'b1; end
                else begin t3 = t3 + 4'd1; carry = 1'b0; end
            end
            if (carry) begin
                if (t4 == 4'd9) begin t4 = 4'd9; carry = 1'b0; end
                else begin t4 = t4 + 4'd1; carry = 1'b0; end
            end

            score_bcd <= {t4,t3,t2,t1,t0};

            if ({t4,t3,t2,t1,t0} == 20'h99999) begin
                win <= 1'b1;
                win_pulse <= 1'b1;
            end
        end
    endtask

    task reset_game;
        begin
            left_paddle_y    <= 10'd200;
            right_paddle_y   <= 10'd0;
            cpu_paddle_y_buf <= 10'd200;

            ball_x <= BALL_X0_10;
            ball_y <= BALL_Y0_10;

            dx_right <= 1'b1;
            dy_down  <= 1'b1;

            lives     <= 2'd3;
            score_bcd <= 20'h00000;

            game_over <= 1'b0;
            win       <= 1'b0;
        end
    endtask

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            reset_game();
            hit_pulse      <= 1'b0;
            miss_pulse     <= 1'b0;
            gameover_pulse <= 1'b0;
            win_pulse      <= 1'b0;
        end else begin
            hit_pulse      <= 1'b0;
            miss_pulse     <= 1'b0;
            gameover_pulse <= 1'b0;
            win_pulse      <= 1'b0;

            if (start_pulse)
                reset_game();

            if (cpu_paddle_we)
                cpu_paddle_y_buf <= cpu_paddle_y;

            // applied visible paddle on tick (frame-stable)
            if (enable && game_tick && !game_over && !win)
                left_paddle_y <= clamp_paddle(cpu_paddle_y_buf);

            if (!enable || game_over || win) begin
                // frozen
            end else if (game_tick) begin

                // Y movement
                if (dy_down) begin
                    if (ball_y >= (BALL_MAX_Y10 - STEP_Y10)) begin
                        ball_y  <= BALL_MAX_Y10;
                        dy_down <= 1'b0;
                    end else
                        ball_y <= ball_y + STEP_Y10;
                end else begin
                    if (ball_y <= (BORDER10 + STEP_Y10)) begin
                        ball_y  <= BORDER10;
                        dy_down <= 1'b1;
                    end else
                        ball_y <= ball_y - STEP_Y10;
                end

                // X movement
                if (dx_right) begin
                    // right wall bounce
                    if (ball_x >= (RIGHT_BOUNCE_X10 - STEP_X10)) begin
                        ball_x   <= RIGHT_BOUNCE_X10;
                        dx_right <= 1'b0;
                    end else
                        ball_x <= ball_x + STEP_X10;

                end else begin
                    // toward player
                    if (ball_x <= LEFT_CHECK_X10) begin
                        if (overlap_y(ball_y, BALL_S10, left_paddle_y)) begin
                            ball_x    <= LEFT_FACE_X10;
                            dx_right  <= 1'b1;
                            hit_pulse <= 1'b1;
                            if (!win) do_score_inc();

                        end else if (ball_x <= LEFT_MISS_X10) begin
                            if (lives == 2'd1) begin
                                lives <= 2'd0;
                                game_over <= 1'b1;
                                gameover_pulse <= 1'b1;
                            end else begin
                                lives <= lives - 2'd1;
                                miss_pulse <= 1'b1;

                                ball_x <= BALL_X0_10;
                                ball_y <= BALL_Y0_10;
                                dx_right <= 1'b1;
                                dy_down  <= 1'b1;
                            end
                        end else
                            ball_x <= ball_x - STEP_X10;
                    end else
                        ball_x <= ball_x - STEP_X10;
                end
            end
        end
    end

endmodule