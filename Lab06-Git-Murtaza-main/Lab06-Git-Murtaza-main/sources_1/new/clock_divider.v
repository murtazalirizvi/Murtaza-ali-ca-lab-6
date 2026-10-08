`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 

// Module Name: clock_divider
// Project Name: Counter
// Target Devices: Baasys 3
// 
//////////////////////////////////////////////////////////////////////////////////


module clock_divider (
    input wire clk_in,    // The super fast 100MHz board clock
    input wire rst,       // The reset button
    output reg clk_out    // Our new slow 1Hz clock
);

    // A register big enough to hold the number 50,000,000
    reg [25:0] count = 0; 
    
    // We toggle the output every 50 Million ticks. 
    // 50M High + 50M Low = 100M total ticks = 1 full second.
    
    // TEMPORARILY CHANGED FOR SIMULATION ONLY!
    // Change this back to 50_000_000 - 1 before programming the board!
  
// localparam MAX_COUNT = 2;            // Commented out for hardware implementation
localparam MAX_COUNT = 50_000_000 - 1;  // 1 Hz slow clock for Basys 3 board

    always @(posedge clk_in) begin
        if (rst) begin
            count <= 0;
            clk_out <= 0;
        end 
        else if (count == MAX_COUNT) begin
            count <= 0;
            clk_out <= ~clk_out; // Flip the slow clock opposite of what it was
        end 
        else begin
            count <= count + 1;
        end
    end

endmodule