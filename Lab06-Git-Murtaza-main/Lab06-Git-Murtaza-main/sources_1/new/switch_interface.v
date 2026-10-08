`timescale 1ns / 1ps

// Generic 2-flip-flop switch synchronizer.
// IMPORTANT: If your Lab 5 already has a switch-interface module,
// reuse the Lab 5 file instead of this one, as required by the lab sheet.
module switch_interface(
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