`timescale 1ns / 1ps

// Three required phases:
// 1) INPUT_WAITING : wait for operation selection.
// 2) COUNTING      : selected ALU operation is active/displayed.
//                    Press ACTION again after changing switches to
//                    load another ALUControl value.
// 3) RESET_STATE   : clears the active control for one clock, then
//                    returns to INPUT_WAITING.
module fsm_controller(
    input  wire       clk,
    input  wire       reset_pulse,
    input  wire       action_pulse,
    input  wire [3:0] switch_control,
    output reg  [3:0] active_control,
    output reg        display_enable,
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
        // In WAITING, this starts the first operation.
        // In COUNTING, this loads the newly selected operation.
        active_control <= switch_control;
    end
end

always @(*) begin
    state_debug = state;

    case (state)
        COUNTING:    display_enable = 1'b1;
        default:     display_enable = 1'b0;
    endcase
end

endmodule