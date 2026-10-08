`timescale 1ns / 1ps

module lab6_top (
    input  wire        clk,
    input  wire        btn_action,
    input  wire        btn_reset,
    input  wire [3:0]  sw,
    output wire [15:0] led_result,
    output wire        led_zero
);

    // Switch interface
    wire [3:0] sw_clean;
    switch_interface u_switch_interface (
        .clk     (clk),
        .sw_raw  (sw),
        .sw_sync (sw_clean)
    );

    // Debouncer + edge pulse
    wire action_pulse;
    wire reset_pulse;

    button_pulse u_action_button (
        .clk     (clk),
        .btn_raw (btn_action),
        .pulse   (action_pulse)
    );

    button_pulse u_reset_button (
        .clk     (clk),
        .btn_raw (btn_reset),
        .pulse   (reset_pulse)
    );

    // FSM
    wire [3:0] active_control;
    wire       display_enable;
    wire [1:0] state_debug;

    fsm_controller u_fsm (
        .clk            (clk),
        .reset_pulse    (reset_pulse),
        .action_pulse   (action_pulse),
        .switch_control (sw_clean),
        .active_control (active_control),
        .display_enable (display_enable),
        .state_debug    (state_debug)
    );

    // Operands set to 7 and 5
    wire [31:0] A = 32'd7;
    wire [31:0] B = 32'd5;

    wire [31:0] ALUResult;
    wire        Zero;

    alu u_alu (
        .A          (A),
        .B          (B),
        .ALUControl (active_control),
        .ALUResult  (ALUResult),
        .Zero       (Zero)
    );

    // LED interface
    led_interface u_led_interface (
        .alu_result     (ALUResult),
        .zero           (Zero),
        .display_enable (display_enable),
        .led_result     (led_result),
        .led_zero       (led_zero)
    );

endmodule

module switch_interface (
    input  wire       clk,
    input  wire [3:0] sw_raw,
    output reg  [3:0] sw_sync
);
    reg [3:0] sw_meta;
    always @(posedge clk) begin
        sw_meta <= sw_raw;
        sw_sync <= sw_meta;
    end
endmodule

module button_pulse (
    input  wire clk,
    input  wire btn_raw,
    output reg  pulse
);
    wire btn_clean;
    reg  btn_prev;

    debouncer u_debouncer (
        .clk   (clk),
        .pbin  (btn_raw),
        .pbout (btn_clean)
    );

    always @(posedge clk) begin
        pulse    <= btn_clean & ~btn_prev;
        btn_prev <= btn_clean;
    end
endmodule

// Active ~20ms Debouncer for 100MHz clock
module debouncer (
    input  wire clk,
    input  wire pbin,
    output reg  pbout = 0
);
    reg [20:0] count = 0;
    reg sync_0 = 0, sync_1 = 0;

    always @(posedge clk) begin
        sync_0 <= pbin;
        sync_1 <= sync_0;

        if (sync_1 != pbout) begin
            count <= count + 1'b1;
            if (count == 21'd2_000_000) begin // 20ms at 100MHz
                pbout <= sync_1;
                count <= 0;
            end
        end else begin
            count <= 0;
        end
    end
endmodule

module fsm_controller (
    input  wire       clk,
    input  wire       reset_pulse,
    input  wire       action_pulse,
    input  wire [3:0] switch_control,
    output reg  [3:0] active_control = 4'b0000,
    output reg        display_enable = 1'b0,
    output reg  [1:0] state_debug
);
    localparam INPUT_WAITING = 2'b00;
    localparam COUNTING      = 2'b01;
    localparam RESET_STATE   = 2'b10;

    reg [1:0] state = INPUT_WAITING;
    reg [1:0] next_state;

    always @(*) begin
        next_state = state;
        case (state)
            INPUT_WAITING: begin
                if (reset_pulse)
                    next_state = RESET_STATE;
                else if (action_pulse)
                    next_state = COUNTING;
            end
            COUNTING: begin
                if (reset_pulse)
                    next_state = RESET_STATE;
                else
                    next_state = COUNTING;
            end
            RESET_STATE: begin
                next_state = INPUT_WAITING;
            end
            default: next_state = INPUT_WAITING;
        endcase
    end

    always @(posedge clk) begin
        state <= next_state;
        if (state == RESET_STATE) begin
            active_control <= 4'b0000;
        end
        else if (action_pulse) begin
            active_control <= switch_control;
        end
    end

    always @(*) begin
        state_debug = state;
        case (state)
            COUNTING: display_enable = 1'b1;
            default:  display_enable = 1'b0;
        endcase
    end
endmodule

module alu (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [3:0]  ALUControl,
    output reg  [31:0] ALUResult,
    output wire        Zero
);
    always @(*) begin
        case (ALUControl)
            4'b0000: ALUResult = A & B;
            4'b0001: ALUResult = A | B;
            4'b0010: ALUResult = A + B;
            4'b0011: ALUResult = A ^ B;
            4'b0100: ALUResult = A << B[4:0];
            4'b0101: ALUResult = A >> B[4:0];
            4'b0110: ALUResult = A - B;
            4'b0111: ALUResult = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;
            4'b1000: ALUResult = (A < B) ? 32'd1 : 32'd0;
            4'b1001: ALUResult = A;
            4'b1010: ALUResult = B;
            4'b1100: ALUResult = ~(A | B);
            default: ALUResult = 32'b0;
        endcase
    end

    assign Zero = (ALUResult == 32'b0);
endmodule

module led_interface (
    input  wire [31:0] alu_result,
    input  wire        zero,
    input  wire        display_enable,
    output reg  [15:0] led_result,
    output reg         led_zero
);
    always @(*) begin
        if (display_enable) begin
            led_result = alu_result[15:0];
            led_zero   = zero;
        end
        else begin
            led_result = 16'h0000;
            led_zero   = 1'b0;
        end
    end
endmodule