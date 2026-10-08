`timescale 1ns / 1ps

// Lab 6 button conditioner.
// Reuses the Lab 5 debouncer module (debouncer.v), then creates
// a one-clock rising-edge pulse for the FSM.
module button_pulse (
    input  wire clk,
    input  wire btn_raw,
    output reg  pulse
);
    wire btn_clean;
    reg btn_prev;

    debouncer u_debouncer (
        .clk  (clk),
        .pbin (btn_raw),
        .pbout(btn_clean)
    );

    always @(posedge clk) begin
        pulse    <= btn_clean & ~btn_prev;
        btn_prev <= btn_clean;
    end
endmodule