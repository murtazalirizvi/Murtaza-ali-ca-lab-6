`timescale 1ns / 1ps

// Generic LED interface.
// Lower 16 bits of ALUResult go to result LEDs.
// Zero gets its own LED.
// IMPORTANT: If your Lab 5 has an LED-interface module,
// reuse that exact file and adapt only the top-level port wiring.
module led_interface(
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