// de10lite_pong_top.v  (TOP LEVEL - DAC AUDIO VERSION)
//
// Uses ALTPLL (~25.175 MHz) for VGA pixel clock.
//
// Audio output is now 8-bit unsigned DAC data for an external R-2R ladder.
// Feed GPIO_DAC[7:0] into your external resistor ladder, then to the LM386 module.

module de10lite_pong_top (
    input         MAX10_CLK1_50,
    input  [1:0]  KEY,
    input  [9:0]  SW,

    input         GPIO_UP_RAW,
    input         GPIO_DOWN_RAW,

    output [7:0]  GPIO_DAC,

    output [9:0]  LEDR,

    output [6:0]  HEX0,
    output [6:0]  HEX1,
    output [6:0]  HEX2,
    output [6:0]  HEX3,
    output [6:0]  HEX4,
    output [6:0]  HEX5,

    output [3:0]  VGA_R,
    output [3:0]  VGA_G,
    output [3:0]  VGA_B,
    output        VGA_HS,
    output        VGA_VS
);

    wire reset_n = ~SW[9];

    wire clk25;
    pll u_pll (
        .inclk0 (MAX10_CLK1_50),
        .c0     (clk25)
    );

    wire key0_pulse;
    wire key1_pulse;

    key_press u_key0 (
        .clk         (clk25),
        .reset_n     (reset_n),
        .key_n       (KEY[0]),
        .press_pulse (key0_pulse)
    );

    key_press u_key1 (
        .clk         (clk25),
        .reset_n     (reset_n),
        .key_n       (KEY[1]),
        .press_pulse (key1_pulse)
    );

    wire up_sync;
    wire down_sync;

    sync_2ff u_up_sync (
        .clk     (clk25),
        .reset_n (reset_n),
        .d       (GPIO_UP_RAW),
        .q       (up_sync)
    );

    sync_2ff u_dn_sync (
        .clk     (clk25),
        .reset_n (reset_n),
        .d       (GPIO_DOWN_RAW),
        .q       (down_sync)
    );

    
    wire up_pressed   = ~up_sync;
    wire down_pressed = ~down_sync;

    // If tested debounced output is ACTIVE-HIGH, we have to change to:
    // wire up_pressed   = up_sync;
    // wire down_pressed = down_sync;

    wire up_only   = up_pressed   & ~down_pressed;
    wire down_only = down_pressed & ~up_pressed;

    wire frame_tick;

    localparam S_TITLE     = 3'd0;
    localparam S_COUNTDOWN = 3'd1;
    localparam S_PLAYING   = 3'd2;
    localparam S_PAUSED    = 3'd3;
    localparam S_GAMEOVER  = 3'd4;
    localparam S_WIN       = 3'd5;

    reg [2:0] state;
    reg [1:0] countdown_val;
    reg [5:0] sec_tick_cnt;
    reg       start_pulse;

    wire playing = (state == S_PLAYING);

    reg [5:0] blink_cnt;
    reg       blink_on;

    always @(posedge clk25 or negedge reset_n) begin
        if (!reset_n) begin
            blink_cnt <= 6'd0;
            blink_on  <= 1'b1;
        end else if (frame_tick) begin
            if (blink_cnt == 6'd29) begin
                blink_cnt <= 6'd0;
                blink_on  <= ~blink_on;
            end else begin
                blink_cnt <= blink_cnt + 6'd1;
            end
        end
    end

    wire blink_score   = (state == S_GAMEOVER) || (state == S_WIN);
    wire score_visible = blink_score ? blink_on : 1'b1;

    wire [9:0]  left_paddle_y;
    wire [9:0]  right_paddle_y;
    wire [9:0]  ball_x;
    wire [9:0]  ball_y;
    wire [1:0]  lives;
    wire [19:0] score_bcd;

    wire engine_gameover;
    wire engine_win;

    wire hit_pulse;
    wire miss_pulse;
    wire gameover_pulse;
    wire win_pulse;

    always @(posedge clk25 or negedge reset_n) begin
        if (!reset_n) begin
            state         <= S_TITLE;
            countdown_val <= 2'd0;
            sec_tick_cnt  <= 6'd0;
            start_pulse   <= 1'b0;
        end else begin
            start_pulse <= 1'b0;

            case (state)
                S_TITLE: begin
                    countdown_val <= 2'd0;
                    sec_tick_cnt  <= 6'd0;
                    if (key1_pulse) begin
                        state         <= S_COUNTDOWN;
                        countdown_val <= 2'd3;
                        sec_tick_cnt  <= 6'd0;
                        start_pulse   <= 1'b1;
                    end
                end

                S_COUNTDOWN: begin
                    if (frame_tick) begin
                        if (sec_tick_cnt == 6'd59) begin
                            sec_tick_cnt <= 6'd0;
                            if (countdown_val > 2'd1) begin
                                countdown_val <= countdown_val - 2'd1;
                            end else begin
                                countdown_val <= 2'd0;
                                state <= S_PLAYING;
                            end
                        end else begin
                            sec_tick_cnt <= sec_tick_cnt + 6'd1;
                        end
                    end
                end

                S_PLAYING: begin
                    countdown_val <= 2'd0;
                    sec_tick_cnt  <= 6'd0;

                    if (engine_win)
                        state <= S_WIN;
                    else if (engine_gameover)
                        state <= S_GAMEOVER;
                    else if (key0_pulse)
                        state <= S_PAUSED;
                end

                S_PAUSED: begin
                    countdown_val <= 2'd0;
                    sec_tick_cnt  <= 6'd0;

                    if (key1_pulse) begin
                        state <= S_PLAYING;
                    end else if (key0_pulse) begin
                        state         <= S_COUNTDOWN;
                        countdown_val <= 2'd3;
                        sec_tick_cnt  <= 6'd0;
                        start_pulse   <= 1'b1;
                    end
                end

                S_GAMEOVER: begin
                    countdown_val <= 2'd0;
                    sec_tick_cnt  <= 6'd0;
                    if (key1_pulse) begin
                        state         <= S_COUNTDOWN;
                        countdown_val <= 2'd3;
                        sec_tick_cnt  <= 6'd0;
                        start_pulse   <= 1'b1;
                    end
                end

                S_WIN: begin
                    countdown_val <= 2'd0;
                    sec_tick_cnt  <= 6'd0;
                    if (key1_pulse) begin
                        state         <= S_COUNTDOWN;
                        countdown_val <= 2'd3;
                        sec_tick_cnt  <= 6'd0;
                        start_pulse   <= 1'b1;
                    end
                end

                default: begin
                    state <= S_TITLE;
                end
            endcase
        end
    end

    reg [3:0] cpu_rst_cnt;
    reg       cpu_soft_reset;

    always @(posedge clk25 or negedge reset_n) begin
        if (!reset_n) begin
            cpu_rst_cnt    <= 4'd0;
            cpu_soft_reset <= 1'b0;
        end else begin
            if (start_pulse) begin
                cpu_rst_cnt    <= 4'd10;
                cpu_soft_reset <= 1'b1;
            end else if (cpu_rst_cnt != 4'd0) begin
                cpu_rst_cnt    <= cpu_rst_cnt - 4'd1;
                cpu_soft_reset <= 1'b1;
            end else begin
                cpu_soft_reset <= 1'b0;
            end
        end
    end

    wire cpu_reset_n = reset_n & ~cpu_soft_reset;

    wire [31:0] cpu_pc;
    wire [31:0] cpu_instr;

    instr_rom u_rom (
        .addr_i (cpu_pc),
        .data_o (cpu_instr)
    );

    wire [31:0] cpu_addr;
    wire [31:0] cpu_wdata;
    wire        cpu_we;
    wire        cpu_re;
    wire [31:0] cpu_rdata;

    rv32i_min u_cpu (
        .clk          (clk25),
        .reset_n      (cpu_reset_n),
        .instr_i      (cpu_instr),
        .pc_o         (cpu_pc),
        .data_addr_o  (cpu_addr),
        .data_wdata_o (cpu_wdata),
        .data_we_o    (cpu_we),
        .data_re_o    (cpu_re),
        .data_rdata_i (cpu_rdata)
    );

    localparam [31:0] INPUT_ADDR  = 32'h8000_0000;
    localparam [31:0] PADDLE_ADDR = 32'h8000_0004;

    wire sample_tick = frame_tick & playing;
    wire input_rd_pulse = cpu_re && (cpu_addr == INPUT_ADDR);
    wire [31:0] input_data;

    input_event_sticky u_input (
        .clk         (clk25),
        .reset_n     (reset_n),
        .sample_tick (sample_tick),
        .up_level    (up_only),
        .down_level  (down_only),
        .rd_pulse    (input_rd_pulse),
        .data_o      (input_data)
    );

    assign cpu_rdata = (cpu_addr == INPUT_ADDR) ? input_data : 32'd0;

    wire cpu_paddle_we_raw = cpu_we && (cpu_addr == PADDLE_ADDR);
    wire cpu_paddle_we     = cpu_paddle_we_raw & playing;

    pong_engine_lives_score u_engine (
        .clk            (clk25),
        .reset_n        (reset_n),
        .start_pulse    (start_pulse),
        .enable         (playing),
        .game_tick      (frame_tick),
        .cpu_paddle_we  (cpu_paddle_we),
        .cpu_paddle_y   (cpu_wdata[9:0]),
        .left_paddle_y  (left_paddle_y),
        .right_paddle_y (right_paddle_y),
        .ball_x         (ball_x),
        .ball_y         (ball_y),
        .lives          (lives),
        .score_bcd      (score_bcd),
        .game_over      (engine_gameover),
        .win            (engine_win),
        .hit_pulse      (hit_pulse),
        .miss_pulse     (miss_pulse),
        .gameover_pulse (gameover_pulse),
        .win_pulse      (win_pulse)
    );

    // Extra audio events derived in the top level
    reg        countdown_pulse;
    reg        start_go_pulse;
    reg        score5_pulse;
    reg [19:0] prev_score_bcd;

    always @(posedge clk25 or negedge reset_n) begin
        if (!reset_n) begin
            countdown_pulse <= 1'b0;
            start_go_pulse  <= 1'b0;
            score5_pulse    <= 1'b0;
            prev_score_bcd  <= 20'h00000;
        end else begin
            countdown_pulse <= 1'b0;
            start_go_pulse  <= 1'b0;
            score5_pulse    <= 1'b0;

            // beep for countdown 3
            if (start_pulse)
                countdown_pulse <= 1'b1;

            // beep for countdown 2 and 1, then GO sound when play begins
            if ((state == S_COUNTDOWN) && frame_tick && (sec_tick_cnt == 6'd59)) begin
                if (countdown_val > 2'd1)
                    countdown_pulse <= 1'b1;
                else
                    start_go_pulse <= 1'b1;
            end

            // sound every time score reaches 5,10,15,...
            if (score_bcd != prev_score_bcd) begin
                if ((score_bcd != 20'h00000) &&
                    ((score_bcd[3:0] == 4'd5) || (score_bcd[3:0] == 4'd0))) begin
                    score5_pulse <= 1'b1;
                end
                prev_score_bcd <= score_bcd;
            end
        end
    end

    dac_audio_r2r #(
        .CLK_HZ    (25175000),
        .SAMPLE_HZ (48000)
    ) u_audio (
        .clk             (clk25),
        .reset_n         (reset_n),
        .hit_pulse       (hit_pulse),
        .miss_pulse      (miss_pulse),
        .gameover_pulse  (gameover_pulse),
        .win_pulse       (win_pulse),
        .countdown_pulse (countdown_pulse),
        .start_go_pulse  (start_go_pulse),
        .score5_pulse    (score5_pulse),
        .dac_out         (GPIO_DAC)
    );

    pong_video u_video (
        .clk25         (clk25),
        .reset_n       (reset_n),
        .state         (state),
        .countdown_val (countdown_val),
        .left_paddle_y (left_paddle_y),
        .ball_x        (ball_x),
        .ball_y        (ball_y),
        .frame_tick    (frame_tick),
        .VGA_R         (VGA_R),
        .VGA_G         (VGA_G),
        .VGA_B         (VGA_B),
        .VGA_HS        (VGA_HS),
        .VGA_VS        (VGA_VS)
    );

    wire [3:0] d0 = score_bcd[3:0];
    wire [3:0] d1 = score_bcd[7:4];
    wire [3:0] d2 = score_bcd[11:8];
    wire [3:0] d3 = score_bcd[15:12];
    wire [3:0] d4 = score_bcd[19:16];

    wire [6:0] seg0;
    wire [6:0] seg1;
    wire [6:0] seg2;
    wire [6:0] seg3;
    wire [6:0] seg4;
    wire [6:0] seg5;

    seg7 u_hex0 (.value(d0),             .seg(seg0));
    seg7 u_hex1 (.value(d1),             .seg(seg1));
    seg7 u_hex2 (.value(d2),             .seg(seg2));
    seg7 u_hex3 (.value(d3),             .seg(seg3));
    seg7 u_hex4 (.value(d4),             .seg(seg4));
    seg7 u_hex5 (.value({2'b00, lives}), .seg(seg5));

    assign HEX0 = score_visible ? seg0 : 7'b1111111;
    assign HEX1 = score_visible ? seg1 : 7'b1111111;
    assign HEX2 = score_visible ? seg2 : 7'b1111111;
    assign HEX3 = score_visible ? seg3 : 7'b1111111;
    assign HEX4 = score_visible ? seg4 : 7'b1111111;
    assign HEX5 = seg5;

    assign LEDR[0] = up_pressed;
    assign LEDR[1] = down_pressed;
    assign LEDR[2] = up_only;
    assign LEDR[3] = down_only;
    assign LEDR[4] = (state == S_TITLE);
    assign LEDR[5] = (state == S_COUNTDOWN);
    assign LEDR[6] = (state == S_PLAYING);
    assign LEDR[7] = (state == S_PAUSED);
    assign LEDR[8] = (state == S_GAMEOVER);
    assign LEDR[9] = (state == S_WIN);

endmodule