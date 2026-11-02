// dac_audio_r2r.v
// 8-bit DAC audio generator for an external R-2R ladder.
//
// Output is unsigned 8-bit audio centered around midscale (128).
// Feed DAC_OUT[7:0] into external 8-bit R-2R ladder, then into
// the LM386 amplifier input through the analog stage on the breadboard.
//
// Event sounds:
//   hit       -> short high beep
//   miss      -> medium low beep
//   gameover  -> two descending notes
//   win       -> three ascending notes

module dac_audio_r2r #(
    parameter integer CLK_HZ    = 25175000,
    parameter integer SAMPLE_HZ = 48000
)(
    input            clk,
    input            reset_n,
    input            hit_pulse,
    input            miss_pulse,
    input            gameover_pulse,
    input            win_pulse,
    input            countdown_pulse,
    input            start_go_pulse,
    input            score5_pulse,
    output reg [7:0] dac_out
);

    localparam integer SAMPLE_DIV = CLK_HZ / SAMPLE_HZ;

    // phase step ~= frequency * 2^24 / SAMPLE_HZ, for SAMPLE_HZ = 48000
    localparam [23:0] STEP_220  = 24'd76896;
    localparam [23:0] STEP_262  = 24'd91556;
    localparam [23:0] STEP_330  = 24'd115343;
    localparam [23:0] STEP_392  = 24'd137014;
    localparam [23:0] STEP_523  = 24'd182802;
    localparam [23:0] STEP_659  = 24'd230337;
    localparam [23:0] STEP_784  = 24'd274028;
    localparam [23:0] STEP_1047 = 24'd365953;
    localparam [23:0] STEP_1319 = 24'd460935;
    localparam [23:0] STEP_1568 = 24'd548056;
    localparam [23:0] STEP_1760 = 24'd615245;

    localparam [3:0] SND_NONE      = 4'd0;
    localparam [3:0] SND_HIT       = 4'd1;
    localparam [3:0] SND_MISS      = 4'd2;
    localparam [3:0] SND_GAMEOVER  = 4'd3;
    localparam [3:0] SND_WIN       = 4'd4;
    localparam [3:0] SND_COUNTDOWN = 4'd5;
    localparam [3:0] SND_START     = 4'd6;
    localparam [3:0] SND_SCORE5    = 4'd7;

    localparam WAVE_TRI    = 1'b0;
    localparam WAVE_SQUARE = 1'b1;

    // durations in 48 kHz samples
    localparam integer DUR_HIT_0   = 2160;   // 45 ms
    localparam integer DUR_MISS_0  = 4320;   // 90 ms
    localparam integer DUR_MISS_1  = 5760;   // 120 ms
    localparam integer DUR_GOV_0   = 5280;   // 110 ms
    localparam integer DUR_GOV_1   = 7200;   // 150 ms
    localparam integer DUR_GOV_2   = 9600;   // 200 ms
    localparam integer DUR_WIN_0   = 3840;   // 80 ms
    localparam integer DUR_WIN_1   = 3840;   // 80 ms
    localparam integer DUR_WIN_2   = 6720;   // 140 ms
    localparam integer DUR_CNT_0   = 4800;   // 100 ms
    localparam integer DUR_START_0 = 3360;   // 70 ms
    localparam integer DUR_START_1 = 6720;   // 140 ms
    localparam integer DUR_SC5_0   = 2400;   // 50 ms
    localparam integer DUR_SC5_1   = 4320;   // 90 ms

    reg [15:0] sample_div_cnt;
    reg [3:0]  sound_kind;
    reg [1:0]  seg_idx;
    reg [23:0] phase_acc;
    reg [23:0] phase_step;
    reg [15:0] seg_samples_left;
    reg [2:0]  volume_shift;
    reg        wave_sel;

    reg [7:0] tri_u;
    reg signed [8:0] wave_s;
    reg signed [8:0] wave_scaled;
    reg signed [9:0] mixed;

    wire sample_tick = (sample_div_cnt == SAMPLE_DIV-1);

    task load_segment;
        input [3:0] new_sound_kind;
        input [1:0] new_seg_idx;
        begin
            sound_kind <= new_sound_kind;
            seg_idx    <= new_seg_idx;
            phase_acc  <= 24'd0;

            case (new_sound_kind)
                SND_HIT: begin
                    phase_step       <= STEP_1319;
                    seg_samples_left <= DUR_HIT_0[15:0];
                    volume_shift     <= 3'd2;
                    wave_sel         <= WAVE_SQUARE;
                end

                SND_MISS: begin
                    if (new_seg_idx == 2'd0) begin
                        phase_step       <= STEP_659;
                        seg_samples_left <= DUR_MISS_0[15:0];
                    end else begin
                        phase_step       <= STEP_392;
                        seg_samples_left <= DUR_MISS_1[15:0];
                    end
                    volume_shift <= 3'd2;
                    wave_sel     <= WAVE_TRI;
                end

                SND_GAMEOVER: begin
                    if (new_seg_idx == 2'd0) begin
                        phase_step       <= STEP_392;
                        seg_samples_left <= DUR_GOV_0[15:0];
                    end else if (new_seg_idx == 2'd1) begin
                        phase_step       <= STEP_330;
                        seg_samples_left <= DUR_GOV_1[15:0];
                    end else begin
                        phase_step       <= STEP_220;
                        seg_samples_left <= DUR_GOV_2[15:0];
                    end
                    volume_shift <= 3'd2;
                    wave_sel     <= WAVE_TRI;
                end

                SND_WIN: begin
                    if (new_seg_idx == 2'd0) begin
                        phase_step       <= STEP_784;
                        seg_samples_left <= DUR_WIN_0[15:0];
                    end else if (new_seg_idx == 2'd1) begin
                        phase_step       <= STEP_1047;
                        seg_samples_left <= DUR_WIN_1[15:0];
                    end else begin
                        phase_step       <= STEP_1319;
                        seg_samples_left <= DUR_WIN_2[15:0];
                    end
                    volume_shift <= 3'd2;
                    wave_sel     <= WAVE_SQUARE;
                end

                SND_COUNTDOWN: begin
                    phase_step       <= STEP_784;
                    seg_samples_left <= DUR_CNT_0[15:0];
                    volume_shift     <= 3'd3;
                    wave_sel         <= WAVE_SQUARE;
                end

                SND_START: begin
                    if (new_seg_idx == 2'd0) begin
                        phase_step       <= STEP_1047;
                        seg_samples_left <= DUR_START_0[15:0];
                    end else begin
                        phase_step       <= STEP_1568;
                        seg_samples_left <= DUR_START_1[15:0];
                    end
                    volume_shift <= 3'd2;
                    wave_sel     <= WAVE_SQUARE;
                end

                SND_SCORE5: begin
                    if (new_seg_idx == 2'd0) begin
                        phase_step       <= STEP_1319;
                        seg_samples_left <= DUR_SC5_0[15:0];
                    end else begin
                        phase_step       <= STEP_1760;
                        seg_samples_left <= DUR_SC5_1[15:0];
                    end
                    volume_shift <= 3'd2;
                    wave_sel     <= WAVE_SQUARE;
                end

                default: begin
                    phase_step       <= 24'd0;
                    seg_samples_left <= 16'd0;
                    volume_shift     <= 3'd7;
                    wave_sel         <= WAVE_TRI;
                end
            endcase
        end
    endtask

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            sample_div_cnt   <= 16'd0;
            sound_kind       <= SND_NONE;
            seg_idx          <= 2'd0;
            phase_acc        <= 24'd0;
            phase_step       <= 24'd0;
            seg_samples_left <= 16'd0;
            volume_shift     <= 3'd2;
            wave_sel         <= WAVE_TRI;
            dac_out          <= 8'd128;
        end else begin
            // priority: win > gameover > start > miss > score5 > countdown > hit
            if (win_pulse) begin
                load_segment(SND_WIN, 2'd0);
            end else if (gameover_pulse) begin
                load_segment(SND_GAMEOVER, 2'd0);
            end else if (start_go_pulse) begin
                load_segment(SND_START, 2'd0);
            end else if (miss_pulse) begin
                load_segment(SND_MISS, 2'd0);
            end else if (score5_pulse) begin
                load_segment(SND_SCORE5, 2'd0);
            end else if (countdown_pulse) begin
                load_segment(SND_COUNTDOWN, 2'd0);
            end else if (hit_pulse) begin
                load_segment(SND_HIT, 2'd0);
            end

            if (sample_tick) begin
                sample_div_cnt <= 16'd0;

                if (sound_kind == SND_NONE) begin
                    dac_out <= 8'd128;
                end else begin
                    phase_acc <= phase_acc + phase_step;

                    if (wave_sel == WAVE_SQUARE) begin
                        if (phase_acc[23])
                            wave_s = 9'sd127;
                        else
                            wave_s = -9'sd127;
                    end else begin
                        if (phase_acc[23])
                            tri_u = ~phase_acc[22:15];
                        else
                            tri_u = phase_acc[22:15];
                        wave_s = {1'b0, tri_u} - 9'sd128;
                    end

                    wave_scaled = wave_s >>> volume_shift;
                    mixed       = 10'sd128 + wave_scaled;

                    if (mixed < 10'sd0)
                        dac_out <= 8'd0;
                    else if (mixed > 10'sd255)
                        dac_out <= 8'd255;
                    else
                        dac_out <= mixed[7:0];

                    if (seg_samples_left > 16'd1) begin
                        seg_samples_left <= seg_samples_left - 16'd1;
                    end else begin
                        case (sound_kind)
                            SND_HIT,
                            SND_COUNTDOWN: begin
                                sound_kind <= SND_NONE;
                                seg_idx    <= 2'd0;
                                phase_step <= 24'd0;
                                dac_out    <= 8'd128;
                            end

                            SND_MISS: begin
                                if (seg_idx == 2'd0)
                                    load_segment(SND_MISS, 2'd1);
                                else begin
                                    sound_kind <= SND_NONE;
                                    seg_idx    <= 2'd0;
                                    phase_step <= 24'd0;
                                    dac_out    <= 8'd128;
                                end
                            end

                            SND_GAMEOVER: begin
                                if (seg_idx == 2'd0)
                                    load_segment(SND_GAMEOVER, 2'd1);
                                else if (seg_idx == 2'd1)
                                    load_segment(SND_GAMEOVER, 2'd2);
                                else begin
                                    sound_kind <= SND_NONE;
                                    seg_idx    <= 2'd0;
                                    phase_step <= 24'd0;
                                    dac_out    <= 8'd128;
                                end
                            end

                            SND_WIN: begin
                                if (seg_idx == 2'd0)
                                    load_segment(SND_WIN, 2'd1);
                                else if (seg_idx == 2'd1)
                                    load_segment(SND_WIN, 2'd2);
                                else begin
                                    sound_kind <= SND_NONE;
                                    seg_idx    <= 2'd0;
                                    phase_step <= 24'd0;
                                    dac_out    <= 8'd128;
                                end
                            end

                            SND_START: begin
                                if (seg_idx == 2'd0)
                                    load_segment(SND_START, 2'd1);
                                else begin
                                    sound_kind <= SND_NONE;
                                    seg_idx    <= 2'd0;
                                    phase_step <= 24'd0;
                                    dac_out    <= 8'd128;
                                end
                            end

                            SND_SCORE5: begin
                                if (seg_idx == 2'd0)
                                    load_segment(SND_SCORE5, 2'd1);
                                else begin
                                    sound_kind <= SND_NONE;
                                    seg_idx    <= 2'd0;
                                    phase_step <= 24'd0;
                                    dac_out    <= 8'd128;
                                end
                            end

                            default: begin
                                sound_kind <= SND_NONE;
                                seg_idx    <= 2'd0;
                                phase_step <= 24'd0;
                                dac_out    <= 8'd128;
                            end
                        endcase
                    end
                end
            end else begin
                sample_div_cnt <= sample_div_cnt + 16'd1;
            end
        end
    end

endmodule